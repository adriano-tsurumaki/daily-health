<script setup lang="ts">
  import { onMounted } from 'vue'
  import { useI18n } from 'vue-i18n'
  import { useFoodStore } from '@stores/food'
  import { Button } from '@components/ui/button'
  import { Alert, AlertDescription } from '@components/ui/alert'
  import {
    Table,
    TableHeader,
    TableBody,
    TableRow,
    TableHead,
    TableCell,
  } from '@components/ui/table'

  const { t } = useI18n()
  const foodStore = useFoodStore()

  onMounted(() => {
    foodStore.loadItems()
  })

  async function handleDelete(id: number) {
    if (!confirm(t('FOOD.CONFIRM_DELETE'))) return
    await foodStore.remove(id)
  }
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">
        {{ t('FOOD.TITLE') }}
      </h1>
      <Button as-child>
        <RouterLink :to="{ name: 'food-new' }">
          {{ t('FOOD.NEW') }}
        </RouterLink>
      </Button>
    </div>

    <div v-if="foodStore.loading" class="text-center py-8 text-muted-foreground">
      {{ t('FOOD.LOADING') }}
    </div>

    <Alert v-else-if="foodStore.error" variant="destructive">
      <AlertDescription>{{ foodStore.error }}</AlertDescription>
    </Alert>

    <div v-else-if="foodStore.items.length === 0" class="text-center py-8 text-muted-foreground">
      {{ t('FOOD.EMPTY') }}
    </div>

    <div v-else class="overflow-x-auto">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{{ t('FOOD.NAME') }}</TableHead>
            <TableHead>{{ t('FOOD.BRAND') }}</TableHead>
            <TableHead>{{ t('FOOD.UNIT') }}</TableHead>
            <TableHead>{{ t('FOOD.CALORIES') }}</TableHead>
            <TableHead>{{ t('FOOD.PROTEIN') }}</TableHead>
            <TableHead>{{ t('FOOD.CARBO') }}</TableHead>
            <TableHead>{{ t('FOOD.FAT') }}</TableHead>
            <TableHead class="text-right">
              {{ t('FOOD.ACTIONS') }}
            </TableHead>
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
                <RouterLink :to="{ name: 'food-edit', params: { id: item.id } }">
                  {{ t('FOOD.EDIT') }}
                </RouterLink>
              </Button>
              <Button
                variant="link"
                class="p-0 h-auto text-destructive"
                :disabled="foodStore.loading"
                @click="handleDelete(item.id)"
              >
                {{ t('FOOD.DELETE') }}
              </Button>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>
  </div>
</template>
