<script setup lang="ts">
import { computed } from 'vue';

import { DECK_PRESETS } from '@/decks';
import { useGameStore } from '@/stores/useGameStore';

const gameStore = useGameStore();

// A deck that is no preset has no option, so the select shows nothing until another deck is picked.
const selectedName = computed(() => (
  DECK_PRESETS.find(({ cards }) => cards.join() === gameStore.deck.join())?.name ?? ''
));

const onChange = (event: Event) => {
  const preset = DECK_PRESETS.find(({ name }) => name === (event.target as HTMLSelectElement).value);

  if (preset !== undefined) {
    gameStore.changeDeck(preset.cards);
  }
};
</script>

<template>
  <label class="inline-flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
    Deck
    <select
      :value="selectedName"
      class="
        rounded-md border-2 border-blue-600 dark:border-blue-400 bg-white dark:bg-gray-900
        text-blue-600 dark:text-blue-400 px-2 py-1 cursor-pointer
      "
      @change="onChange"
    >
      <option
        v-for="{ name } in DECK_PRESETS"
        :key="name"
        :value="name"
      >
        {{ name }}
      </option>
    </select>
  </label>
</template>
