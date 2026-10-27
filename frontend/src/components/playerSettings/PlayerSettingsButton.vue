<script setup lang="ts">
import { ref, onMounted } from 'vue';

import PlayerSettingsModal from './PlayerSettingsModal.vue';
import { usePlayerSettingsStore } from './usePlayerSettingsStore';

import BaseButton from '@/components/BaseButton.vue';
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

  <BaseButton
    v-if="(gameStore.myPlayer?.name ?? null) !== null"
    variant="secondary"
    @click="showModal = true"
  >
    {{ gameStore.myPlayer?.name }}
    &#x270F;
  </BaseButton>
</template>
