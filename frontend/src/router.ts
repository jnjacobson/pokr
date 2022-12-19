import { createRouter, createWebHistory } from 'vue-router'
import type { Game } from './types';

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/games/:gameId',
      name: 'Game',
      component: () => import('@/views/GameView.vue'),
      props: true,
    },
  ],
});

router.beforeEach(async (to) => {
  if (to.name === 'Game') {
    return undefined;
  }

  const response = await fetch(
    `${import.meta.env.VITE_BACKEND_API_URL}/games`,
    {
      method: 'POST',
    },
  );

  if (!response.ok) {
    throw new Error(response.statusText);
  }

  const { id } = (await response.json()) as Game;

  return `/games/${id}`;
});

export default router
