import { createPinia, setActivePinia } from 'pinia';
import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from 'vitest';

import { usePlayerSettingsStore } from '@/components/playerSettings/usePlayerSettingsStore';
import { useGameStore } from '@/stores/useGameStore';
import { FakePhoenixServer } from '@/test/FakePhoenixServer';
import { ChannelEvent } from '@/types';

const ME = 'player-me';
const OTHER = 'player-other';
const TOPIC = 'game:test-game';

let server: FakePhoenixServer;

beforeEach(() => {
  localStorage.clear();
  sessionStorage.clear();

  vi.stubEnv('VITE_BACKEND_WS_URL', 'ws://backend.test/socket');

  server = new FakePhoenixServer({ playerId: ME, otherPlayerIds: [OTHER] });
  server.install();

  setActivePinia(createPinia());
});

afterEach(() => {
  server.dispose();
  vi.unstubAllEnvs();
});

/** Joins the game and waits until the server's join payload has been applied. */
async function joinGame() {
  const store = useGameStore();

  store.joinGame('test-game');
  await vi.waitFor(() => expect(store.myPlayer).toBeDefined());

  return store;
}

function playerIds(store: ReturnType<typeof useGameStore>) {
  return store.players.map(({ id }) => id).sort();
}

describe('useGameStore', () => {
  describe('connecting', () => {
    // Regression test: phoenix 1.8 compares object identity internally, which broke when the
    // socket sat behind a deep Vue ref. The socket opened, but isConnected never turned true.
    it('is connected once the socket has opened', async () => {
      const store = useGameStore();

      expect(store.isConnected).toBe(false);

      store.joinGame('test-game');

      await vi.waitFor(() => expect(store.isConnected).toBe(true));
    });

    it('takes the deck and reveal state from the join payload', async () => {
      server.game.deck = ['1', '2', '3'];
      server.game.areCardsRevealed = true;

      const store = await joinGame();

      expect(store.deck).toEqual(['1', '2', '3']);
      expect(store.areCardsRevealed).toBe(true);
    });

    it('announces itself to the other players after joining', async () => {
      await joinGame();

      await vi.waitFor(() => expect(server.received).toContainEqual({
        topic: TOPIC,
        event: ChannelEvent.PlayerUpdated,
        payload: { id: ME, name: 'New Player', card: null, isSpectator: false },
      }));
    });
  });

  describe('refused joins', () => {
    it('flags a game that does not exist and has nobody in it', async () => {
      server.joinRefusal = 'game_not_found';
      const store = useGameStore();

      store.joinGame('test-game');

      await vi.waitFor(() => expect(store.isGameNotFound).toBe(true));
      expect(store.myPlayer).toBeUndefined();
    });

    it('does not flag temporary errors, which phoenix retries by itself', async () => {
      server.joinRefusal = 'unavailable';
      const store = useGameStore();

      store.joinGame('test-game');

      await vi.waitFor(() => expect(store.isConnected).toBe(true));
      await new Promise((resolve) => { setTimeout(resolve, 50); });
      expect(store.isGameNotFound).toBe(false);
    });
  });

  describe('players', () => {
    it('lists everyone who is present', async () => {
      const store = await joinGame();

      expect(playerIds(store)).toEqual([ME, OTHER].sort());
    });

    it('shows the name and card another player sends', async () => {
      const store = await joinGame();

      server.push(ChannelEvent.PlayerUpdated, { id: OTHER, name: 'Ann', card: '5' });

      await vi.waitFor(() => expect(store.players.find(({ id }) => id === OTHER))
        .toMatchObject({ name: 'Ann', card: '5' }));
    });

    it('adds players who join later', async () => {
      const store = await joinGame();

      server.playerJoins('player-late');

      await vi.waitFor(() => expect(playerIds(store)).toContain('player-late'));
    });

    it('removes players who leave', async () => {
      const store = await joinGame();

      server.playerLeaves(OTHER);

      await vi.waitFor(() => expect(playerIds(store)).toEqual([ME]));
    });
  });

  describe('cards', () => {
    it('sends the chosen card and keeps it on my player', async () => {
      const store = await joinGame();

      store.chooseCard('5');

      expect(store.myPlayer?.card).toBe('5');
      await vi.waitFor(() => expect(server.received).toContainEqual({
        topic: TOPIC,
        event: ChannelEvent.PlayerUpdated,
        payload: { id: ME, name: 'New Player', card: '5', isSpectator: false },
      }));
    });

    it('reveals the cards for everyone', async () => {
      const store = await joinGame();

      store.revealCards();

      await vi.waitFor(() => expect(store.areCardsRevealed).toBe(true));
      expect(server.received).toContainEqual({ topic: TOPIC, event: ChannelEvent.CardsRevealed, payload: {} });
    });

    it('clears every card when the table is reset', async () => {
      const store = await joinGame();

      server.push(ChannelEvent.PlayerUpdated, { id: OTHER, name: 'Ann', card: '8' });
      store.chooseCard('5');
      store.revealCards();
      await vi.waitFor(() => expect(store.areCardsRevealed).toBe(true));

      server.push(ChannelEvent.CardsReset, {});

      await vi.waitFor(() => expect(store.areCardsRevealed).toBe(false));
      expect(store.players.map(({ card }) => card)).toEqual([null, null]);
    });
  });

  describe('deck', () => {
    it('asks the server to change the deck', async () => {
      const store = await joinGame();

      store.changeDeck(['XS', 'S', 'M']);

      await vi.waitFor(() => expect(server.received).toContainEqual({
        topic: TOPIC,
        event: ChannelEvent.DeckChanged,
        payload: { deck: ['XS', 'S', 'M'] },
      }));
    });

    it('switches to the new deck and drops every card when someone changes it', async () => {
      const store = await joinGame();

      server.push(ChannelEvent.PlayerUpdated, { id: OTHER, name: 'Ann', card: '2' });
      store.chooseCard('3');
      await vi.waitFor(() => expect(store.players.map(({ card }) => card)).toContain('2'));
      expect(sessionStorage.getItem('playerCard:test-game')).toBe('3');

      server.push(ChannelEvent.DeckChanged, { deck: ['XS', 'S', 'M'] });

      await vi.waitFor(() => expect(store.deck).toEqual(['XS', 'S', 'M']));
      expect(store.players.map(({ card }) => card)).toEqual([null, null]);
      expect(sessionStorage.getItem('playerCard:test-game')).toBeNull();
    });

    it('remembers the deck of the game for the next one, whoever changed it', async () => {
      server.game.deck = ['1', '2'];
      const store = await joinGame();
      expect(localStorage.getItem('lastDeck')).toBe('["1","2"]');

      server.push(ChannelEvent.DeckChanged, { deck: ['XS', 'S', 'M'] });

      await vi.waitFor(() => expect(store.deck).toEqual(['XS', 'S', 'M']));
      expect(localStorage.getItem('lastDeck')).toBe('["XS","S","M"]');
    });
  });

  describe('spectators', () => {
    it('shows another player as a spectator when they say so', async () => {
      const store = await joinGame();

      server.push(ChannelEvent.PlayerUpdated, {
        id: OTHER, name: 'Pat', card: null, isSpectator: true,
      });

      await vi.waitFor(() => expect(store.players.find(({ id }) => id === OTHER))
        .toMatchObject({ name: 'Pat', isSpectator: true }));
    });

    it('joins as a spectator when I chose to be one', async () => {
      localStorage.setItem('isSpectator', 'true');

      const store = await joinGame();

      expect(store.myPlayer?.isSpectator).toBe(true);
      await vi.waitFor(() => expect(server.received).toContainEqual({
        topic: TOPIC,
        event: ChannelEvent.PlayerUpdated,
        payload: { id: ME, name: 'New Player', card: null, isSpectator: true },
      }));
    });

    it('drops my card when I become a spectator and starts clean when I return', async () => {
      const store = await joinGame();
      const playerSettingsStore = usePlayerSettingsStore();

      store.chooseCard('5');
      playerSettingsStore.isSpectator = true;

      await vi.waitFor(() => expect(server.received).toContainEqual({
        topic: TOPIC,
        event: ChannelEvent.PlayerUpdated,
        payload: { id: ME, name: 'New Player', card: null, isSpectator: true },
      }));
      expect(store.myPlayer).toMatchObject({ card: null, isSpectator: true });

      playerSettingsStore.isSpectator = false;

      await vi.waitFor(() => expect(store.myPlayer?.isSpectator).toBe(false));
      expect(store.myPlayer?.card).toBeNull();
    });

    it('cannot choose a card while spectating', async () => {
      localStorage.setItem('isSpectator', 'true');
      const store = await joinGame();

      store.chooseCard('5');

      expect(store.myPlayer?.card).toBeNull();
    });

    it('can still reveal the cards', async () => {
      localStorage.setItem('isSpectator', 'true');
      const store = await joinGame();

      store.revealCards();

      await vi.waitFor(() => expect(store.areCardsRevealed).toBe(true));
    });
  });

  describe('session replaced', () => {
    it('is flagged when a newer tab joins with my player id', async () => {
      const store = await joinGame();

      server.push(ChannelEvent.SessionReplaced, { player_id: ME, new_join_at: server.game.joinedAt + 1 });

      await vi.waitFor(() => expect(store.isSessionReplaced).toBe(true));
    });

    it('is ignored for other players and for older sessions', async () => {
      const store = await joinGame();

      server.push(ChannelEvent.SessionReplaced, { player_id: OTHER, new_join_at: server.game.joinedAt + 1 });
      server.push(ChannelEvent.SessionReplaced, { player_id: ME, new_join_at: server.game.joinedAt - 1 });
      // Pushes are delivered in order, so by the time this one has been applied the others have too.
      server.push(ChannelEvent.CardsRevealed, {});
      await vi.waitFor(() => expect(store.areCardsRevealed).toBe(true));

      expect(store.isSessionReplaced).toBe(false);
    });
  });
});
