import { defineStore } from 'pinia';
import {
  ref,
  computed,
  watch,
  type Ref,
  type ComputedRef,
} from 'vue';
import { Channel, Socket, Presence } from 'phoenix';
import { useLocalStorage, useSessionStorage, watchIgnorable } from '@vueuse/core';

import { usePlayerNameStore } from '@/components/playerName/usePlayerNameStore';
import type {JoinPayload, Player, SessionReplacedPayload } from '@/types';
import { ChannelEvent } from '@/types';

export const useGameStore = defineStore('game', (): {
  gameId: Ref<string | undefined>,
  deck: Ref<string[]>
  areCardsRevealed: Ref<boolean | undefined>,
  players: Ref<Player[]>,
  myPlayer: ComputedRef<Player | undefined>,
  isConnected: Ref<boolean>,
  isSessionReplaced: Ref<boolean>,

  joinGame: (gameId: string) => void,
  chooseCard: (card: string) => void,
  revealCards: () => void,
  resetCards: () => void,
} => {
  const playerNameStore = usePlayerNameStore();

  const gameId = ref<string>();
  const deck = ref<string[]>([]);
  const areCardsRevealed = ref<boolean | undefined>(undefined);
  const isConnected = ref(false);
  const isSessionReplaced = ref(false);
  const players = ref<Player[]>([]);
  const myId = useLocalStorage<string | undefined>('playerId', undefined);
  const myToken = useLocalStorage<string | undefined>('playerToken', undefined);
  const myCardSessionStorageKey = computed(() => `playerCard:${gameId.value}`);
  const myCard = useSessionStorage<string | null>(myCardSessionStorageKey, null);
  const joinedAt = ref<number>(0);

  const myPlayer = computed(() => players.value.find((player) => player.id === myId.value));

  const socket = ref<Socket>(new Socket(import.meta.env.VITE_BACKEND_WS_URL, {
    params: () => ({
      player_id: myId.value,
      token: myToken.value,
    }),
  }));
  const channel = ref<Channel>();
  const presence = ref<Presence>();

  socket.value.onOpen(() => { isConnected.value = true; });
  socket.value.onClose(() => { isConnected.value = false; });

  const {
    ignoreUpdates: ignoreMyPlayerUpdates,
  } = watchIgnorable([
    () => myPlayer.value?.card,
    () => myPlayer.value?.name,
  ], ([newCard, newName], [oldCard, oldName]) => {
    if (newCard === oldCard && newName === oldName) {
      return;
    }

    const myPlayerRaw = myPlayer.value;
    if (myPlayerRaw === undefined) {
      return;
    }

    channel.value?.push(ChannelEvent.PlayerUpdated, myPlayerRaw);
  }, { deep: true });

  watch(() => playerNameStore.playerName, (newName) => {
    const myPlayerRaw = myPlayer.value;
    if (myPlayerRaw === undefined) {
      return;
    }

    myPlayerRaw.name = newName;
  });

  /** Actions */

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

    channel.value.on(ChannelEvent.Join, onJoin);
    channel.value.on(ChannelEvent.PlayerUpdated, onPlayerUpdated);
    channel.value.on(ChannelEvent.CardsRevealed, onCardsRevealed);
    channel.value.on(ChannelEvent.CardsReset, onCardsReset);
    channel.value.on(ChannelEvent.SessionReplaced, onSessionReplaced);

    channel.value.join();
  }

  function revealCards() {
    channel.value?.push(ChannelEvent.CardsRevealed, {});
  }

  function resetCards() {
    channel.value?.push(ChannelEvent.CardsReset, {});
  }

  function chooseCard(card: string | null) {
    const myPlayerRaw = myPlayer.value;
    if (myPlayerRaw === undefined) {
      return;
    }

    myPlayerRaw.card = card;
    myCard.value = card;
  }

  /** Callback functions for events */

  function onSync() {
    const activeIds: string[] = [];
    presence.value?.list((id) => {
      activeIds.push(id);
    });

    // Remove players that are no longer active
    players.value = players.value.filter((player) => activeIds.includes(player.id));

    const newPlayers = activeIds.filter((id) => !players.value.some((p) => p.id === id));
    newPlayers.forEach((id) => {
      players.value.push({
        id,
        name: id === myId.value ? playerNameStore.playerName : 'New Player',
        card: id === myId.value ? myCard.value : null,
      });
    });

    const somebodyElseJoined = newPlayers.length > 0 && !newPlayers.includes(myId.value ?? '');

    if (myPlayer.value && somebodyElseJoined) {
      // say hello to the new player
      channel.value?.push(ChannelEvent.PlayerUpdated, myPlayer.value);
    }
  }

  function onJoin(joinPayload: JoinPayload & { joined_at: number }) {
    deck.value = joinPayload.deck;
    areCardsRevealed.value = joinPayload.are_cards_revealed;

    myId.value = joinPayload.player_id;
    myToken.value = joinPayload.token;
    joinedAt.value = joinPayload.joined_at;
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

  function onCardsReset() {
    areCardsRevealed.value = false;
    myCard.value = null;

    ignoreMyPlayerUpdates(() => {
      players.value.forEach((player: Player) => {
        player.card = null;
      });
    });
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

    joinGame,
    chooseCard,
    revealCards,
    resetCards,
  };
});
