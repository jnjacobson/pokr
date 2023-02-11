<script setup lang="ts">
import { RouterView } from 'vue-router';

import { useThemeStore } from './components/theme/useThemeStore';

const themeStore = useThemeStore();
</script>

<template>
  <div :class="themeStore.selectedTheme">
    <router-view />

    <div id="modal" />
  </div>
</template>
