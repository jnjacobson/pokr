import { defineStore } from 'pinia';
import { ref, watch } from 'vue';

export const usePlayerNameStore = defineStore('playerName', () => {
  const playerName = ref(localStorage.getItem('playerName') ?? 'New Player');

  watch(playerName, (value) => {
    localStorage.setItem('playerName', value.toString());
  });

  return {
    playerName,
  };
});
