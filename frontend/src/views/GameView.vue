<script setup lang="ts">
import { useGameStore } from '@/stores/useGameStore';
import { onMounted } from 'vue';

const props = defineProps<{
  gameId: string,
}>();

const gameStore = useGameStore();

onMounted(() => {
  if (!gameStore.isConnected) {
    gameStore.joinGame(props.gameId);
  }
})
</script>

<template>
  <main class="m-5 space-y-3">
    <h1 class="font-bold">
      {{ gameId }}
    </h1>

    <ul>
      <li>
        Status: {{ gameStore.isConnected ? 'connected' : 'offline' }}
      </li>
      <li>
        Cards: {{ gameStore.areCardsRevealed ? 'revealed' : 'hidden' }}
      </li>
    </ul>

    <div>
      <button
        class="px-3 py-2 border rounded hover:bg-gray-100"
        v-text="gameStore.areCardsRevealed ? 'Next voting' : 'Show cards'"
        @click="gameStore.areCardsRevealed ? gameStore.resetCards() : gameStore.revealCards()"
      />
    </div>

    <div>
      Players:
      <ul>
        <li
          v-for="player in gameStore.players"
        >
          {{ player.name }} {{ gameStore.areCardsRevealed ? player.card ?? 'None' : 'Hidden' }}
        </li>
      </ul>
    </div>

    <div class="flex space-x-3">
      <button
        v-for="card in gameStore.deck"
        :class="{'bg-gray-100': gameStore.myPlayer?.card === card}"
        class="px-3 py-2 border rounded hover:bg-gray-100"
        v-text="card"
        @click="gameStore.chooseCard(card)"
      />
    </div>
  </main>
</template>
