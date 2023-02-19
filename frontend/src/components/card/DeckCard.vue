<script setup lang="ts">
defineProps<{
  value: string,
  selected?: boolean,
  disabled?: boolean,
}>();
</script>

<template>
  <button
    :class="{
      'text-white dark:text-gray-900 -translate-y-1.5': selected,
      'border-gray-300 dark:border-gray-600 cursor-default': disabled,
      'border-blue-600 dark:border-blue-400': !disabled,
      'bg-blue-600 dark:bg-blue-400': selected && !disabled,
      'bg-gray-300 dark:bg-gray-600 dark:text-gray-900': selected && disabled,
      'text-gray-300 dark:text-gray-600': !selected && disabled,
      'text-blue-600 dark:text-blue-400 hover:-translate-y-1': !selected && !disabled,
    }"
    class="
      border-2 rounded-md w-11 h-16 text-xl font-semibold flex items-center justify-center
      mx-auto transition duration-150 ease-out
    "
    type="button"
  >
    {{ value }}
  </button>
</template>
