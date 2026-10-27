<script setup lang="ts">
import {
  computed,
  nextTick,
  ref,
  watch,
} from 'vue';

import { usePlayerSettingsStore } from './usePlayerSettingsStore';

import Modal from '@/components/Modal.vue';
import ToggleSwitch from '@/components/ToggleSwitch.vue';

const props = defineProps<{
  show: boolean,
}>();

const emit = defineEmits<{ (event: 'close'): void }>();

const playerSettingsStore = usePlayerSettingsStore();

const newPlayerName = ref(playerSettingsStore.playerName);
const newSpectating = ref(playerSettingsStore.isSpectator);
const nameInput = ref<HTMLInputElement | null>(null);

const isNameInvalid = computed(
  () => newPlayerName.value.length === 0 || newPlayerName.value.length > 24,
);

watch(() => props.show, () => {
  newPlayerName.value = playerSettingsStore.playerName;
  newSpectating.value = playerSettingsStore.isSpectator;

  void nextTick(() => {
    nameInput.value?.focus();
    nameInput.value?.select();
  });
});

const close = () => {
  playerSettingsStore.hasSeenSpectatorOption = true;
  emit('close');
};

const submit = () => {
  if (isNameInvalid.value) {
    return;
  }

  playerSettingsStore.playerName = newPlayerName.value;
  playerSettingsStore.isSpectator = newSpectating.value;
  close();
};
</script>

<template>
  <Modal
    :show="show"
    @close="close"
  >
    <h1 class="text-xl font-medium mb-5">
      Hello there! &#128075;
    </h1>

    <form
      class="flex flex-col gap-4"
      @submit.prevent="submit"
    >
      <label>
        What's your name?

        <input
          ref="nameInput"
          v-model="newPlayerName"
          class="
            block w-full shadow-md rounded-md px-4 py-2 bg-gray-100
            dark:bg-gray-800 appearance-none focus:outline-none focus:ring-2
            dark:focus:ring-blue-200 focus:ring-blue-500 placeholder-gray-400
            dark:placeholder-gray-500 mt-2
          "
          placeholder="Enter name..."
          autocomplete="name"
          type="text"
          maxlength="24"
        />
      </label>

      <ToggleSwitch v-model="newSpectating">
        Just watching?

        <template #description>
          Spectators don't vote, but can still show the cards.
        </template>
      </ToggleSwitch>

      <button
        :class="{
          'opacity-50 cursor-default': isNameInvalid,
          'hover:bg-blue-700 dark:hover:bg-blue-300': !isNameInvalid,
        }"
        class="
          py-2 px-4 rounded-md shrink-0 bg-blue-600
          dark:bg-blue-200 transition font-semibold
          text-white dark:text-gray-900 w-full
        "
        type="submit"
      >
        Let's go!
      </button>
    </form>
  </Modal>
</template>
