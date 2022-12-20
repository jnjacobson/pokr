import { fileURLToPath, URL } from 'node:url';

import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import analyze from 'rollup-plugin-analyzer';

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
  build: {
    rollupOptions: {
      plugins: [
        analyze({
          summaryOnly: true,
          limit: 10,
        }),
      ],
    },
  },
});
