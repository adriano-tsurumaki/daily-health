import { createRouter, createWebHistory } from "vue-router"
import { getStoredToken } from "@/services/auth"

const routes = [
  { path: "/", name: "home", component: () => import("../views/Home.vue") },
  { path: "/login", name: "login", component: () => import("../views/Login.vue") },
  {
    path: "/food",
    name: "food",
    component: () => import("../views/Food.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/food/new",
    name: "food-new",
    component: () => import("../views/FoodForm.vue"),
    meta: { requiresAuth: true },
  },
  {
    path: "/food/:id/edit",
    name: "food-edit",
    component: () => import("../views/FoodForm.vue"),
    meta: { requiresAuth: true },
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  if (to.meta.requiresAuth && !getStoredToken()) {
    return { name: "login" }
  }
})

export default router
