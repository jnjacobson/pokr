<script setup lang="ts">
import { onMounted } from 'vue';

import { Socket } from 'phoenix';

onMounted(() => {
  const url = `ws://${import.meta.env.VITE_BACKEND_URL}/socket`
  const socket = new Socket(url);

  socket.connect();

  const channel = socket.channel('game:test-id');

  channel.join();

  console.log({channel})
});
</script>

<template>
  <main>
    Hello
  </main>
</template>
