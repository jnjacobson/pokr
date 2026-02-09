<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { toDataURL } from 'qrcode';

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
    @close="showModal = false"
  >
    <div class="flex flex-col items-center">
      <div class="rounded-lg bg-white dark:bg-gray-800 p-3 pb-2 text-center mb-5">
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

      <div class="flex items-center gap-3">
        <CopyInviteLinkButton />
        <button
          class="px-4 py-2 rounded-md transition duration-7 text-blue-600 dark:text-blue-400 font-semibold hover:bg-blue-200 dark:hover:bg-gray-800"
          type="button"
          @click="showModal = false"
        >
          Close
        </button>
      </div>
    </div>
  </Modal>

  <button
    class="px-4 rounded-md transition duration-75 font-semibold text-white dark:text-gray-900 bg-blue-600 hover:bg-blue-700 dark:bg-blue-200 dark:hover:bg-blue-300"
    type="button"
    @click="showModal = true"
  >
    Share
  </button>
</template>
