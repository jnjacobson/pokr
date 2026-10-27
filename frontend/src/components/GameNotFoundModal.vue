<script setup lang="ts">
import Modal from '@/components/Modal.vue';
import { useGameStore } from '@/stores/useGameStore';

const gameStore = useGameStore();

// A full load, so the router creates a game and the store joins it from scratch.
const startNewGame = () => window.location.assign('/');
</script>

<template>
  <Modal :show="gameStore.isGameNotFound">
    <h1 class="text-xl font-medium mb-5">
      This game doesn't exist &#129335;
    </h1>

    <div class="space-y-4">
      <p>
        The link is wrong, or nobody has played this game for a week and it was cleaned up.
      </p>

      <div class="flex sm:justify-end">
        <button
          class="
            py-2 px-4 rounded-md shrink-0 bg-blue-600 hover:bg-blue-700
            dark:bg-blue-200 dark:hover:bg-blue-300 transition font-semibold
            text-white dark:text-gray-900 w-full sm:w-auto
          "
          type="button"
          @click="startNewGame"
        >
          Start a new game
        </button>
      </div>
    </div>
  </Modal>
</template>
