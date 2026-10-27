<script setup lang="ts">
import { ref } from 'vue';

import ModalButton from '@/components/ModalButton.vue';

const showLinkCopySuccess = ref(false);

const copyInviteLink = async () => {
  await navigator.clipboard.writeText(window.location.href);

  showLinkCopySuccess.value = true;
  setTimeout(() => {
    showLinkCopySuccess.value = false;
  }, 2000);
};
</script>

<template>
  <ModalButton
    :variant="showLinkCopySuccess ? 'success' : 'primary'"
    @click="!showLinkCopySuccess && copyInviteLink()"
  >
    Copy invite link

    <template #success>
      Link copied!
    </template>
  </ModalButton>
</template>
