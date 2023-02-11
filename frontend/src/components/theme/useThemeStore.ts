import { defineStore } from 'pinia';
import { ref, watch } from 'vue';

const THEME = {
  'classic-light': 'Pokr (light)',
  'classic-dark': 'Pokr (dark)',
  neubrutalism: 'Neubrutalism',
} as const;

export const useThemeStore = defineStore('theme', () => {
  const selectedTheme = ref(localStorage.getItem('theme') ?? 'classic-light');

  watch(selectedTheme, (value) => {
    localStorage.setItem('theme', value.toString());
  });

  return {
    selectedTheme,
    themes: Object.entries(THEME).map(([key, value]) => ({
      value: key,
      label: value,
    })),
  };
});
