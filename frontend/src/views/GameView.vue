<script setup lang="ts">
import { onMounted, computed } from 'vue';

import ChangeNameButton from '@/components/playerName/ChangeNameButton.vue';
import CenterTable from '@/components/CenterTable.vue';
import Confetti from '@/components/Confetti.vue';
import CopyInviteLinkButton from '@/components/CopyInviteLinkButton.vue';
import DarkModeSwitch from '@/components/darkMode/DarkModeSwitch.vue';
import Deck from '@/components/Deck.vue';
import PlayerRow from '@/components/PlayerRow.vue';
import LoadingSpinner from '@/components/LoadingSpinner.vue';
import { useGameStore } from '@/stores/useGameStore';
import type { Player } from '@/types';

const props = defineProps<{
  gameId: string,
}>();

const gameStore = useGameStore();

onMounted(() => {
  if (!gameStore.isConnected) {
    gameStore.joinGame(props.gameId);
  }
});

const sortedPlayers = computed(() => (
  [...gameStore.players].sort((a: Player, b: Player) => (
    (a.name ?? '').localeCompare(b.name ?? '')
  ))
));

const evenPlayers = computed(() => (
  sortedPlayers.value.filter(
    (_: Player, index: number) => (index % 2) === 0,
  )
));
const oddPlayers = computed(() => (
  sortedPlayers.value.filter(
    (_: Player, index: number) => (index % 2) === 1,
  )
));
</script>

<template>
  <main class="h-screen w-screen relative py-10 md:py-20 px-5 dark:bg-gray-900 dark:text-blue-100">
    <transition
      enter-active-class="ease-out duration-100"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="ease-in duration-100"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <LoadingSpinner
        v-if="!gameStore.isConnected"
        class="absolute bottom-5 left-5"
      />

      <div
        v-else
        class="flex flex-col items-center text-center h-full space-y-6"
      >
        <div class="grow flex flex-col items-center justify-center text-center space-y-6 relative w-full">
          <Confetti
            class="
              absolute pointer-events-none bottom-0 top-0
              right-0 left-0 flex justify-center items-center z-50
            "
          />

          <div class="flex-1 flex items-end max-w-full overflow-x-auto">
            <PlayerRow :players="oddPlayers" />
          </div>

          <CenterTable />

          <div class="flex-1 max-w-full overflow-x-auto">
            <PlayerRow :players="evenPlayers" />
          </div>
        </div>

        <div class="max-w-full">
          <p
            :class="gameStore.areCardsRevealed && 'opacity-40'"
            class="mb-6"
          >
            Choose your card &#128071;
          </p>

          <Deck />
        </div>
      </div>
    </transition>

    <div class="absolute top-5 left-5 flex space-x-3">
      <CopyInviteLinkButton />
      <ChangeNameButton />
    </div>
    <DarkModeSwitch class="absolute top-5 right-5" />
  </main>
</template>
