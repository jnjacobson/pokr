import { defineStore } from 'pinia';
import {
  ref,
  computed,
  watch,
  shallowRef,
  type Ref,
  type ComputedRef,
} from 'vue';
import { Channel, Socket, Presence } from 'phoenix';
import { useLocalStorage, useSessionStorage } from '@vueuse/core';

import { usePlayerSettingsStore } from '@/components/playerSettings/usePlayerSettingsStore';
import type {
  JoinErrorPayload, JoinPayload, Player, SessionReplacedPayload,
} from '@/types';
import { ChannelEvent } from '@/types';

export const useGameStore = defineStore('game', (): {
  gameId: Ref<string | undefined>,
  deck: Ref<string[]>
  areCardsRevealed: Ref<boolean | undefined>,
  players: Ref<Player[]>,
  myPlayer: ComputedRef<Player | undefined>,
  isConnected: Ref<boolean>,
  isSessionReplaced: Ref<boolean>,
  isGameNotFound: Ref<boolean>,

  joinGame: (gameId: string) => void,
  chooseCard: (card: string | null) => void,
  revealCards: () => void,
  resetCards: () => void,
} => {
  const playerSettingsStore = usePlayerSettingsStore();

  const gameId = ref<string>();
  const deck = ref<string[]>([]);
  const areCardsRevealed = ref<boolean | undefined>(undefined);
  const isConnected = ref(false);
  const isSessionReplaced = ref(false);
  const isGameNotFound = ref(false);
  const players = ref<Player[]>([]);
  const myId = useLocalStorage<string | undefined>('playerId', undefined);
  const myToken = useLocalStorage<string | undefined>('playerToken', undefined);
  const myCardSessionStorageKey = computed(() => `playerCard:${gameId.value}`);
  const myCard = useSessionStorage<string | null>(myCardSessionStorageKey, null);
  const joinedAt = ref<number>(0);

  const myPlayer = computed(() => players.value.find((player) => player.id === myId.value));

  // shallowRef: phoenix compares object identity internally, which breaks behind Vue's deep reactive proxies.
  const socket = shallowRef<Socket>(new Socket(import.meta.env.VITE_BACKEND_WS_URL, {
    params: () => ({
      player_id: myId.value,
      token: myToken.value,
    }),
  }));
  const channel = shallowRef<Channel>();
  const presence = shallowRef<Presence>();

  socket.value.onOpen(() => { isConnected.value = true; });
  socket.value.onClose(() => { isConnected.value = false; });

  watch(
    () => [playerSettingsStore.playerName, playerSettingsStore.isSpectator] as const,
    ([newName, isSpectator]) => {
      updateMyPlayer({ name: newName, isSpectator });
    },
  );

  function joinGame(newGameId: string) {
    if (channel.value) {
      channel.value.leave();
    }

    players.value = [];

    socket.value.connect();

    if (!socket.value.isConnected) {
      throw new Error(`Couldn't connect to socket: ${socket.value.connectionState}`);
    }

    channel.value = socket.value.channel(`game:${newGameId}`);
    gameId.value = newGameId;

    presence.value = new Presence(channel.value);

    presence.value.onSync(onSync);
    presence.value.onJoin(onPresenceJoin);

    channel.value.on(ChannelEvent.Join, onJoin);
    channel.value.on(ChannelEvent.PlayerUpdated, onPlayerUpdated);
    channel.value.on(ChannelEvent.CardsRevealed, onCardsRevealed);
    channel.value.on(ChannelEvent.CardsReset, onCardsReset);
    channel.value.on(ChannelEvent.SessionReplaced, onSessionReplaced);

    channel.value.join().receive('error', onJoinError);
  }

  function revealCards() {
    channel.value?.push(ChannelEvent.CardsRevealed, {});
  }

  function resetCards() {
    channel.value?.push(ChannelEvent.CardsReset, {});
  }

  function chooseCard(card: string | null) {
    updateMyPlayer({ card });
  }

  function updateMyPlayer(player: Partial<Player>) {
    if (myPlayer.value === undefined) {
      return;
    }

    myPlayer.value.name = player.name ?? myPlayer.value.name;
    myPlayer.value.isSpectator = player.isSpectator ?? myPlayer.value.isSpectator;

    // A spectator never holds a vote.
    const card = myPlayer.value.isSpectator ? null : player.card;

    if (card !== undefined) {
      myPlayer.value.card = card;
      myCard.value = card;
    }

    channel.value?.push(ChannelEvent.PlayerUpdated, myPlayer.value);
  }

  /** My name, role and card as kept on this device. A spectator never holds a vote. */
  function myLocalPlayer(): Omit<Player, 'id'> {
    const { playerName, isSpectator } = playerSettingsStore;

    return { name: playerName, isSpectator, card: isSpectator ? null : myCard.value };
  }

  /** Callback functions for events */

  function onSync() {
    const activeIds = new Set<string>();
    presence.value?.list((id) => {
      activeIds.add(id);
    });

    // Remove players that are no longer active
    players.value = players.value.filter((player) => activeIds.has(player.id));

    const newPlayers = Array.from(activeIds).filter((id) => !players.value.some((p) => p.id === id));
    newPlayers.forEach((id) => {
      players.value.push(
        id === myId.value
          ? { id, ...myLocalPlayer() }
          : {
            id, name: 'New Player', card: null, isSpectator: false,
          },
      );
    });
  }

  function onJoin(joinPayload: JoinPayload & { joined_at: number }) {
    deck.value = joinPayload.deck;
    areCardsRevealed.value = joinPayload.are_cards_revealed;

    myId.value = joinPayload.player_id;
    myToken.value = joinPayload.token;
    joinedAt.value = joinPayload.joined_at;

    if (myPlayer.value === undefined) {
      return;
    }

    Object.assign(myPlayer.value, myLocalPlayer());

    channel.value?.push(ChannelEvent.PlayerUpdated, myPlayer.value);
  }

  function onPlayerUpdated(updatedPlayer: Player) {
    if (updatedPlayer.id === myId.value) {
      return;
    }

    const idx = players.value.findIndex(({ id }) => id === updatedPlayer.id);

    if (idx === -1) {
      players.value.push(updatedPlayer); // a new player

      return;
    }

    players.value[idx] = updatedPlayer;
  }


  function onCardsRevealed() {
    areCardsRevealed.value = true;
  }

  function onPresenceJoin(id: string|undefined) {
    if (id === myId.value || myPlayer.value === undefined) {
      return;
    }

    channel.value?.push(ChannelEvent.PlayerUpdated, myPlayer.value);
  }

  function onCardsReset() {
    areCardsRevealed.value = false;
    myCard.value = null;

    players.value.forEach((player: Player) => {
      player.card = null;
    });
  }

  function onJoinError({ reason }: JoinErrorPayload) {
    // Other errors, like an unreachable database, are worth retrying: phoenix rejoins by itself.
    if (reason !== 'game_not_found') {
      return;
    }

    channel.value?.leave();
    isGameNotFound.value = true;
  }

  function onSessionReplaced({ player_id, new_join_at }: SessionReplacedPayload) {
    if (player_id === myId.value && new_join_at > joinedAt.value && joinedAt.value !== 0) {
      // This is an older tab, the session has been replaced by a newer one.
      channel.value?.leave();
      isSessionReplaced.value = true;
    }
  }

  return {
    gameId,
    deck,
    areCardsRevealed,
    players,
    myPlayer,
    isConnected,
    isSessionReplaced,
    isGameNotFound,

    joinGame,
    chooseCard,
    revealCards,
    resetCards,
  };
});
