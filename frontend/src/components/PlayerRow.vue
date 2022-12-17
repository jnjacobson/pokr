<script setup lang="ts">
import { useCountdownStore } from '@/stores/useCountdownStore';
import { useGameStore } from '@/stores/useGameStore';
import type { Player as PlayerType } from '@/types';
import Player from './Player.vue';

defineProps<{
  players: PlayerType[],
}>();

const gameStore = useGameStore();
const countdownStore = useCountdownStore();
</script>

<template>
  <div class="flex space-x-6">
    <Player
      v-for="player in players"
      :key="player.id"
      :player="player"
      :revealed="gameStore.areCardsRevealed && !countdownStore.isRunning"
      :is-my-player="player.id === gameStore.myPlayer?.id"
    />
  </div>
</template>
