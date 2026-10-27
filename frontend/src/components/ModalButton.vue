<script setup lang="ts">
withDefaults(defineProps<{
  variant?: 'primary' | 'secondary' | 'success',
}>(), {
  variant: 'primary',
});
</script>

<template>
  <button
    :class="{
      'text-white dark:text-gray-900': variant !== 'secondary',
      'bg-blue-600 enabled:hover:bg-blue-700 dark:bg-blue-200 dark:enabled:hover:bg-blue-300': variant === 'primary',
      'bg-green-600 dark:bg-green-300 cursor-default': variant === 'success',
      'text-blue-600 dark:text-blue-400 hover:bg-blue-200 dark:hover:bg-gray-800': variant === 'secondary',
    }"
    class="
      w-full py-2 px-4 rounded-md transition duration-75 font-semibold
      disabled:opacity-50 disabled:cursor-default
    "
    type="button"
  >
    <slot
      v-if="variant === 'success'"
      name="success"
    >
      <slot />
    </slot>
    <slot v-else />
  </button>
</template>
