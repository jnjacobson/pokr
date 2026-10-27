<script setup lang="ts">
import type { Player } from '@/types';
import PlayerCard from '@/components/card/PlayerCard.vue';

defineProps<{
  player: Player,
  cardRevealed: boolean,
  own: boolean,
}>();
</script>

<template>
  <li class="space-y-1.5 w-20 md:w-28">
    <PlayerCard
      :value="player.card"
      :revealed="cardRevealed"
      :spectating="player.isSpectator"
    />

    <div
      :class="{
        'opacity-60': cardRevealed && player.card === null,
        'text-blue-700 dark:text-blue-400': own,
      }"
      class="font-semibold wrap-break-word"
      v-text="player.name ?? 'unknown'"
    />
  </li>
</template>
