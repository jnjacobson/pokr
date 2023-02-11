<script setup lang="ts">
import { useThemeStore } from './useThemeStore';

const themeStore = useThemeStore();
</script>

<template>
  <select
    class="py-2 px-3 rounded-md transition duration-75 font-semibold hover:bg-contrast text-link bg-background"
    v-model="themeStore.selectedTheme"
  >
    <option
      v-for="theme in themeStore.themes"
      :key="theme.value"
      :value="theme.value"
    >
      {{ theme.label }}
    </option>
  </select>
</template>
