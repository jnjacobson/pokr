import { defineStore } from 'pinia';
import { ref, watch } from 'vue';

export const useDarkModeStore = defineStore('darkMode', () => {
  const isEnabled = ref((() => {
    const fromLocalStorage = localStorage.getItem('darkMode');

    if (fromLocalStorage === null) {
      // init from system scheme
      return window.matchMedia
        && window.matchMedia('(prefers-color-scheme: dark)').matches;
    }

    return fromLocalStorage === 'true';
  })());

  watch(isEnabled, (value) => {
    localStorage.setItem('darkMode', value.toString());
  });

  watch(isEnabled, (value) => {
    document.documentElement.classList[value ? 'add' : 'remove']('dark');
  }, { immediate: true });

  return {
    isEnabled,
  };
});
