<script setup lang="ts">
import { ref } from 'vue';
import {useDarkModeStore} from "./useDarkModeStore";

const darkModeStore = useDarkModeStore();

const checkbox = ref<HTMLElement>();
</script>

<template>
  <div>
    <input
      ref="checkbox"
      class="py-2 px-3 rounded-md transition font-semibold text-white"
      type="checkbox"
      v-model="darkModeStore.isEnabled"
      hidden
    />
    <button
      class="text-2xl transition duration-75 hover:scale-125"
      @click="checkbox?.click()"
      v-text="darkModeStore.isEnabled ? '&#x1F315;' : '&#x2600;'"
    />
  </div>
</template>
