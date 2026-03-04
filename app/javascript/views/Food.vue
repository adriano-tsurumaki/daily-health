<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useFoodStore } from '@/stores/food'
import { useAuthStore } from '@/stores/auth'
import { Button } from '@/components/ui/button'
import { Alert, AlertDescription } from '@/components/ui/alert'
import {
  Table, TableHeader, TableBody, TableRow, TableHead, TableCell
} from '@/components/ui/table'

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
  <div class="max-w-4xl mx-auto px-4">
    <header class="flex items-center justify-between py-4 border-b border-border mb-8">
      <h1 class="text-2xl font-bold text-primary m-0">Daily Health</h1>
      <nav class="flex gap-3 items-center">
        <Button as-child>
          <RouterLink :to="{ name: 'food-new' }">+ Novo Alimento</RouterLink>
        </Button>
        <Button variant="secondary" @click="handleLogout" :disabled="authStore.loading">
          {{ authStore.loading ? 'Saindo...' : 'Sair' }}
        </Button>
      </nav>
    </header>

    <main>
      <h2 class="text-xl font-semibold mb-6">Meus Alimentos</h2>

      <div v-if="foodStore.loading" class="text-center py-8 text-muted-foreground">Carregando...</div>

      <Alert v-else-if="foodStore.error" variant="destructive">
        <AlertDescription>{{ foodStore.error }}</AlertDescription>
      </Alert>

      <div v-else-if="foodStore.items.length === 0" class="text-center py-8 text-muted-foreground">
        Nenhum alimento cadastrado ainda.
      </div>

      <div v-else class="overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Nome</TableHead>
              <TableHead>Marca</TableHead>
              <TableHead>Unidade</TableHead>
              <TableHead>Calorias</TableHead>
              <TableHead>Prot</TableHead>
              <TableHead>Carbo</TableHead>
              <TableHead>Gord</TableHead>
              <TableHead class="text-right">Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="item in foodStore.items" :key="item.id">
              <TableCell>{{ item.name }}</TableCell>
              <TableCell>{{ item.brand ?? '-' }}</TableCell>
              <TableCell>{{ item.default_unit }}</TableCell>
              <TableCell>{{ item.food_nutrition?.calories ?? '-' }}</TableCell>
              <TableCell>{{ item.food_nutrition?.protein ?? '-' }}</TableCell>
              <TableCell>{{ item.food_nutrition?.carbo ?? '-' }}</TableCell>
              <TableCell>{{ item.food_nutrition?.fat ?? '-' }}</TableCell>
              <TableCell class="text-right whitespace-nowrap">
                <Button variant="link" as-child class="p-0 h-auto mr-3">
                  <RouterLink :to="{ name: 'food-edit', params: { id: item.id } }">Editar</RouterLink>
                </Button>
                <Button variant="link" class="p-0 h-auto text-destructive" @click="handleDelete(item.id)" :disabled="foodStore.loading">
                  Remover
                </Button>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </main>
  </div>
</template>
