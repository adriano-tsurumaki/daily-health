<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { useFinanceStore } from '@/stores/finance'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Alert, AlertDescription } from '@/components/ui/alert'
import {
  Table, TableHeader, TableBody, TableRow, TableHead, TableCell
} from '@/components/ui/table'

const { t } = useI18n()
const store = useFinanceStore()

const newName = ref('')
const editingId = ref<number | null>(null)
const editingName = ref('')

function startEdit(id: number, name: string) {
  editingId.value = id
  editingName.value = name
}

function cancelEdit() {
  editingId.value = null
  editingName.value = ''
}

async function handleCreate() {
  if (!newName.value.trim()) return
  await store.addCategory({ name: newName.value.trim() })
  newName.value = ''
}

async function handleUpdate() {
  if (!editingId.value || !editingName.value.trim()) return
  await store.editCategory(editingId.value, { name: editingName.value.trim() })
  cancelEdit()
}

async function handleDelete(id: number) {
  if (!confirm(t('FINANCE.CONFIRM_DELETE'))) return
  await store.removeCategory(id)
}

onMounted(() => {
  store.loadCategories()
})
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">{{ t('FINANCE.CATEGORIES.TITLE') }}</h1>

    <Alert v-if="store.error" variant="destructive" class="mb-4">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <!-- Create form -->
    <form @submit.prevent="handleCreate" class="flex gap-2 mb-6">
      <Input v-model="newName" :placeholder="t('FINANCE.CATEGORIES.NAME')" class="max-w-xs" />
      <Button type="submit" :disabled="store.loading">{{ t('FINANCE.CATEGORIES.NEW') }}</Button>
    </form>

    <div v-if="store.loading" class="text-center py-8 text-muted-foreground">...</div>

    <div v-else-if="store.categories.length === 0" class="text-center py-8 text-muted-foreground">
      {{ t('FINANCE.CATEGORIES.NO_CATEGORIES') }}
    </div>

    <Table v-else>
      <TableHeader>
        <TableRow>
          <TableHead>{{ t('FINANCE.CATEGORIES.NAME') }}</TableHead>
          <TableHead class="text-right">{{ t('FINANCE.ACTIONS') }}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow v-for="cat in store.categories" :key="cat.id">
          <TableCell>
            <form v-if="editingId === cat.id" @submit.prevent="handleUpdate" class="flex gap-2">
              <Input v-model="editingName" class="max-w-xs" />
              <Button type="submit" size="sm">{{ t('FINANCE_FORM.SAVE') }}</Button>
              <Button type="button" variant="outline" size="sm" @click="cancelEdit">{{ t('FINANCE_FORM.CANCEL') }}</Button>
            </form>
            <span v-else>{{ cat.name }}</span>
          </TableCell>
          <TableCell class="text-right whitespace-nowrap" v-if="editingId !== cat.id">
            <Button variant="link" class="p-0 h-auto mr-3" @click="startEdit(cat.id, cat.name)">{{ t('FINANCE.EDIT') }}</Button>
            <Button variant="link" class="p-0 h-auto text-destructive" @click="handleDelete(cat.id)">{{ t('FINANCE.DELETE') }}</Button>
          </TableCell>
          <TableCell v-else />
        </TableRow>
      </TableBody>
    </Table>
  </div>
</template>
