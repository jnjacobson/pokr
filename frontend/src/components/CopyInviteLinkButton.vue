<script setup lang="ts">
import { ref } from 'vue';

import BaseButton from '@/components/BaseButton.vue';

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
  <BaseButton
    :variant="showLinkCopySuccess ? 'success' : 'primary'"
    @click="!showLinkCopySuccess && copyInviteLink()"
  >
    Copy invite link

    <template #success>
      Link copied!
    </template>
  </BaseButton>
</template>
