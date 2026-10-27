import { createPinia, setActivePinia } from 'pinia';
import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from 'vitest';

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
        payload: { id: ME, name: 'New Player', card: null },
      }));
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
        payload: { id: ME, name: 'New Player', card: '5' },
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
