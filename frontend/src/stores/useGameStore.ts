import { defineStore } from "pinia";
import type { Game, Player } from "@/types";
import { ref, computed, watch, type Ref, type ComputedRef } from "vue";
import { Channel, Socket } from "phoenix";

export const useGameStore = defineStore('game', (): {
  game: Ref<Game>,
  players: Ref<Player[]>,
  myPlayer: ComputedRef<Player | undefined>,
  isLoading: Ref<boolean>,
  inGame: ComputedRef<boolean>,

  joinGame: (gameId: string) => void,
  // chooseCard: (card: string) => Promise<void>,
  revealCards: () => void,
  resetCards: () => void,
} => {
  const game = ref<Game>({
    id: null,
    deck: [],
    areCardsRevealed: false,
    isConnected: false,
  });
  const players = ref<Player[]>([]);
  const myId = ref<string>();

  const myPlayer = computed(() =>
    players.value.find((player) => player.id === myId.value)
  );

  const isLoading = ref(false);
  const inGame = computed(() => game.value.isConnected);

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

  const joinGame = (gameId: string) => {
    socket.value.connect();

    channel.value = socket.value.channel(`game:${gameId}`);
    channel.value.on('join', (joinPayload: { player_id: string, deck: string[], are_cards_revealed: boolean}) => {
      game.value.id = gameId;
      game.value.deck = joinPayload.deck;
      game.value.areCardsRevealed = joinPayload.are_cards_revealed;
      game.value.isConnected = true;

      myId.value = joinPayload.player_id;
      players.value.push({
        id: myId.value,
        name: `user_${myId.value}`,
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
      game.value.areCardsRevealed = true;
    });
    channel.value.on('cards_reset', () => {
      game.value.areCardsRevealed = false;
    });

    watch(myPlayer, (updatedMyPlayer) => {
      if (updatedMyPlayer === undefined) {
        return;
      }

      channel.value?.push('player_updated', updatedMyPlayer);
    });

    channel.value.join();
  };

  const revealCards = () => {
    channel.value?.push('cards_revealed', {});
  }

  const resetCards = () => {
    channel.value?.push('cards_reset', {});
  }

  return {
    game,
    players,
    myPlayer,
    isLoading,
    inGame,

    joinGame,
    revealCards,
    resetCards,
  };
});
