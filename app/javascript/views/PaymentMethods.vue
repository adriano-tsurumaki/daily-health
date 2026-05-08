<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useFinanceStore } from '@stores/finance';
import { Button } from '@components/ui/button';
import { Input } from '@components/ui/input';
import { Label } from '@components/ui/label';
import { Card } from '@components/ui/card';
import { Badge } from '@components/ui/badge';
import { Alert, AlertDescription } from '@components/ui/alert';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@components/ui/select';
import type { PaymentMethod, PaymentMethodPayload } from '@services/finance';

const { t, n } = useI18n();
const store = useFinanceStore();

type InstrumentForm = {
  name: string;
  kind: PaymentMethodPayload['kind'];
  is_active: 'true' | 'false';
  display_color: string;
  closing_day: string;
  due_day: string;
  credit_limit: string;
};

const form = reactive<InstrumentForm>({
  name: '',
  kind: 'account',
  is_active: 'true',
  display_color: '#0f766e',
  closing_day: '',
  due_day: '',
  credit_limit: ''
});

const editingId = ref<number | null>(null);

const groupedInstruments = computed(() => [
  {
    key: 'account',
    label: t('FINANCE.PAYMENT_METHODS.GROUPS.ACCOUNT'),
    items: store.paymentMethods.filter(item => item.kind === 'account')
  },
  {
    key: 'credit_card',
    label: t('FINANCE.PAYMENT_METHODS.GROUPS.CREDIT_CARD'),
    items: store.paymentMethods.filter(item => item.kind === 'credit_card')
  },
  {
    key: 'instant',
    label: t('FINANCE.PAYMENT_METHODS.GROUPS.INSTANT'),
    items: store.paymentMethods.filter(item => item.kind === 'instant')
  }
]);

function defaultColorFor(kind: PaymentMethodPayload['kind']) {
  if (kind === 'credit_card') return '#2563eb';

  if (kind === 'instant') return '#d97706';

  return '#0f766e';
}

function identifierFor(kind: PaymentMethodPayload['kind']) {
  if (kind === 'credit_card') return 'credit_card';

  if (kind === 'instant') return 'pix';

  return 'debit_card';
}

function resetForm() {
  form.name = '';
  form.kind = 'account';
  form.is_active = 'true';
  form.display_color = defaultColorFor('account');
  form.closing_day = '';
  form.due_day = '';
  form.credit_limit = '';
  editingId.value = null;
}

function syncCardFields() {
  if (form.kind !== 'credit_card') {
    form.closing_day = '';
    form.due_day = '';
    form.credit_limit = '';
  }

  if (!editingId.value) {
    form.display_color = defaultColorFor(form.kind);
  }
}

function fillForm(paymentMethod: PaymentMethod) {
  editingId.value = paymentMethod.id;
  form.name = paymentMethod.name;
  form.kind = paymentMethod.kind;
  form.is_active = paymentMethod.is_active ? 'true' : 'false';
  form.display_color = paymentMethod.display_color;
  form.closing_day = paymentMethod.closing_day ? String(paymentMethod.closing_day) : '';
  form.due_day = paymentMethod.due_day ? String(paymentMethod.due_day) : '';
  form.credit_limit = paymentMethod.credit_limit ? String(paymentMethod.credit_limit) : '';
}

function buildPayload(): PaymentMethodPayload {
  return {
    name: form.name.trim(),
    locale: 'pt-BR',
    identifier: identifierFor(form.kind),
    kind: form.kind,
    is_active: form.is_active === 'true',
    display_color: form.display_color,
    closing_day: form.kind === 'credit_card' && form.closing_day ? Number(form.closing_day) : null,
    due_day: form.kind === 'credit_card' && form.due_day ? Number(form.due_day) : null,
    credit_limit: form.kind === 'credit_card' && form.credit_limit ? Number(form.credit_limit) : null
  };
}

async function handleSubmit() {
  if (!form.name.trim()) return;

  if (editingId.value) {
    await store.editPaymentMethod(editingId.value, buildPayload());
  } else {
    await store.addPaymentMethod(buildPayload());
  }

  if (!store.error) resetForm();
}

async function handleDelete(id: number) {
  if (!confirm(t('FINANCE.CONFIRM_DELETE'))) return;
  await store.removePaymentMethod(id);
}

function formatCurrency(value: number | null) {
  return value === null ? '—' : n(value, 'currency');
}

function statusVariant(status: string) {
  if (status === 'ok') return 'default';

  if (status === 'inactive') return 'secondary';

  return 'outline';
}

onMounted(() => {
  store.loadPaymentMethods();
  resetForm();
});
</script>

<template>
  <div class="space-y-5">
    <header class="border-b border-border pb-5">
      <div class="space-y-1">
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t('FINANCE.PAYMENT_METHODS.TITLE') }}
        </h1>
        <p class="text-sm text-muted-foreground">
          {{ t('FINANCE.PAYMENT_METHODS.SUBTITLE') }}
        </p>
      </div>
    </header>

    <Alert v-if="store.error" variant="destructive">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <Card class="border-border/70 p-4">
      <form class="grid gap-4 lg:grid-cols-[minmax(0,2fr)_minmax(12rem,1fr)_10rem_8rem]" @submit.prevent="handleSubmit">
        <div class="space-y-2">
          <Label>{{ t('FINANCE.PAYMENT_METHODS.NAME') }}</Label>
          <Input v-model="form.name" :placeholder="t('FINANCE.PAYMENT_METHODS.NAME_PLACEHOLDER')" />
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.PAYMENT_METHODS.KIND') }}</Label>
          <Select v-model="form.kind" @update:model-value="syncCardFields">
            <SelectTrigger class="w-full">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="account">
                {{ t('FINANCE.PAYMENT_METHODS.GROUPS.ACCOUNT') }}
              </SelectItem>
              <SelectItem value="credit_card">
                {{ t('FINANCE.PAYMENT_METHODS.GROUPS.CREDIT_CARD') }}
              </SelectItem>
              <SelectItem value="instant">
                {{ t('FINANCE.PAYMENT_METHODS.GROUPS.INSTANT') }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.PAYMENT_METHODS.ACTIVE') }}</Label>
          <Select v-model="form.is_active">
            <SelectTrigger class="w-full">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="true">{{ t('FINANCE.PAYMENT_METHODS.ACTIVE_YES') }}</SelectItem>
              <SelectItem value="false">{{ t('FINANCE.PAYMENT_METHODS.ACTIVE_NO') }}</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.PAYMENT_METHODS.COLOR') }}</Label>
          <div class="flex items-center gap-2">
            <Input v-model="form.display_color" type="color" class="h-9 w-12 p-1" />
            <span class="font-mono text-xs uppercase text-muted-foreground">{{ form.display_color }}</span>
          </div>
        </div>

        <template v-if="form.kind === 'credit_card'">
          <div class="space-y-2">
            <Label>{{ t('FINANCE.PAYMENT_METHODS.CLOSING_DAY') }}</Label>
            <Input v-model="form.closing_day" type="number" min="1" max="31" />
          </div>

          <div class="space-y-2">
            <Label>{{ t('FINANCE.PAYMENT_METHODS.DUE_DAY') }}</Label>
            <Input v-model="form.due_day" type="number" min="1" max="31" />
          </div>

          <div class="space-y-2 lg:col-span-2">
            <Label>{{ t('FINANCE.PAYMENT_METHODS.CREDIT_LIMIT') }}</Label>
            <Input v-model="form.credit_limit" type="number" step="0.01" min="0" />
          </div>
        </template>

        <div class="flex gap-2 lg:col-span-4">
          <Button type="submit" :disabled="store.loading">
            {{ editingId ? t('FINANCE.PAYMENT_METHODS.SAVE_CHANGES') : t('FINANCE.PAYMENT_METHODS.NEW') }}
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
      v-else-if="store.paymentMethods.length === 0"
      class="rounded-lg border border-dashed bg-card p-8 text-center text-sm text-muted-foreground"
    >
      {{ t('FINANCE.PAYMENT_METHODS.NO_METHODS') }}
    </div>

    <div v-else class="space-y-4">
      <Card v-for="group in groupedInstruments" :key="group.key" class="gap-0 border-border/70 p-0">
        <div class="flex items-center justify-between border-b border-border bg-muted/30 px-4 py-3">
          <h2 class="text-sm font-semibold">
            {{ group.label }}
          </h2>
          <Badge variant="outline">{{ group.items.length }}</Badge>
        </div>

        <div v-if="group.items.length === 0" class="px-4 py-5 text-sm text-muted-foreground">
          {{ t('FINANCE.PAYMENT_METHODS.EMPTY_GROUP') }}
        </div>

        <div v-else class="divide-y divide-border">
          <div
            v-for="item in group.items"
            :key="item.id"
            class="grid gap-3 px-4 py-3 lg:grid-cols-[minmax(0,1fr)_minmax(16rem,0.8fr)_8rem_auto] lg:items-center"
          >
            <div class="flex min-w-0 items-center gap-3">
              <span
                class="size-3 shrink-0 rounded-full border border-black/10"
                :style="{ backgroundColor: item.display_color }"
              />
              <div class="min-w-0">
                <h3 class="truncate text-sm font-semibold">
                  {{ item.name }}
                </h3>
                <p class="text-xs text-muted-foreground">
                  {{ t(`FINANCE.PAYMENT_METHODS.GROUPS.${item.kind.toUpperCase()}`) }}
                </p>
              </div>
            </div>

            <div class="grid grid-cols-2 gap-x-4 gap-y-1 text-sm">
              <div>
                <p class="text-xs text-muted-foreground">{{ t('FINANCE.PAYMENT_METHODS.ACTIVE') }}</p>
                <p class="font-medium">
                  {{
                    item.is_active ? t('FINANCE.PAYMENT_METHODS.ACTIVE_YES') : t('FINANCE.PAYMENT_METHODS.ACTIVE_NO')
                  }}
                </p>
              </div>
              <div v-if="item.kind === 'credit_card'">
                <p class="text-xs text-muted-foreground">{{ t('FINANCE.PAYMENT_METHODS.CLOSING_DAY') }}</p>
                <p class="font-medium tabular-nums">{{ item.closing_day ?? '—' }}</p>
              </div>
              <div v-if="item.kind === 'credit_card'">
                <p class="text-xs text-muted-foreground">{{ t('FINANCE.PAYMENT_METHODS.DUE_DAY') }}</p>
                <p class="font-medium tabular-nums">{{ item.due_day ?? '—' }}</p>
              </div>
              <div v-if="item.kind === 'credit_card'">
                <p class="text-xs text-muted-foreground">{{ t('FINANCE.PAYMENT_METHODS.CREDIT_LIMIT') }}</p>
                <p class="font-medium tabular-nums">{{ formatCurrency(item.credit_limit) }}</p>
              </div>
            </div>

            <Badge :variant="statusVariant(item.review_status)">
              {{ t(`FINANCE.REVIEW_STATUSES.${item.review_status}`) }}
            </Badge>

            <div class="flex justify-end gap-2">
              <Button variant="outline" size="sm" @click="fillForm(item)">
                {{ t('FINANCE.EDIT') }}
              </Button>
              <Button variant="ghost" size="sm" class="text-destructive" @click="handleDelete(item.id)">
                {{ t('FINANCE.DELETE') }}
              </Button>
            </div>
          </div>
        </div>
      </Card>
    </div>
  </div>
</template>
