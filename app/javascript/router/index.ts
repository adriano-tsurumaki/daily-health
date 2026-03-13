import { createRouter, createWebHistory } from 'vue-router'
import { getStoredToken } from '@services/auth'

const routes = [
  { path: '/', name: 'home', component: () => import('../views/HomePage.vue') },
  { path: '/login', name: 'login', component: () => import('../views/auth/UserLogin.vue') },
  {
    path: '/forgot-password',
    name: 'forgot-password',
    component: () => import('../views/auth/ForgotPassword.vue'),
  },
  {
    path: '/reset-password',
    name: 'reset-password',
    component: () => import('../views/auth/ResetPassword.vue'),
  },
  {
    path: '/',
    component: () => import('../layouts/AppLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: 'food',
        name: 'food',
        component: () => import('../views/FoodList.vue'),
      },
      {
        path: 'food/new',
        name: 'food-new',
        component: () => import('../views/FoodForm.vue'),
      },
      {
        path: 'food/:id/edit',
        name: 'food-edit',
        component: () => import('../views/FoodForm.vue'),
      },
      {
        path: 'finance',
        name: 'finance',
        component: () => import('../views/FinanceDashboard.vue'),
      },
      {
        path: 'finance/transactions/new',
        name: 'finance-transactions-new',
        component: () => import('../views/TransactionForm.vue'),
      },
      {
        path: 'finance/transactions/:id/edit',
        name: 'finance-transactions-edit',
        component: () => import('../views/TransactionForm.vue'),
      },
      {
        path: 'finance/categories',
        name: 'finance-categories',
        component: () => import('../views/FinanceCategories.vue'),
      },
      {
        path: 'finance/tags',
        name: 'finance-tags',
        component: () => import('../views/FinanceTags.vue'),
      },
      {
        path: 'finance/payment-methods',
        name: 'finance-payment-methods',
        component: () => import('../views/PaymentMethods.vue'),
      },
      {
        path: 'settings',
        name: 'settings',
        component: () => import('../views/AppSettings.vue'),
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  if (to.meta.requiresAuth && !getStoredToken()) {
    return { name: 'login' }
  }
})

export default router
