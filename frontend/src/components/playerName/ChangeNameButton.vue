<script setup lang="ts">
import { useGameStore } from '@/stores/useGameStore';
import { computed, ref, onMounted, watch } from 'vue';
import SetNameModal from './SetNameModal.vue';
import { usePlayerNameStore } from './usePlayerNameStore';

const playerNameStore = usePlayerNameStore();

const gameStore = useGameStore();

const showModal = ref(false);

onMounted(() => {
  if (playerNameStore.playerName === 'New Player') {
    showModal.value = true;
  }
})
</script>

<template>
  <SetNameModal
    v-model="playerNameStore.playerName"
    :show="showModal"
    @close="showModal = false"
  />

  <button
    v-if="(gameStore.myPlayer?.name ?? null) !== null"
    class="
      py-2 px-4 rounded-md transition duration-75 font-semibold
      dark:hover:bg-gray-800 hover:bg-gray-100 text-blue-700 dark:text-blue-400
    "
    @click="showModal = true"
  >
    {{ gameStore.myPlayer?.name }}
    &#x270F;
  </button>
</template>