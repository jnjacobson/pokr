<script setup lang="ts">
import { ref } from 'vue';

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
  <button
    :class="{
        'bg-blue-600 dark:bg-blue-200 dark:hover:bg-blue-300 hover:bg-blue-700': !showLinkCopySuccess,
        'bg-green-600 dark:bg-green-300 cursor-default': showLinkCopySuccess,
      }"
    class="py-2 rounded-md transition duration-75 font-semibold text-white dark:text-gray-900"
    type="button"
    style="width: 144px"
    @click="!showLinkCopySuccess && copyInviteLink()"
    v-text="showLinkCopySuccess ? 'Link copied!' : 'Copy invite link'"
  />
</template>
