<script setup lang="ts">
import { computed, watch } from 'vue';

import { useCountdownStore } from '@/stores/useCountdownStore';
import { useGameStore } from '@/stores/useGameStore';
import type { Player } from '@/types';

const gameStore = useGameStore();
const countdownStore = useCountdownStore();

const noCardsChosen = computed(
  () => !gameStore.players.some((player: Player) => player.card !== null),
);

watch(() => gameStore.areCardsRevealed, (areCardsRevealed) => {
  if (!areCardsRevealed) {
    return;
  }

  countdownStore.countDownFrom(3);
});
</script>

<template>
  <!-- center table -->
  <div
    class="
      bg-blue-100 dark:bg-gray-800 rounded-full max-w-full
      w-96 h-48 flex justify-center items-center z-10
    "
  >
    <p v-if="noCardsChosen && !gameStore.areCardsRevealed">
      Pick your cards!
    </p>

    <p
      v-else-if="countdownStore.isRunning"
      class="text-3xl text-blue-600 dark:text-blue-200 font-semibold"
      v-text="countdownStore.countdown"
    />

    <button
      v-else
      class="
        py-2 px-4 bg-blue-600 hover:bg-blue-700 dark:bg-blue-200 dark:hover:bg-blue-300
        rounded-md transition font-semibold text-lg text-white dark:text-gray-900
      "
      type="button"
      @click="gameStore.areCardsRevealed ? gameStore.resetCards() : gameStore.revealCards()"
    >
      {{ gameStore.areCardsRevealed ? 'Next voting' : 'Show cards' }}
    </button>
  </div>
</template>
