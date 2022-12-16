import { defineStore } from 'pinia';
import { ref, watch } from 'vue';

export const useDarkModeStore = defineStore('darkMode', () => {
  const isEnabled = ref(localStorage.getItem('darkMode') === 'true');

  watch(isEnabled, (value) => {
    localStorage.setItem('darkMode', value.toString());
  });

  return {
    isEnabled,
  };
});
