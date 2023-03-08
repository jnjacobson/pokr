<script setup lang="ts">
import { computed } from 'vue';

import { useGameStore } from '@/stores/useGameStore';
import DeckCard from '@/components/card/DeckCard.vue';

const gameStore = useGameStore();

const disabled = computed(() => gameStore.areCardsRevealed);

const isCardSelected = (card: string) => (
  gameStore.myPlayer?.card === card
);

const selectCard = (card: string) => {
  const { myPlayer } = gameStore;
  if (myPlayer === undefined) {
    throw new Error('Player not defined');
  }

  if (myPlayer.card === card) {
    myPlayer.card = null;

    return;
  }

  myPlayer.card = card;
};
</script>

<template>
  <ol class="flex space-x-3 overflow-x-auto pt-1.5 -mt-1.5">
    <li
      v-for="card in gameStore.deck"
      :key="card"
    >
      <DeckCard
        :value="card"
        :disabled="disabled"
        :selected="isCardSelected(card)"
        @click="!disabled && selectCard(card)"
      />
    </li>
  </ol>
</template>
