<script setup lang="ts">
import { ref, onMounted } from 'vue';

import PlayerSettingsModal from './PlayerSettingsModal.vue';
import { usePlayerSettingsStore } from './usePlayerSettingsStore';

import { useGameStore } from '@/stores/useGameStore';

const playerSettingsStore = usePlayerSettingsStore();

const gameStore = useGameStore();

const showModal = ref(false);

onMounted(() => {
  // Everyone sees the modal once more, so that existing players learn about the spectator option.
  if (playerSettingsStore.playerName === 'New Player' || !playerSettingsStore.hasSeenSpectatorOption) {
    showModal.value = true;
  }
});
</script>

<template>
  <PlayerSettingsModal
    :show="showModal"
    @close="showModal = false"
  />

  <button
    v-if="(gameStore.myPlayer?.name ?? null) !== null"
    class="
      py-2 px-4 rounded-md transition duration-75 font-semibold
      dark:hover:bg-gray-800 hover:bg-gray-100 text-blue-700 dark:text-blue-400
    "
    type="button"
    @click="showModal = true"
  >
    {{ gameStore.myPlayer?.name }}
    &#x270F;
  </button>
</template>
