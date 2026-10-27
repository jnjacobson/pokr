<script setup lang="ts">
import Modal from '@/components/Modal.vue';
import { useGameStore } from '@/stores/useGameStore';

const gameStore = useGameStore();
</script>

<template>
  <Modal :show="gameStore.isSessionReplaced">
    <h1 class="text-xl font-medium mb-5">
      Hello again!
    </h1>

    <p>
      You have joined this game in another tab or window. This connection has been closed to prevent conflicts.
    </p>

    <template #actions>
      <p class="text-center text-gray-600 dark:text-gray-400">
        You can close this tab now.
      </p>
    </template>
  </Modal>
</template>
