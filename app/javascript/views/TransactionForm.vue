<script setup lang="ts">
import { onMounted, ref, computed, reactive } from 'vue'
import { useI18n } from 'vue-i18n'
import { useRouter, useRoute } from 'vue-router'
import { useFinanceStore } from '@stores/finance'
import type { TransactionPayload, TransactionItemPayload } from '@services/finance'
import { Button } from '@components/ui/button'
import { Input } from '@components/ui/input'
import { Label } from '@components/ui/label'
import { Alert, AlertDescription } from '@components/ui/alert'
import { Badge } from '@components/ui/badge'
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue
} from '@components/ui/select'

const { t } = useI18n()
const router = useRouter()
const route = useRoute()
const store = useFinanceStore()

const isEdit = computed(() => !!route.params.id)
const transactionId = computed(() => Number(route.params.id))

const form = reactive({
  amount: 0,
  payment_date: new Date().toISOString().split('T')[0],
  transaction_type: 'expense',
  status: 'pending',
  payment_method_id: 0,
  category_id: null as number | null,
  tag_ids: [] as number[],
  items: [] as TransactionItemPayload[],
})

const saving = ref(false)
const formError = ref<string | null>(null)

const transactionTypes = ['expense', 'income', 'transfer', 'refund']
const statuses = ['pending', 'paid', 'cancelled', 'failed', 'expired']

function addItem() {
  form.items.push({ name: '', quantity: 1, unit_of_measure: 'un', unit_price: 0 })
}

function removeItem(index: number) {
  const item = form.items[index]
  if (item.id) {
    item._destroy = true
  } else {
    form.items.splice(index, 1)
  }
}

function toggleTag(tagId: number) {
  const idx = form.tag_ids.indexOf(tagId)
  if (idx === -1) {
    form.tag_ids.push(tagId)
  } else {
    form.tag_ids.splice(idx, 1)
  }
}

async function handleSubmit() {
  saving.value = true
  formError.value = null

  const payload: TransactionPayload = {
    amount: form.amount,
    payment_date: form.payment_date,
    transaction_type: form.transaction_type,
    status: form.status,
    payment_method_id: form.payment_method_id,
    category_id: form.category_id,
    tag_ids: form.tag_ids,
    transaction_items_attributes: form.items,
  }

  try {
    if (isEdit.value) {
      await store.editTransaction(transactionId.value, payload)
    } else {
      await store.addTransaction(payload)
    }
    router.push({ name: 'finance' })
  } catch (e: unknown) {
    formError.value = e instanceof Error ? e.message : t('ERRORS.UNKNOWN')
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  await Promise.all([
    store.loadCategories(),
    store.loadTags(),
    store.loadPaymentMethods(),
  ])

  if (isEdit.value) {
    const tx = await store.loadTransaction(transactionId.value)
    form.amount = tx.amount
    form.payment_date = tx.payment_date.split('T')[0]
    form.transaction_type = tx.transaction_type
    form.status = tx.status
    form.payment_method_id = tx.payment_method?.id ?? 0
    form.category_id = tx.category?.id ?? null
    form.tag_ids = tx.tags.map(t => t.id)
    form.items = tx.transaction_items.map(i => ({
      id: i.id,
      name: i.name,
      quantity: i.quantity,
      unit_of_measure: i.unit_of_measure,
      unit_price: i.unit_price,
    }))
  }
})
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">
      {{ isEdit ? t('FINANCE_FORM.EDIT_TITLE') : t('FINANCE_FORM.NEW_TITLE') }}
    </h1>

    <Alert v-if="formError" variant="destructive" class="mb-4">
      <AlertDescription>{{ formError }}</AlertDescription>
    </Alert>

    <form @submit.prevent="handleSubmit" class="space-y-6 max-w-2xl">
      <!-- Amount & Date -->
      <div class="grid grid-cols-2 gap-4">
        <div class="space-y-2">
          <Label>{{ t('FINANCE_FORM.AMOUNT') }}</Label>
          <Input v-model.number="form.amount" type="number" step="0.01" :placeholder="t('FINANCE_FORM.AMOUNT_PLACEHOLDER')" required />
        </div>
        <div class="space-y-2">
          <Label>{{ t('FINANCE_FORM.PAYMENT_DATE') }}</Label>
          <Input v-model="form.payment_date" type="date" required />
        </div>
      </div>

      <!-- Type & Status -->
      <div class="grid grid-cols-2 gap-4">
        <div class="space-y-2">
          <Label>{{ t('FINANCE_FORM.TRANSACTION_TYPE') }}</Label>
          <Select v-model="form.transaction_type">
            <SelectTrigger>
              <SelectValue :placeholder="t('FINANCE_FORM.SELECT_TYPE')" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="tt in transactionTypes" :key="tt" :value="tt">
                {{ t(`FINANCE.TYPES.${tt}`) }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div class="space-y-2">
          <Label>{{ t('FINANCE_FORM.STATUS') }}</Label>
          <Select v-model="form.status">
            <SelectTrigger>
              <SelectValue :placeholder="t('FINANCE_FORM.SELECT_STATUS')" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="s in statuses" :key="s" :value="s">
                {{ t(`FINANCE.STATUSES.${s}`) }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <!-- Payment Method & Category -->
      <div class="grid grid-cols-2 gap-4">
        <div class="space-y-2">
          <Label>{{ t('FINANCE_FORM.PAYMENT_METHOD') }}</Label>
          <Select v-model="form.payment_method_id">
            <SelectTrigger>
              <SelectValue :placeholder="t('FINANCE_FORM.SELECT_PAYMENT_METHOD')" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="pm in store.paymentMethods" :key="pm.id" :value="pm.id">
                {{ pm.name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div class="space-y-2">
          <Label>{{ t('FINANCE_FORM.CATEGORY_OPTIONAL') }}</Label>
          <Select v-model="form.category_id">
            <SelectTrigger>
              <SelectValue :placeholder="t('FINANCE_FORM.SELECT_CATEGORY')" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem :value="null">{{ t('FINANCE_FORM.NONE') }}</SelectItem>
              <SelectItem v-for="cat in store.categories" :key="cat.id" :value="cat.id">
                {{ cat.name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <!-- Tags -->
      <div class="space-y-2">
        <Label>{{ t('FINANCE_FORM.TAGS') }}</Label>
        <div class="flex flex-wrap gap-2">
          <Badge
            v-for="tag in store.tags" :key="tag.id"
            :variant="form.tag_ids.includes(tag.id) ? 'default' : 'outline'"
            class="cursor-pointer"
            @click="toggleTag(tag.id)"
          >
            {{ tag.name }}
          </Badge>
        </div>
      </div>

      <!-- Items -->
      <div class="space-y-3">
        <div class="flex items-center justify-between">
          <Label>{{ t('FINANCE_FORM.ITEMS') }}</Label>
          <Button type="button" variant="outline" size="sm" @click="addItem">
            {{ t('FINANCE_FORM.ADD_ITEM') }}
          </Button>
        </div>

        <div v-for="(item, index) in form.items" :key="index">
          <div v-if="!item._destroy" class="grid grid-cols-12 gap-2 items-end">
            <div class="col-span-4">
              <Label v-if="index === 0" class="text-xs">{{ t('FINANCE_FORM.ITEM_NAME') }}</Label>
              <Input v-model="item.name" :placeholder="t('FINANCE_FORM.ITEM_NAME')" required />
            </div>
            <div class="col-span-2">
              <Label v-if="index === 0" class="text-xs">{{ t('FINANCE_FORM.ITEM_QUANTITY') }}</Label>
              <Input v-model.number="item.quantity" type="number" step="0.01" min="0.01" required />
            </div>
            <div class="col-span-2">
              <Label v-if="index === 0" class="text-xs">{{ t('FINANCE_FORM.ITEM_UNIT') }}</Label>
              <Input v-model="item.unit_of_measure" placeholder="un" required />
            </div>
            <div class="col-span-2">
              <Label v-if="index === 0" class="text-xs">{{ t('FINANCE_FORM.ITEM_PRICE') }}</Label>
              <Input v-model.number="item.unit_price" type="number" step="0.01" min="0" required />
            </div>
            <div class="col-span-2">
              <Button type="button" variant="destructive" size="sm" class="w-full" @click="removeItem(index)">
                {{ t('FINANCE_FORM.REMOVE_ITEM') }}
              </Button>
            </div>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="flex gap-3">
        <Button type="submit" :disabled="saving">
          {{ saving ? t('FINANCE_FORM.SAVING') : t('FINANCE_FORM.SAVE') }}
        </Button>
        <Button type="button" variant="outline" @click="router.push({ name: 'finance' })">
          {{ t('FINANCE_FORM.CANCEL') }}
        </Button>
      </div>
    </form>
  </div>
</template>
