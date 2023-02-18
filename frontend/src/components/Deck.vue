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
  <div class="flex space-x-3">
    <DeckCard
      v-for="card in gameStore.deck"
      :key="card"
      :value="card"
      :disabled="disabled"
      :selected="isCardSelected(card)"
      @click="!disabled && selectCard(card)"
    />
  </div>
</template>
