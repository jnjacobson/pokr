import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/games/:gameId',
      component: () => import('@/views/GameView.vue'),
      props: true,
    },
  ],
});

export default router
