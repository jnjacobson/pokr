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
      'cursor-default': showLinkCopySuccess,
    }"
    class="py-2 rounded-md transition duration-75 font-semibold text-button-text bg-button-bg hover:button-bg-hover"
    type="button"
    style="width: 144px"
    @click="!showLinkCopySuccess && copyInviteLink()"
    v-text="showLinkCopySuccess ? 'Link copied!' : 'Copy invite link'"
  />
</template>
