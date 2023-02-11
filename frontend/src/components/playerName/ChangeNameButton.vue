<script setup lang="ts">
import { ref, onMounted } from 'vue';

import SetNameModal from './SetNameModal.vue';
import { usePlayerNameStore } from './usePlayerNameStore';

import { useGameStore } from '@/stores/useGameStore';

const playerNameStore = usePlayerNameStore();

const gameStore = useGameStore();

const showModal = ref(false);

onMounted(() => {
  if (playerNameStore.playerName === 'New Player') {
    showModal.value = true;
  }
});
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
      py-2 px-4 rounded-md transition duration-75 font-semibold hover:bg-contrast text-link
    "
    type="button"
    @click="showModal = true"
  >
    {{ gameStore.myPlayer?.name }}
    &#x270F;
  </button>
</template>
