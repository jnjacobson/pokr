<script setup lang="ts">
import { RouterView } from 'vue-router';

import { useDarkModeStore } from '@/components/darkMode/useDarkModeStore';

const darkModeStore = useDarkModeStore();
</script>

<template>
  <div :class="darkModeStore.isEnabled ? 'dark' : 'bg-white'">
    <router-view />

    <div id="modal" />
  </div>
</template>
