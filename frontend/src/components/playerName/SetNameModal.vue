<script setup lang="ts">
import {
  computed,
  nextTick,
  ref,
  watch,
} from 'vue';

import Modal from '@/components/Modal.vue';

const props = defineProps<{
  modelValue: string,
  show: boolean,
}>();

const emit = defineEmits<{
  (event: 'update:modelValue', value: string): void
  (event: 'close'): void
}>();

const newPlayerName = ref(props.modelValue);
const nameInput = ref<HTMLInputElement | null>(null);

const isNameValid = computed(
  () => newPlayerName.value.length === 0 || newPlayerName.value.length > 24,
)

watch(() => props.show, () => {
  newPlayerName.value = props.modelValue;

  nextTick(() => {
    nameInput.value?.focus();
    nameInput.value?.select();
  });
});

const setName = () => {
  if (isNameValid.value) {
    return;
  }

  emit('update:modelValue', newPlayerName.value);
  emit('close');
};
</script>

<template>
  <Modal
    :show="show"
    @close="emit('close')"
  >
    <h1 class="text-xl font-medium mb-5">
      Hello there! &#128075;
    </h1>

    <label
      for="name"
      class="block mb-2.5"
    >
      What's your name?
    </label>
    <form
      class="sm:flex sm:space-x-4 space-y-3 sm:space-y-0"
      @submit.prevent="setName"
    >
      <input
        id="name"
        ref="nameInput"
        v-model="newPlayerName"
        class="
          block w-full shadow-md rounded-md px-4 py-2 bg-gray-100
          dark:bg-gray-800 appearance-none focus:outline-none focus:ring-2
          dark:focus:ring-blue-200 focus:ring-blue-500 placeholder-gray-400
          dark:placeholder-gray-500
        "
        placeholder="Enter name..."
        autocomplete="name"
        type="text"
        maxlength="24"
      />
      <button
        :class="{
          'opacity-50 cursor-default': isNameValid,
          'hover:bg-blue-700 dark:hover:bg-blue-300': !isNameValid,
        }"
        class="
          py-2 px-4 rounded-md shrink-0 bg-blue-600
          dark:bg-blue-200 transition font-semibold
          text-white dark:text-gray-900 w-full sm:w-auto
        "
        type="submit"
      >
        Let's go!
      </button>
    </form>
  </Modal>
</template>
