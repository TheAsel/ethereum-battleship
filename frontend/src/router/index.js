import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('../views/HomeView.vue')
    },
    {
      path: '/create',
      name: 'create',
      component: () => import('../views/CreateView.vue')
    },
    {
      path: '/join',
      name: 'join',
      component: () => import('../views/JoinView.vue')
    },
    {
      path: '/acceptgame',
      name: 'acceptgame',
      component: () => import('../views/AcceptGameView.vue')
    },
    {
      path: '/waiting',
      name: 'waiting',
      component: () => import('../views/WaitingView.vue')
    },
    {
      path: '/placing',
      name: 'placing',
      component: () => import('../views/PlacingView.vue')
    },
    {
      path: '/play',
      name: 'play',
      component: () => import('../views/PlayView.vue')
    }
  ]
})

export default router
