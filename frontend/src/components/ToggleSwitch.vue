<script setup lang="ts">
const model = defineModel<boolean>({ required: true });
</script>

<template>
  <label
    class="
      flex items-center gap-4 text-left cursor-pointer rounded-md -mx-2 px-2 py-1
      has-focus-visible:ring-2 ring-blue-500 dark:ring-blue-200
    "
  >
    <input
      v-model="model"
      class="peer sr-only"
      type="checkbox"
    />
    <span
      class="
        relative shrink-0 w-11 h-6 rounded-full transition bg-gray-300 dark:bg-gray-600
        peer-checked:bg-blue-600 dark:peer-checked:bg-blue-200
        after:absolute after:top-0.5 after:left-0.5 after:w-5 after:h-5 after:rounded-full
        after:bg-white dark:after:bg-gray-200 dark:peer-checked:after:bg-gray-900
        after:transition-transform
        peer-checked:after:translate-x-5
      "
      aria-hidden="true"
    />

    <span class="grow">
      <span class="block">
        <slot />
      </span>
      <span
        v-if="$slots.description"
        class="block text-sm text-gray-500 dark:text-gray-400"
      >
        <slot name="description" />
      </span>
    </span>
  </label>
</template>
