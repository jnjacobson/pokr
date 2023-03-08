<script setup lang="ts">
import {
  computed, ref, onMounted,
} from 'vue';

import { useGameStore } from '@/stores/useGameStore';

type CardPlayerCountDict = {
  [card: string]: number,
};

const gameStore = useGameStore();

const cardPlayerCountDict = computed(() => gameStore.players.reduce((dict, player) => {
  if (player.card === null) {
    return dict;
  }

  if (dict[player.card] === undefined) {
    dict[player.card] = 0;
  }

  dict[player.card]++;

  return dict;
}, <CardPlayerCountDict>{}));

const totalPlayersWithCardCount = computed(() => (
  gameStore.players.filter(({ card }) => card !== null).length
));

const heightModifier = ref(0);

onMounted(() => {
  setTimeout(() => {
    heightModifier.value = 100;
  }, 50);
});
</script>

<template>
  <ol class="flex justify-center space-x-3 md:space-x-5">
    <li
      v-for="[card, count] in Object.entries(cardPlayerCountDict)"
      :key="card"
      class="space-y-3 w-11 flex flex-col items-center"
    >
      <div class="m-auto relative w-2.5 rounded-full h-16 bg-gray-200 dark:bg-gray-800">
        <div
          class="
            absolute w-full rounded-full ease-out outline outline-2
            bottom-0 bg-gray-700 dark:bg-gray-300 outline-white dark:outline-gray-900
          "
          :style="`height: ${count / totalPlayersWithCardCount * heightModifier}%; transition: height .5s;`"
        />
      </div>

      <div
        class="
          border-2 border-gray-700 dark:border-gray-300 text-gray-700 dark:text-gray-300 rounded-md w-11 h-16
          flex items-center justify-center text-2xl font-semibold
        "
        type="button"
      >
        {{ card }}
      </div>
    </li>
  </ol>
</template>
