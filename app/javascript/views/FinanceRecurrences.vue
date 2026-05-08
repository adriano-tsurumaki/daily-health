<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { getLocalTimeZone, today } from '@internationalized/date';
import { useFinanceStore } from '@stores/finance';
import { Button } from '@components/ui/button';
import { Input } from '@components/ui/input';
import { Label } from '@components/ui/label';
import { Card } from '@components/ui/card';
import { Badge } from '@components/ui/badge';
import { Alert, AlertDescription } from '@components/ui/alert';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@components/ui/select';
import type { Recurrence, RecurrencePayload } from '@services/finance';

const { t, n } = useI18n();
const store = useFinanceStore();

type RecurrenceForm = {
  name: string;
  amount: string;
  category_id: string;
  payment_method_id: string;
  frequency: string;
  recurrence_interval: string;
  next_due_date: string;
  end_date: string;
  is_active: 'true' | 'false';
};

const form = reactive<RecurrenceForm>({
  name: '',
  amount: '',
  category_id: 'none',
  payment_method_id: '',
  frequency: 'monthly',
  recurrence_interval: '1',
  next_due_date: today(getLocalTimeZone()).toString(),
  end_date: '',
  is_active: 'true'
});

const editingId = ref<number | null>(null);

const sortedRecurrences = computed(() =>
  [...store.recurrences].sort((left, right) => left.next_due_date.localeCompare(right.next_due_date, 'pt-BR'))
);

function resetForm() {
  form.name = '';
  form.amount = '';
  form.category_id = 'none';
  form.payment_method_id = '';
  form.frequency = 'monthly';
  form.recurrence_interval = '1';
  form.next_due_date = today(getLocalTimeZone()).toString();
  form.end_date = '';
  form.is_active = 'true';
  editingId.value = null;
}

function fillForm(recurrence: Recurrence) {
  editingId.value = recurrence.id;
  form.name = recurrence.name;
  form.amount = String(recurrence.amount);
  form.category_id = recurrence.category?.id ? String(recurrence.category.id) : 'none';
  form.payment_method_id = recurrence.payment_method?.id ? String(recurrence.payment_method.id) : '';
  form.frequency = recurrence.frequency;
  form.recurrence_interval = String(recurrence.recurrence_interval);
  form.next_due_date = recurrence.next_due_date.slice(0, 10);
  form.end_date = recurrence.end_date ? recurrence.end_date.slice(0, 10) : '';
  form.is_active = recurrence.is_active ? 'true' : 'false';
}

function buildPayload(): RecurrencePayload {
  return {
    name: form.name.trim(),
    amount: Number(form.amount),
    category_id: form.category_id === 'none' ? null : Number(form.category_id),
    payment_method_id: Number(form.payment_method_id),
    frequency: form.frequency,
    recurrence_interval: Number(form.recurrence_interval),
    next_due_date: form.next_due_date,
    end_date: form.end_date || null,
    is_active: form.is_active === 'true'
  };
}

async function handleSubmit() {
  if (!form.name.trim() || !form.amount || !form.payment_method_id) return;

  if (editingId.value) {
    await store.editRecurrence(editingId.value, buildPayload());
  } else {
    await store.addRecurrence(buildPayload());
  }

  if (!store.error) resetForm();
}

async function handleDelete(id: number) {
  if (!confirm(t('FINANCE.CONFIRM_DELETE'))) return;
  await store.removeRecurrence(id);
}

function formatCurrency(value: number) {
  return n(value, 'currency');
}

function formatDate(value: string) {
  return new Date(value).toLocaleDateString('pt-BR');
}

function reviewVariant(status: string) {
  return status === 'ok' ? 'default' : 'outline';
}

function activeVariant(isActive: boolean) {
  return isActive ? 'secondary' : 'outline';
}

onMounted(async () => {
  await Promise.all([store.loadCategories(), store.loadPaymentMethods(), store.loadRecurrences()]);
});
</script>

<template>
  <div class="space-y-5">
    <header class="border-b border-border pb-5">
      <div class="space-y-1">
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t('FINANCE.RECURRENCES.TITLE') }}
        </h1>
        <p class="text-sm text-muted-foreground">
          {{ t('FINANCE.RECURRENCES.SUBTITLE') }}
        </p>
      </div>
    </header>

    <Alert v-if="store.error" variant="destructive">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <Card class="border-border/70 p-4">
      <form class="grid gap-4 lg:grid-cols-[minmax(0,2fr)_10rem_14rem_12rem]" @submit.prevent="handleSubmit">
        <div class="space-y-2">
          <Label>{{ t('FINANCE.RECURRENCES.NAME') }}</Label>
          <Input v-model="form.name" :placeholder="t('FINANCE.RECURRENCES.NAME_PLACEHOLDER')" />
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.RECURRENCES.AMOUNT') }}</Label>
          <Input v-model="form.amount" type="number" min="0" step="0.01" />
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.PAYMENT_METHODS.TITLE') }}</Label>
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
          <Label>{{ t('FINANCE.CATEGORY') }}</Label>
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

        <div class="space-y-2">
          <Label>{{ t('FINANCE.RECURRENCES.FREQUENCY') }}</Label>
          <Select v-model="form.frequency">
            <SelectTrigger class="w-full">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="daily">{{ t('FINANCE.RECURRENCES.FREQUENCIES.daily') }}</SelectItem>
              <SelectItem value="weekly">{{ t('FINANCE.RECURRENCES.FREQUENCIES.weekly') }}</SelectItem>
              <SelectItem value="monthly">{{ t('FINANCE.RECURRENCES.FREQUENCIES.monthly') }}</SelectItem>
              <SelectItem value="yearly">{{ t('FINANCE.RECURRENCES.FREQUENCIES.yearly') }}</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.RECURRENCES.INTERVAL') }}</Label>
          <Input v-model="form.recurrence_interval" type="number" min="1" step="1" />
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.RECURRENCES.NEXT_DUE_DATE') }}</Label>
          <Input v-model="form.next_due_date" type="date" />
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.RECURRENCES.END_DATE') }}</Label>
          <Input v-model="form.end_date" type="date" />
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.RECURRENCES.STATUS') }}</Label>
          <Select v-model="form.is_active">
            <SelectTrigger class="w-full">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="true">{{ t('FINANCE.RECURRENCES.STATUS_ACTIVE') }}</SelectItem>
              <SelectItem value="false">{{ t('FINANCE.RECURRENCES.STATUS_PAUSED') }}</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="flex gap-2 lg:col-span-4">
          <Button type="submit" :disabled="store.loading">
            {{ editingId ? t('FINANCE.RECURRENCES.SAVE_CHANGES') : t('FINANCE.RECURRENCES.NEW') }}
          </Button>
          <Button v-if="editingId" type="button" variant="outline" @click="resetForm">
            {{ t('FINANCE_FORM.CANCEL') }}
          </Button>
        </div>
      </form>
    </Card>

    <div v-if="store.loading" class="py-8 text-center text-sm text-muted-foreground">
      {{ t('FINANCE.LOADING') }}
    </div>

    <div
      v-else-if="sortedRecurrences.length === 0"
      class="rounded-lg border border-dashed bg-card p-8 text-center text-sm text-muted-foreground"
    >
      {{ t('FINANCE.RECURRENCES.EMPTY') }}
    </div>

    <Card v-else class="gap-0 border-border/70 p-0">
      <div class="divide-y divide-border">
        <div v-for="recurrence in sortedRecurrences" :key="recurrence.id" class="px-4 py-4">
          <div class="grid gap-4 xl:grid-cols-[minmax(0,1fr)_minmax(22rem,0.9fr)_auto] xl:items-start">
            <div class="min-w-0 space-y-2">
              <div class="flex min-w-0 items-center gap-2">
                <h2 class="truncate text-sm font-semibold">
                  {{ recurrence.name }}
                </h2>
                <Badge :variant="reviewVariant(recurrence.review_status)">
                  {{ t(`FINANCE.REVIEW_STATUSES.${recurrence.review_status}`) }}
                </Badge>
              </div>
              <p class="text-sm text-muted-foreground">
                {{ recurrence.payment_method?.name ?? '—' }} · {{ recurrence.category?.name ?? t('FINANCE_FORM.NONE') }}
              </p>
            </div>

            <div class="grid grid-cols-2 gap-x-4 gap-y-3 text-sm md:grid-cols-4 xl:grid-cols-2">
              <div>
                <p class="text-xs text-muted-foreground">{{ t('FINANCE.RECURRENCES.AMOUNT') }}</p>
                <p class="font-medium tabular-nums">{{ formatCurrency(recurrence.amount) }}</p>
              </div>
              <div>
                <p class="text-xs text-muted-foreground">{{ t('FINANCE.RECURRENCES.NEXT_DUE_DATE') }}</p>
                <p class="font-medium">{{ formatDate(recurrence.next_due_date) }}</p>
              </div>
              <div>
                <p class="text-xs text-muted-foreground">{{ t('FINANCE.RECURRENCES.FREQUENCY') }}</p>
                <p class="font-medium">
                  {{ t(`FINANCE.RECURRENCES.FREQUENCIES.${recurrence.frequency}`) }}
                </p>
              </div>
              <div>
                <p class="text-xs text-muted-foreground">{{ t('FINANCE.RECURRENCES.STATUS') }}</p>
                <Badge :variant="activeVariant(recurrence.is_active)">
                  {{
                    recurrence.is_active
                      ? t('FINANCE.RECURRENCES.STATUS_ACTIVE')
                      : t('FINANCE.RECURRENCES.STATUS_PAUSED')
                  }}
                </Badge>
              </div>
            </div>

            <div class="flex justify-end gap-2">
              <Button variant="outline" size="sm" @click="fillForm(recurrence)">
                {{ t('FINANCE.EDIT') }}
              </Button>
              <Button variant="ghost" size="sm" class="text-destructive" @click="handleDelete(recurrence.id)">
                {{ t('FINANCE.DELETE') }}
              </Button>
            </div>
          </div>

          <div class="mt-4 grid gap-3 rounded-lg bg-muted/30 p-3 text-sm md:grid-cols-[16rem_1fr]">
            <div>
              <p class="text-xs font-medium uppercase tracking-[0.12em] text-muted-foreground">
                {{ t('FINANCE.RECURRENCES.PROJECTION') }}
              </p>
              <div class="mt-2 grid grid-cols-3 gap-3">
                <div>
                  <p class="text-xs text-muted-foreground">3m</p>
                  <p class="font-medium tabular-nums">{{ formatCurrency(recurrence.projection.next_3_months) }}</p>
                </div>
                <div>
                  <p class="text-xs text-muted-foreground">6m</p>
                  <p class="font-medium tabular-nums">{{ formatCurrency(recurrence.projection.next_6_months) }}</p>
                </div>
                <div>
                  <p class="text-xs text-muted-foreground">12m</p>
                  <p class="font-medium tabular-nums">{{ formatCurrency(recurrence.projection.next_12_months) }}</p>
                </div>
              </div>
            </div>

            <div>
              <p class="text-xs font-medium uppercase tracking-[0.12em] text-muted-foreground">
                {{ t('FINANCE.RECURRENCES.NEXT_OCCURRENCES') }}
              </p>
              <div class="mt-2 flex flex-wrap gap-1.5">
                <span
                  v-for="date in recurrence.upcoming_occurrences"
                  :key="date"
                  class="rounded-md bg-background px-2 py-1 text-xs text-muted-foreground ring-1 ring-border"
                >
                  {{ formatDate(date) }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Card>
  </div>
</template>
