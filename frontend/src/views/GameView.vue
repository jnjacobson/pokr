<script setup lang="ts">
import { useGameStore } from '@/stores/useGameStore';
import { onMounted } from 'vue';

const props = defineProps<{
  gameId: string,
}>();

const gameStore = useGameStore();

onMounted(() => {
  if (!gameStore.inGame) {
    gameStore.joinGame(props.gameId);
  }
})
</script>

<template>
  <main class="m-5 space-y-3">
    <ul>
      <li>
        Status: {{ gameStore.inGame ? 'connected' : 'offline' }}
      </li>
      <li>
        Cards: {{ gameStore.game.areCardsRevealed ? 'revealed' : 'hidden' }}
      </li>
    </ul>

    <div>
      <button
        v-text="gameStore.game.areCardsRevealed ? 'Next voting' : 'Show cards'"
        @click="gameStore.game.areCardsRevealed ? gameStore.resetCards() : gameStore.revealCards()"
      />
    </div>

    <div>
      Players:
      <ul>
        <li
          v-for="player in gameStore.players"
        >
          {{ player.name }}
        </li>
      </ul>
    </div>
  </main>
</template>
