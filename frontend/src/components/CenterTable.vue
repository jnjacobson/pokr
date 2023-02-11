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
  <div class="bg-contrast rounded-full w-96 h-48 flex justify-center items-center z-10">
    <p v-if="noCardsChosen && !gameStore.areCardsRevealed">
      Pick your cards!
    </p>

    <p
      v-else-if="countdownStore.isRunning"
      class="text-3xl text-text font-semibold"
      v-text="countdownStore.countdown"
    />

    <button
      v-else
      class="px-4 py-2 rounded-md transition duration-75 font-semibold text-button-text bg-button-bg hover:button-bg-hover"
      type="button"
      @click="gameStore.areCardsRevealed ? gameStore.resetCards() : gameStore.revealCards()"
    >
      {{ gameStore.areCardsRevealed ? 'Next voting' : 'Show cards' }}
    </button>
  </div>
</template>
