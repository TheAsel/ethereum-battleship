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
      path: '/:pathMatch(.*)*',
      component: () => import('../views/ErrorView.vue')
    },
    {
      path: '/create',
      name: 'create',
      component: () => import('../views/CreateView.vue')
    },
    {
      path: '/waiting',
      name: 'waiting',
      component: () => import('../views/WaitingView.vue')
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
      path: '/game/',
      component: () => import('../views/GameView.vue'),
      children: [
        {
          path: 'deposit',
          name: 'deposit',
          component: () => import('../views/Game/DepositView.vue')
        },
        {
          path: 'placing',
          name: 'placing',
          component: () => import('../views/Game/PlacingView.vue')
        },
        {
          path: 'play',
          name: 'play',
          component: () => import('../views/Game/PlayView.vue')
        },
        {
          path: 'verify',
          name: 'verify',
          component: () => import('../views/Game/VerifyView.vue')
        },
        {
          path: 'withdraw',
          name: 'withdraw',
          component: () => import('../views/Game/WithdrawView.vue')
        }
      ]
    }
  ]
})

export default router
