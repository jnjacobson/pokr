<script setup lang="ts">
import { computed, watch } from 'vue';

import BaseButton from '@/components/BaseButton.vue';
import { useCountdownStore } from '@/stores/useCountdownStore';
import { useGameStore } from '@/stores/useGameStore';
import type { Player } from '@/types';

const gameStore = useGameStore();
const countdownStore = useCountdownStore();

const noCardsChosen = computed(
  () => !gameStore.players.some((player: Player) => player.card !== null),
);

watch(() => gameStore.areCardsRevealed, (areCardsRevealed, oldAreCardsRevealed) => {
  const didJustJoin = oldAreCardsRevealed === undefined;
  if (!areCardsRevealed || didJustJoin) {
    return;
  }

  countdownStore.countDownFrom(3);
});
</script>

<template>
  <div
    class="
      bg-blue-100 dark:bg-gray-800 rounded-full max-w-full
      w-96 h-40 md:h-48 flex justify-center items-center z-10
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

    <BaseButton
      v-else
      class="text-lg"
      @click="gameStore.areCardsRevealed ? gameStore.resetCards() : gameStore.revealCards()"
    >
      {{ gameStore.areCardsRevealed ? 'Next voting' : 'Show cards' }}
    </BaseButton>
  </div>
</template>
