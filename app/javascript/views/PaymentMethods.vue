<script setup lang="ts">
import { onMounted, ref, reactive } from 'vue'
import { useI18n } from 'vue-i18n'
import { useFinanceStore } from '@/stores/finance'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { Alert, AlertDescription } from '@/components/ui/alert'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@/components/ui/select'
import {
  Table, TableHeader, TableBody, TableRow, TableHead, TableCell
} from '@/components/ui/table'

const { t } = useI18n()
const store = useFinanceStore()

const identifiers = ['unknown', 'credit_card', 'debit_card', 'cash', 'pix', 'boleto']

const newForm = reactive({ name: '', locale: 'pt_BR', identifier: 'unknown' })
const editingId = ref<number | null>(null)
const editForm = reactive({ name: '', locale: '', identifier: '' })

function startEdit(pm: { id: number; name: string; locale: string; identifier: string }) {
  editingId.value = pm.id
  editForm.name = pm.name
  editForm.locale = pm.locale
  editForm.identifier = pm.identifier
}

function cancelEdit() {
  editingId.value = null
}

async function handleCreate() {
  if (!newForm.name.trim()) return
  await store.addPaymentMethod({ ...newForm, name: newForm.name.trim() })
  newForm.name = ''
  newForm.identifier = 'unknown'
}

async function handleUpdate() {
  if (!editingId.value || !editForm.name.trim()) return
  await store.editPaymentMethod(editingId.value, { ...editForm, name: editForm.name.trim() })
  cancelEdit()
}

async function handleDelete(id: number) {
  if (!confirm(t('FINANCE.CONFIRM_DELETE'))) return
  await store.removePaymentMethod(id)
}

onMounted(() => {
  store.loadPaymentMethods()
})
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">{{ t('FINANCE.PAYMENT_METHODS.TITLE') }}</h1>

    <Alert v-if="store.error" variant="destructive" class="mb-4">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <!-- Create form -->
    <form @submit.prevent="handleCreate" class="flex gap-2 mb-6 items-end">
      <div class="space-y-1">
        <Label class="text-xs">{{ t('FINANCE.PAYMENT_METHODS.NAME') }}</Label>
        <Input v-model="newForm.name" :placeholder="t('FINANCE.PAYMENT_METHODS.NAME')" />
      </div>
      <div class="space-y-1">
        <Label class="text-xs">{{ t('FINANCE.PAYMENT_METHODS.IDENTIFIER') }}</Label>
        <Select v-model="newForm.identifier">
          <SelectTrigger class="w-40">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem v-for="id in identifiers" :key="id" :value="id">
              {{ t(`FINANCE.PAYMENT_METHODS.IDENTIFIERS.${id}`) }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>
      <Button type="submit" :disabled="store.loading">{{ t('FINANCE.PAYMENT_METHODS.NEW') }}</Button>
    </form>

    <div v-if="store.loading" class="text-center py-8 text-muted-foreground">...</div>

    <div v-else-if="store.paymentMethods.length === 0" class="text-center py-8 text-muted-foreground">
      {{ t('FINANCE.PAYMENT_METHODS.NO_METHODS') }}
    </div>

    <Table v-else>
      <TableHeader>
        <TableRow>
          <TableHead>{{ t('FINANCE.PAYMENT_METHODS.NAME') }}</TableHead>
          <TableHead>{{ t('FINANCE.PAYMENT_METHODS.IDENTIFIER') }}</TableHead>
          <TableHead class="text-right">{{ t('FINANCE.ACTIONS') }}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        <TableRow v-for="pm in store.paymentMethods" :key="pm.id">
          <TableCell>
            <div v-if="editingId === pm.id" class="flex gap-2">
              <Input v-model="editForm.name" class="max-w-xs" />
              <Select v-model="editForm.identifier">
                <SelectTrigger class="w-40">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem v-for="id in identifiers" :key="id" :value="id">
                    {{ t(`FINANCE.PAYMENT_METHODS.IDENTIFIERS.${id}`) }}
                  </SelectItem>
                </SelectContent>
              </Select>
              <Button size="sm" @click="handleUpdate">{{ t('FINANCE_FORM.SAVE') }}</Button>
              <Button variant="outline" size="sm" @click="cancelEdit">{{ t('FINANCE_FORM.CANCEL') }}</Button>
            </div>
            <span v-else>{{ pm.name }}</span>
          </TableCell>
          <TableCell v-if="editingId !== pm.id">
            <Badge variant="outline">{{ t(`FINANCE.PAYMENT_METHODS.IDENTIFIERS.${pm.identifier}`) }}</Badge>
          </TableCell>
          <TableCell v-else />
          <TableCell class="text-right whitespace-nowrap" v-if="editingId !== pm.id">
            <Button variant="link" class="p-0 h-auto mr-3" @click="startEdit(pm)">{{ t('FINANCE.EDIT') }}</Button>
            <Button variant="link" class="p-0 h-auto text-destructive" @click="handleDelete(pm.id)">{{ t('FINANCE.DELETE') }}</Button>
          </TableCell>
          <TableCell v-else />
        </TableRow>
      </TableBody>
    </Table>
  </div>
</template>
