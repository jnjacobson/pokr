import { defineStore } from 'pinia';
import { useLocalStorage } from '@vueuse/core';

export const usePlayerSettingsStore = defineStore('playerSettings', () => {
  const playerName = useLocalStorage('playerName', 'New Player');
  const isSpectator = useLocalStorage('isSpectator', false);
  const hasSeenSpectatorOption = useLocalStorage('spectatorOptionSeen', false);

  return {
    playerName,
    isSpectator,
    hasSeenSpectatorOption,
  };
});
