import { defineStore } from 'pinia';
import { computed, readonly, ref } from 'vue';

export const useCountdownStore = defineStore('countdown', () => {
  const countdown = ref<number>();

  const countDownFrom = (num: number) => {
    if (num === 0) {
      // done
      countdown.value = undefined;

      return;
    }

    countdown.value = num;
    setTimeout(() => {
      countDownFrom(num - 1);
    }, 500);
  };

  const isRunning = computed(() => countdown.value !== undefined);

  return {
    countdown: readonly(countdown),
    isRunning,
    countDownFrom,
  };
});
