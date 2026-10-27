<script setup lang="ts">
import Modal from '@/components/Modal.vue';
import BaseButton from '@/components/BaseButton.vue';
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

    <p>
      The link is wrong, or nobody has played this game for a week and it was cleaned up.
    </p>

    <template #actions>
      <BaseButton @click="startNewGame">
        Start a new game
      </BaseButton>
    </template>
  </Modal>
</template>
