<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue';
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
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle
} from '@components/ui/dialog';
import {
  NumberField,
  NumberFieldContent,
  NumberFieldDecrement,
  NumberFieldInput,
  NumberFieldIncrement
} from '@components/ui/number-field';

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
const keepFilling = ref(false);

const pendingType = ref<string | null>(null);
const showTypeChangeDialog = ref(false);

const transactionTypes = ['expense', 'income', 'transfer', 'refund'];
const statuses = ['pending', 'paid', 'cancelled', 'failed', 'expired'];

const isIncome = computed(() => form.transaction_type === 'income');
const isTransfer = computed(() => form.transaction_type === 'transfer');
const isExpense = computed(() => form.transaction_type === 'expense' || form.transaction_type === 'refund');
const isAlwaysPaid = computed(() => form.transaction_type === 'income' || form.transaction_type === 'refund');

const descriptionPlaceholder = computed(() => {
  const map: Record<string, string> = {
    income: t('FINANCE_FORM.DESCRIPTION_PLACEHOLDER_INCOME'),
    transfer: t('FINANCE_FORM.DESCRIPTION_PLACEHOLDER_TRANSFER'),
    refund: t('FINANCE_FORM.DESCRIPTION_PLACEHOLDER_REFUND')
  };

  return map[form.transaction_type] ?? t('FINANCE_FORM.DESCRIPTION_PLACEHOLDER');
});

const typeIcons: Record<string, string> = {
  expense: '↓',
  income: '↑',
  transfer: '⇄',
  refund: '↩'
};

function isFormDirty(): boolean {
  return (
    form.amount !== 0 ||
    form.description !== '' ||
    form.merchant_name !== '' ||
    form.tag_ids.length > 0 ||
    form.items.length > 0
  );
}

function requestTypeChange(type: string) {
  if (type === form.transaction_type) return;

  if (!isEdit.value && isFormDirty()) {
    pendingType.value = type;
    showTypeChangeDialog.value = true;
  } else {
    applyTypeChange(type);
  }
}

function confirmTypeChange() {
  if (pendingType.value) applyTypeChange(pendingType.value);
  showTypeChangeDialog.value = false;
  pendingType.value = null;
}

function cancelTypeChange() {
  showTypeChangeDialog.value = false;
  pendingType.value = null;
}

function applyTypeChange(type: string) {
  form.transaction_type = type;
  form.amount = 0;
  form.description = '';
  form.merchant_name = '';
  form.tag_ids = [];
  form.items = [];
  showInstallment.value = false;
  showItems.value = false;
  showRecurrenceLink.value = false;

  const expenseTypes = ['expense', 'refund'];

  if (!expenseTypes.includes(type)) form.due_date = '';

  if (type === 'income' || type === 'refund') {
    form.status = 'paid';
  }
}

watch(isAlwaysPaid, val => {
  if (val) form.status = 'paid';
});

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

function resetForNextEntry() {
  form.amount = 0;
  form.description = '';
  form.tag_ids = [];
  form.items = [];
  form.installment_name = '';
  form.total_installments = '2';
  form.interval_in_months = '1';
  showItems.value = false;
  showInstallment.value = false;
  showRecurrenceLink.value = false;
  formError.value = null;
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

  if (keepFilling.value && !isEdit.value) {
    resetForNextEntry();
  } else {
    router.push({ name: 'finance' });
  }
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

    <Card class="border-border/70 p-4">
      <div class="flex flex-wrap gap-2">
        <button
          v-for="type in transactionTypes"
          :key="type"
          type="button"
          :class="[
            'flex items-center gap-2 rounded-md border px-4 py-2 text-sm font-medium transition-colors',
            form.transaction_type === type
              ? 'border-primary bg-primary text-primary-foreground'
              : 'border-border bg-background text-foreground hover:bg-accent hover:text-accent-foreground',
            isEdit ? 'cursor-not-allowed opacity-50' : 'cursor-pointer'
          ]"
          :disabled="isEdit"
          @click="requestTypeChange(type)"
        >
          <span>{{ typeIcons[type] }}</span>
          {{ t(`FINANCE.TYPES.${type}`) }}
        </button>
      </div>
    </Card>

    <form class="space-y-5" @submit.prevent="handleSubmit">
      <Card class="border-border/70 p-4">
        <div class="grid gap-4 md:grid-cols-2">
          <div class="space-y-2 md:col-span-2">
            <Label>{{ t('FINANCE_FORM.DESCRIPTION') }}</Label>
            <Input v-model="form.description" :placeholder="descriptionPlaceholder" required />
          </div>

          <div class="space-y-2">
            <Label for="amount">{{ t('FINANCE_FORM.AMOUNT') }}</Label>
            <NumberField
              id="amount"
              v-model="form.amount"
              :min="0"
              :step="1"
              :format-options="{
                style: 'currency',
                currency: 'BRL',
                currencyDisplay: 'symbol',
                currencySign: 'accounting'
              }"
              invert-wheel-change
            >
              <NumberFieldContent>
                <NumberFieldDecrement />
                <NumberFieldInput />
                <NumberFieldIncrement />
              </NumberFieldContent>
            </NumberField>
          </div>

          <div v-if="!isIncome" class="space-y-2">
            <Label>
              {{ isTransfer ? t('FINANCE_FORM.TRANSFER_COUNTERPART') : t('FINANCE_FORM.MERCHANT_NAME') }}
            </Label>
            <Input
              v-model="form.merchant_name"
              :placeholder="
                isTransfer ? t('FINANCE_FORM.TRANSFER_COUNTERPART_PLACEHOLDER') : t('FINANCE_FORM.MERCHANT_PLACEHOLDER')
              "
            />
          </div>
          <div v-if="isIncome" class="space-y-2">
            <Label>{{ t('FINANCE_FORM.INCOME_SOURCE') }}</Label>
            <Input v-model="form.merchant_name" :placeholder="t('FINANCE_FORM.INCOME_SOURCE_PLACEHOLDER')" />
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE_FORM.PAYMENT_DATE') }}</Label>
            <Input v-model="form.payment_date" type="date" required />
          </div>

          <div v-if="isExpense" class="space-y-2">
            <Label>{{ t('FINANCE_FORM.DUE_DATE_OPTIONAL') }}</Label>
            <Input v-model="form.due_date" type="date" />
          </div>

          <div v-if="!isAlwaysPaid" class="space-y-2">
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

          <div v-if="store.tags.length > 0" class="space-y-2 md:col-span-2">
            <Label>{{ t('FINANCE_FORM.TAGS') }}</Label>
            <div class="flex flex-wrap gap-2">
              <Badge
                v-for="tag in store.tags"
                :key="tag.id"
                :variant="form.tag_ids.includes(tag.id) ? 'tag-active' : 'tag'"
                class="cursor-pointer select-none transition-colors"
                @click="toggleTag(tag.id)"
              >
                {{ tag.name }}
              </Badge>
            </div>
          </div>
        </div>
      </Card>

      <Card class="border-border/70 p-4">
        <div class="flex flex-wrap items-center gap-2">
          <Button
            v-if="isExpense"
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
          <Button
            v-if="isExpense"
            type="button"
            :variant="showItems ? 'secondary' : 'outline'"
            @click="showItems = !showItems"
          >
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

      <div class="flex items-center gap-4">
        <div class="flex gap-3">
          <Button type="submit" :disabled="saving">
            {{ saving ? t('FINANCE_FORM.SAVING') : t('FINANCE_FORM.SAVE') }}
          </Button>
          <Button type="button" variant="outline" @click="router.push({ name: 'finance' })">
            {{ t('FINANCE_FORM.CANCEL') }}
          </Button>
        </div>

        <div v-if="!isEdit" class="ml-auto flex items-center gap-2">
          <input
            id="keep-filling"
            v-model="keepFilling"
            type="checkbox"
            class="h-4 w-4 cursor-pointer rounded border-border accent-primary"
          />
          <Label for="keep-filling" class="cursor-pointer text-sm font-normal text-muted-foreground">
            {{ t('FINANCE_FORM.KEEP_FILLING') }}
          </Label>
        </div>
      </div>
    </form>

    <!-- Modal confirmação troca de tipo -->
    <Dialog :open="showTypeChangeDialog" @update:open="cancelTypeChange">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>{{ t('FINANCE_FORM.TYPE_CHANGE_TITLE') }}</DialogTitle>
          <DialogDescription>{{ t('FINANCE_FORM.TYPE_CHANGE_DESCRIPTION') }}</DialogDescription>
        </DialogHeader>
        <DialogFooter>
          <Button variant="outline" @click="cancelTypeChange">{{ t('FINANCE_FORM.CANCEL') }}</Button>
          <Button variant="destructive" @click="confirmTypeChange">{{ t('FINANCE_FORM.TYPE_CHANGE_CONFIRM') }}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
