<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { toDataURL } from 'qrcode';

import BaseButton from '@/components/BaseButton.vue';
import Modal from '@/components/Modal.vue';
import { useGameStore } from '@/stores/useGameStore';
import { useDarkModeStore } from '@/components/darkMode/useDarkModeStore';
import CopyInviteLinkButton from '@/components/CopyInviteLinkButton.vue';

const showModal = ref(false);
const inviteUrl = ref('');
const qrImageUrl = ref('');
const isGenerating = ref(false);

const darkModeStore = useDarkModeStore();

watch(() => darkModeStore.isEnabled, () => {
  void generateQrCode();
});

async function generateQrCode() {
  if (!inviteUrl.value) {
    return;
  }

  isGenerating.value = true;
  try {
    qrImageUrl.value = await toDataURL(inviteUrl.value, {
      width: 220,
      margin: 1,
      color: {
        dark: darkModeStore.isEnabled ? '#bedbff' : '#1447e6',
        light: darkModeStore.isEnabled ? '#1e2939' : '#ffffff',
      },
    });
  } finally {
    isGenerating.value = false;
  }
}

const gameStore = useGameStore();

onMounted(() => {
  inviteUrl.value = window.location.href;
});

watch(showModal, (isOpen) => {
  if (isOpen) {
    void generateQrCode();
  }
});
</script>

<template>
  <Modal
    :show="showModal"
    closable
    @close="showModal = false"
  >
    <div class="flex flex-col items-center">
      <div class="rounded-lg bg-white dark:bg-gray-800 p-3 pb-2 text-center">
        <img
          v-if="qrImageUrl"
          :src="qrImageUrl"
          alt="Invite QR code"
          class="h-56 w-56"
        >
        <div
          v-else
          class="h-48 w-48 rounded-md"
          :class="isGenerating ? 'animate-pulse bg-blue-200' : 'bg-blue-100'"
        />
        <span class="font-mono text-sm text-gray-600 dark:text-gray-400">{{ gameStore.gameId }}</span>
      </div>
    </div>

    <template #actions>
      <CopyInviteLinkButton />
    </template>
  </Modal>

  <BaseButton @click="showModal = true">
    Share
  </BaseButton>
</template>
