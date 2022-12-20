<script setup lang="ts">
import Card from './Card.vue';

import type { Player } from '@/types';

defineProps<{
  player: Player,
  cardRevealed: boolean,
  isMyPlayer: boolean,
}>();
</script>

<template>
  <div class="space-y-1.5 w-28">
    <Card
      :card="player.card"
      :revealed="cardRevealed"
    />

    <div
      :class="{
        'opacity-60': cardRevealed && player.card === null,
        'text-blue-700 dark:text-blue-400': isMyPlayer,
      }"
      class="font-semibold break-words"
      v-text="player.name ?? 'unknown'"
    />
  </div>
</template>
