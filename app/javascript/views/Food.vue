<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useFoodStore } from '@/stores/food'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const foodStore = useFoodStore()
const authStore = useAuthStore()

onMounted(() => {
  foodStore.loadItems()
})

async function handleDelete(id: number) {
  if (!confirm('Remover este alimento?')) return
  await foodStore.remove(id)
}

async function handleLogout() {
  await authStore.logout()
  router.push({ name: 'login' })
}
</script>

<template>
  <div class="app">
    <header class="app-header">
      <h1 class="app-logo">Daily Health</h1>
      <nav class="app-nav">
        <RouterLink :to="{ name: 'food-new' }" class="btn btn-primary">+ Novo Alimento</RouterLink>
        <button @click="handleLogout" :disabled="authStore.loading" class="btn btn-secondary">
          {{ authStore.loading ? 'Saindo...' : 'Sair' }}
        </button>
      </nav>
    </header>

    <main class="main-content">
      <h2>Meus Alimentos</h2>

      <div v-if="foodStore.loading" class="status-message">Carregando...</div>
      <div v-else-if="foodStore.error" class="status-message error">{{ foodStore.error }}</div>
      <div v-else-if="foodStore.items.length === 0" class="status-message empty">
        Nenhum alimento cadastrado ainda.
      </div>

      <div v-else class="table-wrapper">
        <table class="food-table">
          <thead>
            <tr>
              <th>Nome</th>
              <th>Marca</th>
              <th>Unidade</th>
              <th>Calorias</th>
              <th>Prot</th>
              <th>Carbo</th>
              <th>Gord</th>
              <th class="col-actions">Ações</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in foodStore.items" :key="item.id">
              <td>{{ item.name }}</td>
              <td>{{ item.brand ?? '-' }}</td>
              <td>{{ item.default_unit }}</td>
              <td>{{ item.food_nutrition?.calories ?? '-' }}</td>
              <td>{{ item.food_nutrition?.protein ?? '-' }}</td>
              <td>{{ item.food_nutrition?.carbo ?? '-' }}</td>
              <td>{{ item.food_nutrition?.fat ?? '-' }}</td>
              <td class="col-actions">
                <RouterLink :to="{ name: 'food-edit', params: { id: item.id } }" class="action-link">
                  Editar
                </RouterLink>
                <button @click="handleDelete(item.id)" class="action-btn danger" :disabled="foodStore.loading">
                  Remover
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </main>
  </div>
</template>

<style scoped>
.app {
  max-width: 960px;
  margin: 0 auto;
  padding: 0 1rem;
}

.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 0;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 2rem;
}

.app-logo {
  font-size: 1.5rem;
  font-weight: 700;
  color: #4f46e5;
  margin: 0;
}

.app-nav {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.btn {
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  border: none;
  transition: background-color 0.2s;
}

.btn-primary {
  background-color: #4f46e5;
  color: #fff;
}

.btn-primary:hover {
  background-color: #4338ca;
}

.btn-secondary {
  background-color: #f3f4f6;
  color: #374151;
}

.btn-secondary:hover {
  background-color: #e5e7eb;
}

.main-content h2 {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0 0 1.5rem;
}

.status-message {
  text-align: center;
  padding: 2rem;
  color: #6b7280;
  font-size: 0.95rem;
}

.status-message.error {
  color: #991b1b;
  background-color: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 8px;
}

.table-wrapper {
  overflow-x: auto;
}

.food-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.food-table th,
.food-table td {
  padding: 0.75rem 0.5rem;
  text-align: left;
  border-bottom: 1px solid #e5e7eb;
}

.food-table th {
  font-weight: 600;
  color: #6b7280;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.food-table tbody tr:hover {
  background-color: #f9fafb;
}

.col-actions {
  text-align: right;
  white-space: nowrap;
}

.action-link {
  color: #4f46e5;
  text-decoration: none;
  font-weight: 500;
  margin-right: 0.75rem;
}

.action-link:hover {
  text-decoration: underline;
}

.action-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 500;
  padding: 0;
}

.action-btn.danger {
  color: #dc2626;
}

.action-btn.danger:hover {
  text-decoration: underline;
}
</style>
