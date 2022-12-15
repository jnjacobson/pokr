<script setup lang="ts">
import { onMounted, ref } from 'vue';

import { Channel, Socket } from 'phoenix';

const name = ref<string>();
const gameId = ref<string>();

let socket: Socket;
let channel: Channel;

const joinGame = () => {
  const url = `ws://${import.meta.env.VITE_BACKEND_URL}/socket`
  socket = new Socket(url);

  socket.connect();

  console.log({socket});

  channel = socket.channel(`game:${gameId.value}`);

  channel.join();
  channel.push('player_updated', {
    name: name.value,
  });

  channel.on('join', (payload) => {
    console.log('my id is ' + payload.id);
  });
  channel.on('player_updated', (payload) => {
    console.log(payload);
  })
  channel.on('player_left', () => {
    console.log('bye boy');
  })
};

const leaveGame = () => {
  channel?.leave();
}
</script>

<template>
  <main>
    <div class="flex space-x-3 items-end">
      <label class="flex flex-col">
        GameId
        <input
        v-model="gameId"
        class="bg-gray-200 py-2 px-3"
      />
      </label>
      <label class="flex flex-col">
        Name
        <input
        v-model="name"
        class="bg-gray-200 py-2 px-3"
      />
      </label>
      <button
        class="bg-blue-500 hover:bg-blue-600 text-white py-2 px-3"
        @click="joinGame()"
      >
        Join
      </button>
      <button
        class="bg-blue-500 hover:bg-blue-600 text-white py-2 px-3"
        @click="leaveGame()"
      >
        Leave
      </button>
    </div>
  </main>
</template>
