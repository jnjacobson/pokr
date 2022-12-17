<script setup lang="ts">
import { ref, watch } from "vue";

const props = defineProps<{
  show: boolean,
}>();

const emit = defineEmits<{
  (event: 'close'): void,
}>();

const wrapper = ref<HTMLElement>();

watch(() => props.show, (show) => {
  const body = document.querySelector('body');
  if (body === null) {
    return;
  }

  if (!show) {
    setTimeout(() => {
      body.style.marginRight = '';
      body.classList.remove('overflow-hidden');
    }, 100)

    return;
  }

  body.style.marginRight = `${window.innerWidth - document.body.clientWidth}px`;
  body.classList.add('overflow-hidden');
  wrapper.value?.focus();
});
</script>

<template>
  <teleport to="#modal">
    <div
      ref="wrapper"
      class="fixed z-10 inset-0 overflow-y-auto focus:outline-none"
      :class="show ? 'pointer-events-auto' : 'pointer-events-none'"
      tabindex="-1"
      @keyup.esc.exact="emit('close')"
    >
      <div
        class="
          flex items-end justify-center min-h-screen
          pt-4 px-4 pb-20 text-center sm:block sm:p-0
        "
      >
        <!-- Background overlay -->
        <transition
          enter-active-class="ease-out duration-150"
          enter-from-class="opacity-0"
          enter-to-class="opacity-100"
          leave-active-class="ease-in duration-75"
          leave-from-class="opacity-100"
          leave-to-class="opacity-0"
        >
          <div
            v-if="show"
            class="fixed inset-0 transition-opacity"
            aria-hidden="true"
          >
            <div
              class="absolute inset-0 bg-gray-700/75"
              @click="emit('close')"
            />
          </div>
        </transition>

        <!-- Trick the browser into centering the modal contents. -->
        <span
          class="hidden sm:inline-block sm:align-middle sm:h-screen"
          aria-hidden="true"
        >&#8203;</span>

        <!-- Modal panel -->
        <transition
          enter-active-class="ease-out duration-150"
          enter-from-class="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
          enter-to-class="opacity-100 translate-y-0 sm:scale-100"
          leave-active-class="ease-in duration-75"
          leave-from-class="opacity-100 translate-y-0 sm:scale-100"
          leave-to-class="opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"
        >
          <div
            v-if="show"
            class="
              inline-block align-bottom bg-blue-100 dark:bg-gray-900 dark:text-blue-100 rounded-lg px-4 pt-5
              pb-4 text-left overflow-hidden shadow-xl transform sm:max-w-lg
              transition-all sm:my-8 sm:align-middle w-full sm:p-6
            "
            role="dialog"
            aria-modal="true"
          >
            <slot />
          </div>
        </transition>
      </div>
    </div>
  </teleport>
</template>
