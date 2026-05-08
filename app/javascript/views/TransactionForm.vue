<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRouter, useRoute } from 'vue-router';
import { useFinanceStore } from '@stores/finance';
import type { TransactionItemPayload, TransactionPayload } from '@services/finance';
import { Button } from '@components/ui/button';
import { Input } from '@components/ui/input';
import { Label } from '@components/ui/label';
import { Card } from '@components/ui/card';
import { Alert, AlertDescription } from '@components/ui/alert';
import { Badge } from '@components/ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@components/ui/select';

const { t } = useI18n();
const router = useRouter();
const route = useRoute();
const store = useFinanceStore();

const isEdit = computed(() => !!route.params.id);
const transactionId = computed(() => Number(route.params.id));

const form = reactive({
  amount: 0,
  description: '',
  merchant_name: '',
  payment_date: new Date().toISOString().slice(0, 10),
  due_date: '',
  transaction_type: 'expense',
  status: 'pending',
  payment_method_id: '',
  category_id: 'none',
  recurrence_id: 'none',
  tag_ids: [] as number[],
  items: [] as TransactionItemPayload[],
  installment_name: '',
  total_installments: '2',
  interval_in_months: '1'
});

const saving = ref(false);
const formError = ref<string | null>(null);
const showItems = ref(false);
const showInstallment = ref(false);
const showRecurrenceLink = ref(false);

const transactionTypes = ['expense', 'income', 'transfer', 'refund'];
const statuses = ['pending', 'paid', 'cancelled', 'failed', 'expired'];

function addItem() {
  showItems.value = true;
  form.items.push({ name: '', quantity: 1, unit_of_measure: 'un', unit_price: 0 });
}

function removeItem(index: number) {
  const item = form.items[index];

  if (item.id) {
    item._destroy = true;
  } else {
    form.items.splice(index, 1);
  }
}

function toggleTag(tagId: number) {
  const index = form.tag_ids.indexOf(tagId);

  if (index === -1) form.tag_ids.push(tagId);
  else form.tag_ids.splice(index, 1);
}

function buildPayload(): TransactionPayload {
  return {
    amount: form.amount,
    description: form.description.trim(),
    merchant_name: form.merchant_name.trim() || null,
    payment_date: form.payment_date,
    due_date: form.due_date || null,
    transaction_type: form.transaction_type,
    status: form.status,
    payment_method_id: Number(form.payment_method_id),
    category_id: form.category_id === 'none' ? null : Number(form.category_id),
    recurrence_id: showRecurrenceLink.value && form.recurrence_id !== 'none' ? Number(form.recurrence_id) : null,
    tag_ids: form.tag_ids,
    installment_plan_attributes:
      !isEdit.value && showInstallment.value
        ? {
            name: form.installment_name.trim() || form.description.trim(),
            total_installments: Number(form.total_installments),
            interval_in_months: Number(form.interval_in_months)
          }
        : undefined,
    transaction_items_attributes: showItems.value ? form.items : undefined
  };
}

async function handleSubmit() {
  saving.value = true;
  formError.value = null;

  const payload = buildPayload();
  const result = isEdit.value
    ? await store.editTransaction(transactionId.value, payload)
    : await store.addTransaction(payload);

  saving.value = false;

  if (!result) {
    formError.value = store.error;

    return;
  }

  router.push({ name: 'finance' });
}

onMounted(async () => {
  await Promise.all([store.loadCategories(), store.loadTags(), store.loadPaymentMethods(), store.loadRecurrences()]);

  if (!isEdit.value) return;

  const transaction = await store.loadTransaction(transactionId.value);

  if (!transaction) return;

  form.amount = transaction.amount;
  form.description = transaction.description;
  form.merchant_name = transaction.merchant_name ?? '';
  form.payment_date = transaction.payment_date.slice(0, 10);
  form.due_date = transaction.due_date ? transaction.due_date.slice(0, 10) : '';
  form.transaction_type = transaction.transaction_type;
  form.status = transaction.status;
  form.payment_method_id = transaction.payment_method?.id ? String(transaction.payment_method.id) : '';
  form.category_id = transaction.category?.id ? String(transaction.category.id) : 'none';
  form.recurrence_id = transaction.recurrence?.id ? String(transaction.recurrence.id) : 'none';
  form.tag_ids = transaction.tags.map(tag => tag.id);
  form.items = transaction.transaction_items.map(item => ({
    id: item.id,
    name: item.name,
    quantity: item.quantity,
    unit_of_measure: item.unit_of_measure,
    unit_price: item.unit_price
  }));
  showItems.value = form.items.length > 0;
  showRecurrenceLink.value = transaction.recurrence !== null;

  if (transaction.installment_plan) {
    showInstallment.value = true;
    form.installment_name = transaction.installment_plan.name;
    form.total_installments = String(transaction.installment_plan.total_installments);
    form.interval_in_months = String(transaction.installment_plan.interval_in_months);
  }
});
</script>

<template>
  <div class="space-y-5">
    <header class="flex flex-col gap-4 border-b border-border pb-5 sm:flex-row sm:items-center sm:justify-between">
      <div class="space-y-1">
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ isEdit ? t('FINANCE_FORM.EDIT_TITLE') : t('FINANCE_FORM.NEW_TITLE') }}
        </h1>
        <p class="text-sm text-muted-foreground">
          {{ t('FINANCE_FORM.SUBTITLE') }}
        </p>
      </div>
      <Button variant="outline" size="sm" @click="router.push({ name: 'finance' })">
        {{ t('FINANCE_FORM.BACK_TO_DASHBOARD') }}
      </Button>
    </header>

    <Alert v-if="formError" variant="destructive">
      <AlertDescription>{{ formError }}</AlertDescription>
    </Alert>

    <form class="space-y-5" @submit.prevent="handleSubmit">
      <Card class="border-border/70 p-4">
        <div class="grid gap-4 md:grid-cols-2">
          <div class="space-y-2 md:col-span-2">
            <Label>{{ t('FINANCE_FORM.DESCRIPTION') }}</Label>
            <Input v-model="form.description" :placeholder="t('FINANCE_FORM.DESCRIPTION_PLACEHOLDER')" required />
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.AMOUNT') }}</Label>
            <Input
              v-model.number="form.amount"
              type="number"
              step="0.01"
              min="0"
              :placeholder="t('FINANCE_FORM.AMOUNT_PLACEHOLDER')"
              required
            />
          </div>

          <div class="space-y-2">
            <Label>
              {{
                form.transaction_type === 'transfer'
                  ? t('FINANCE_FORM.TRANSFER_COUNTERPART')
                  : t('FINANCE_FORM.MERCHANT_NAME')
              }}
            </Label>
            <Input
              v-model="form.merchant_name"
              :placeholder="
                form.transaction_type === 'transfer'
                  ? t('FINANCE_FORM.TRANSFER_COUNTERPART_PLACEHOLDER')
                  : t('FINANCE_FORM.MERCHANT_PLACEHOLDER')
              "
            />
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.PAYMENT_DATE') }}</Label>
            <Input v-model="form.payment_date" type="date" required />
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.DUE_DATE_OPTIONAL') }}</Label>
            <Input v-model="form.due_date" type="date" />
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.TRANSACTION_TYPE') }}</Label>
            <Select v-model="form.transaction_type">
              <SelectTrigger class="w-full">
                <SelectValue :placeholder="t('FINANCE_FORM.SELECT_TYPE')" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem v-for="transactionType in transactionTypes" :key="transactionType" :value="transactionType">
                  {{ t(`FINANCE.TYPES.${transactionType}`) }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.STATUS') }}</Label>
            <Select v-model="form.status">
              <SelectTrigger class="w-full">
                <SelectValue :placeholder="t('FINANCE_FORM.SELECT_STATUS')" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem v-for="status in statuses" :key="status" :value="status">
                  {{ t(`FINANCE.STATUSES.${status}`) }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.PAYMENT_METHOD') }}</Label>
            <Select v-model="form.payment_method_id">
              <SelectTrigger class="w-full">
                <SelectValue :placeholder="t('FINANCE_FORM.SELECT_PAYMENT_METHOD')" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem
                  v-for="paymentMethod in store.paymentMethods"
                  :key="paymentMethod.id"
                  :value="String(paymentMethod.id)"
                >
                  {{ paymentMethod.name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.CATEGORY_OPTIONAL') }}</Label>
            <Select v-model="form.category_id">
              <SelectTrigger class="w-full">
                <SelectValue :placeholder="t('FINANCE_FORM.SELECT_CATEGORY')" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="none">{{ t('FINANCE_FORM.NONE') }}</SelectItem>
                <SelectItem v-for="category in store.categories" :key="category.id" :value="String(category.id)">
                  {{ category.name }}
                </SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </Card>

      <Card class="border-border/70 p-4">
        <div class="flex flex-wrap items-center gap-2">
          <Button
            type="button"
            :variant="showInstallment ? 'secondary' : 'outline'"
            :disabled="isEdit"
            @click="showInstallment = !showInstallment"
          >
            {{ t('FINANCE_FORM.INSTALLMENT_TOGGLE') }}
          </Button>
          <Button
            type="button"
            :variant="showRecurrenceLink ? 'secondary' : 'outline'"
            @click="showRecurrenceLink = !showRecurrenceLink"
          >
            {{ t('FINANCE_FORM.RECURRENCE_TOGGLE') }}
          </Button>
          <Button type="button" :variant="showItems ? 'secondary' : 'outline'" @click="showItems = !showItems">
            {{ t('FINANCE_FORM.ITEMS_TOGGLE') }}
          </Button>
        </div>

        <Alert v-if="form.transaction_type === 'transfer'" class="mt-4">
          <AlertDescription>{{ t('FINANCE_FORM.TRANSFER_HELP') }}</AlertDescription>
        </Alert>

        <div v-if="showInstallment" class="mt-5 grid gap-4 md:grid-cols-3">
          <div class="space-y-2 md:col-span-3">
            <Label>{{ t('FINANCE_FORM.INSTALLMENT_NAME') }}</Label>
            <Input
              v-model="form.installment_name"
              :placeholder="t('FINANCE_FORM.INSTALLMENT_NAME_PLACEHOLDER')"
              :disabled="isEdit"
            />
          </div>
          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.TOTAL_INSTALLMENTS') }}</Label>
            <Input v-model="form.total_installments" type="number" min="2" step="1" :disabled="isEdit" />
          </div>
          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.INSTALLMENT_INTERVAL') }}</Label>
            <Input v-model="form.interval_in_months" type="number" min="1" step="1" :disabled="isEdit" />
          </div>
          <div v-if="isEdit" class="flex items-end text-sm text-muted-foreground">
            {{ t('FINANCE_FORM.INSTALLMENT_EDIT_NOTE') }}
          </div>
        </div>

        <div v-if="showRecurrenceLink" class="mt-5 space-y-2">
          <Label>{{ t('FINANCE_FORM.RECURRENCE') }}</Label>
          <Select v-model="form.recurrence_id">
            <SelectTrigger class="w-full">
              <SelectValue :placeholder="t('FINANCE_FORM.SELECT_RECURRENCE')" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="none">{{ t('FINANCE_FORM.NONE') }}</SelectItem>
              <SelectItem v-for="recurrence in store.recurrences" :key="recurrence.id" :value="String(recurrence.id)">
                {{ recurrence.name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="mt-5 space-y-3">
          <div class="flex items-center justify-between">
            <Label>{{ t('FINANCE_FORM.TAGS') }}</Label>
          </div>
          <div class="flex flex-wrap gap-2">
            <Badge
              v-for="tag in store.tags"
              :key="tag.id"
              :variant="form.tag_ids.includes(tag.id) ? 'default' : 'outline'"
              class="cursor-pointer transition-colors hover:bg-accent hover:text-accent-foreground"
              @click="toggleTag(tag.id)"
            >
              {{ tag.name }}
            </Badge>
          </div>
        </div>

        <div v-if="showItems" class="mt-5 space-y-3">
          <div class="flex items-center justify-between">
            <Label>{{ t('FINANCE_FORM.ITEMS') }}</Label>
            <Button type="button" variant="outline" size="sm" @click="addItem">
              {{ t('FINANCE_FORM.ADD_ITEM') }}
            </Button>
          </div>

          <div
            v-for="(item, index) in form.items"
            v-show="!item._destroy"
            :key="index"
            class="grid gap-3 rounded-lg border bg-muted/20 p-3 md:grid-cols-[minmax(0,2fr)_1fr_1fr_1fr_auto]"
          >
            <Input v-model="item.name" :placeholder="t('FINANCE_FORM.ITEM_NAME')" />
            <Input v-model.number="item.quantity" type="number" min="0.01" step="0.01" />
            <Input v-model="item.unit_of_measure" :placeholder="t('FINANCE_FORM.ITEM_UNIT')" />
            <Input v-model.number="item.unit_price" type="number" min="0" step="0.01" />
            <Button type="button" variant="ghost" class="text-destructive" @click="removeItem(index)">
              {{ t('FINANCE_FORM.REMOVE_ITEM') }}
            </Button>
          </div>
        </div>
      </Card>

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
