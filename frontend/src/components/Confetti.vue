<script setup lang="ts">
import { onMounted, ref, watch } from 'vue';
import type { AnimationItem } from 'lottie-web-light';
import Lottie from 'lottie-web-light';

import { useCountdownStore } from '@/stores/useCountdownStore';
import { useGameStore } from '@/stores/useGameStore';

const confetti = ref<HTMLElement>();
const confettiAnimation = ref<AnimationItem>();

const countdownStore = useCountdownStore();
const gameStore = useGameStore();

onMounted(() => {
  if (confetti.value === undefined) {
    throw Error('Confetti html element not found');
  }

  confettiAnimation.value = Lottie.loadAnimation({
    container: confetti.value,
    renderer: 'svg',
    autoplay: false,
    loop: false,
    path: 'https://assets10.lottiefiles.com/packages/lf20_wgcqrpue.json',
  });
});

watch(() => countdownStore.isRunning, (countdownIsRunning) => {
  if (countdownIsRunning || confettiAnimation.value === undefined) {
    return;
  }

  const playersWithCard = gameStore.players.filter((player) => player.card !== null);
  if (playersWithCard.length < 3) {
    return;
  }

  const hasEveryoneSameCard = playersWithCard.every(
    (player) => player.card === playersWithCard[0].card,
  );

  if (hasEveryoneSameCard) {
    confettiAnimation.value.goToAndPlay(0, false);
  }
});
</script>

<template>
  <div v-show="!confettiAnimation?.isPaused">
    <div
      ref="confetti"
      style="height: 30rem; width: 30rem;"
    />
  </div>
</template>
