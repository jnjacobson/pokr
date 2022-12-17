import { defineStore } from "pinia";
import type { Player } from "@/types";
import { ref, computed, watch, type Ref, type ComputedRef } from "vue";
import { Channel, Socket } from "phoenix";
import { usePlayerNameStore } from "@/components/playerName/usePlayerNameStore";

export const useGameStore = defineStore('game', (): {
  gameId: Ref<string | undefined>,
  deck: Ref<string[]>
  areCardsRevealed: Ref<boolean>,
  players: Ref<Player[]>,
  myPlayer: ComputedRef<Player | undefined>,
  isConnected: Ref<boolean>,

  joinGame: (gameId: string) => void,
  chooseCard: (card: string) => void,
  revealCards: () => void,
  resetCards: () => void,
} => {
  const playerNameStore = usePlayerNameStore();
  
  const gameId = ref<string>();
  const deck = ref<string[]>([]);
  const areCardsRevealed = ref(false);
  const isConnected = ref(false);
  const players = ref<Player[]>([]);
  const myId = ref<string>();

  const myPlayer = computed(() =>
    players.value.find((player) => player.id === myId.value)
  );

  const socket = ref<Socket>(new Socket(`ws://${import.meta.env.VITE_BACKEND_URL}/socket`));
  const channel = ref<Channel>();

  const addOrUpdatePlayer = (player: Player) => {
    const idx = players.value.findIndex(({ id }) => id === player.id);

    if (idx === -1) {
      players.value.push(player); // a new player

      return;
    }

    players.value[idx] = player;
  }

  const joinGame = (newGameId: string) => {
    socket.value.connect();

    channel.value = socket.value.channel(`game:${newGameId}`);
    channel.value.on('join', (joinPayload: { player_id: string, deck: string[], are_cards_revealed: boolean}) => {
      gameId.value = newGameId;
      deck.value = joinPayload.deck;
      areCardsRevealed.value = joinPayload.are_cards_revealed;
      isConnected.value = true;

      myId.value = joinPayload.player_id;
      players.value.push({
        id: myId.value,
        name: playerNameStore.playerName,
        card: null,
      });
    });
    channel.value.on('player_joined', () => {
      // a new player joined, say hello
      channel.value?.push('player_updated', myPlayer.value ?? {});
    });
    channel.value.on('player_updated', (updatedPlayer: Player) => {
      if (updatedPlayer.id === myId.value) {
        return;
      }

      addOrUpdatePlayer(updatedPlayer);
    });
    channel.value.on('player_left', ({ id }) => {
      const idx = players.value.findIndex((player) => player.id === id);

      players.value.splice(idx, 1);
    });
    channel.value.on('cards_revealed', () => {
      areCardsRevealed.value = true;
    });
    channel.value.on('cards_reset', () => {
      areCardsRevealed.value = false;
      chooseCard(null);
    });

    watch(myPlayer, (updatedMyPlayer) => {
      if (updatedMyPlayer === undefined) {
        return;
      }

      channel.value?.push('player_updated', updatedMyPlayer);
    }, { deep: true });

    watch(() => playerNameStore.playerName, (newName) => {
      const myPlayerRaw = myPlayer.value;
      if (myPlayerRaw === undefined) {
        return;
      }

      myPlayerRaw.name = newName;
    });

    channel.value.join();
  };

  const revealCards = () => {
    channel.value?.push('cards_revealed', {});
  }

  const resetCards = () => {
    channel.value?.push('cards_reset', {});
  }

  const chooseCard = (card: string | null) => {
    const myPlayerRaw = myPlayer.value;
    if (myPlayerRaw === undefined) {
      return;
    }

    myPlayerRaw.card = card;
  }

  return {
    gameId,
    deck,
    areCardsRevealed,
    players,
    myPlayer,
    isConnected,

    joinGame,
    chooseCard,
    revealCards,
    resetCards,
  };
});
