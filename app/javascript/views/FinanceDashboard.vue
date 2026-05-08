<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useFinanceStore } from '@stores/finance';
import { Button } from '@components/ui/button';
import { Card } from '@components/ui/card';
import { Alert, AlertDescription } from '@components/ui/alert';
import { Badge } from '@components/ui/badge';
import { AlertTriangle, ChevronLeft, ChevronRight, Plus } from 'lucide-vue-next';

const { t, n } = useI18n();
const store = useFinanceStore();

const currentMonth = ref(new Date().getMonth() + 1);
const currentYear = ref(new Date().getFullYear());
const rankingTab = ref<'categories' | 'merchants'>('categories');

const monthLabel = computed(() => {
  const date = new Date(currentYear.value, currentMonth.value - 1);

  return date.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' });
});

const summaryCards = computed(() => [
  {
    key: 'available',
    label: t('FINANCE.SUMMARY.AVAILABLE'),
    value: store.dashboard?.summary.available ?? 0,
    tone: 'text-success'
  },
  {
    key: 'committed_this_month',
    label: t('FINANCE.SUMMARY.COMMITTED'),
    value: store.dashboard?.summary.committed_this_month ?? 0,
    tone: 'text-foreground'
  },
  {
    key: 'upcoming_charges',
    label: t('FINANCE.SUMMARY.UPCOMING'),
    value: store.dashboard?.summary.upcoming_charges ?? 0,
    tone: 'text-primary'
  },
  {
    key: 'projected_surplus',
    label: t('FINANCE.SUMMARY.LEFTOVER'),
    value: store.dashboard?.summary.projected_surplus ?? 0,
    tone: (store.dashboard?.summary.projected_surplus ?? 0) >= 0 ? 'text-success' : 'text-destructive'
  }
]);

function prevMonth() {
  if (currentMonth.value === 1) {
    currentMonth.value = 12;
    currentYear.value -= 1;
  } else {
    currentMonth.value -= 1;
  }
  loadData();
}

function nextMonth() {
  if (currentMonth.value === 12) {
    currentMonth.value = 1;
    currentYear.value += 1;
  } else {
    currentMonth.value += 1;
  }
  loadData();
}

function loadData() {
  store.loadDashboard(currentMonth.value, currentYear.value);
}

function formatCurrency(value: number) {
  return n(value, 'currency');
}

function formatDate(value: string) {
  return new Date(value).toLocaleDateString('pt-BR');
}

function alertTone(level: string) {
  if (level === 'danger') return 'bg-destructive/10 text-destructive';

  if (level === 'warning') return 'bg-chart-5/10 text-chart-5';

  return 'bg-muted text-muted-foreground';
}

function entryStateVariant(state: string) {
  if (state === 'realized') return 'default';

  if (state === 'predicted') return 'secondary';

  return 'outline';
}

function budgetBarWidth(percentage: number | null) {
  if (percentage === null) return '0%';

  return `${Math.min(100, Math.max(0, percentage))}%`;
}

onMounted(() => {
  loadData();
});
</script>

<template>
  <div class="space-y-5">
    <header class="flex flex-col gap-4 border-b border-border pb-5 lg:flex-row lg:items-end lg:justify-between">
      <div class="space-y-1">
        <p class="text-xs font-semibold uppercase tracking-[0.18em] text-primary">
          {{ t('FINANCE.DASHBOARD') }}
        </p>
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t('FINANCE.TITLE') }}
        </h1>
        <p class="max-w-2xl text-sm text-muted-foreground">
          {{ t('FINANCE.DASHBOARD_SUBTITLE') }}
        </p>
      </div>

      <div class="flex flex-wrap items-center gap-2">
        <div class="inline-flex h-9 items-center rounded-md border bg-card shadow-xs">
          <Button variant="ghost" size="icon-sm" class="rounded-r-none" aria-label="Previous month" @click="prevMonth">
            <ChevronLeft class="size-4" />
          </Button>
          <span class="min-w-44 px-3 text-center text-sm font-medium capitalize">{{ monthLabel }}</span>
          <Button variant="ghost" size="icon-sm" class="rounded-l-none" aria-label="Next month" @click="nextMonth">
            <ChevronRight class="size-4" />
          </Button>
        </div>

        <Button as-child>
          <RouterLink :to="{ name: 'finance-transactions-new' }">
            <Plus class="size-4" />
            {{ t('FINANCE.NEW_TRANSACTION') }}
          </RouterLink>
        </Button>
      </div>
    </header>

    <Alert v-if="store.error" variant="destructive">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <div v-if="store.loading && !store.dashboard" class="py-16 text-center text-muted-foreground">
      {{ t('FINANCE.LOADING') }}
    </div>

    <template v-else-if="store.dashboard">
      <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <Card v-for="card in summaryCards" :key="card.key" class="border-border/70 p-4">
          <div>
            <p class="text-xs font-medium uppercase tracking-[0.14em] text-muted-foreground">
              {{ card.label }}
            </p>
            <p class="mt-3 text-2xl font-semibold tracking-tight tabular-nums" :class="card.tone">
              {{ formatCurrency(card.value) }}
            </p>
          </div>
        </Card>
      </div>

      <div class="grid gap-4 xl:grid-cols-[1.2fr_0.8fr]">
        <Card class="border-border/70 p-4">
          <div class="flex items-center justify-between gap-3">
            <div>
              <h2 class="text-base font-semibold">{{ t('FINANCE.ALERTS.TITLE') }}</h2>
              <p class="text-sm text-muted-foreground">{{ t('FINANCE.ALERTS.SUBTITLE') }}</p>
            </div>
            <Badge variant="outline">{{ store.dashboard.alerts.length }}</Badge>
          </div>

          <div v-if="store.dashboard.alerts.length === 0" class="pt-5 text-sm text-muted-foreground">
            {{ t('FINANCE.ALERTS.EMPTY') }}
          </div>

          <div v-else class="mt-4 divide-y divide-border">
            <div v-for="alert in store.dashboard.alerts" :key="alert.id" class="flex gap-3 py-3 first:pt-0 last:pb-0">
              <span
                class="mt-0.5 flex size-8 shrink-0 items-center justify-center rounded-md"
                :class="alertTone(alert.level)"
              >
                <AlertTriangle class="size-4" />
              </span>
              <div class="min-w-0">
                <p class="font-medium">{{ alert.title }}</p>
                <p class="mt-1 text-sm text-muted-foreground">{{ alert.description }}</p>
              </div>
            </div>
          </div>
        </Card>

        <Card class="border-border/70 p-4">
          <div class="flex items-start justify-between gap-3">
            <div>
              <h2 class="text-base font-semibold">{{ t('FINANCE.REVIEW_QUEUE.TITLE') }}</h2>
              <p class="text-sm text-muted-foreground">{{ t('FINANCE.REVIEW_QUEUE.SUBTITLE') }}</p>
            </div>
            <Badge>{{ store.dashboard.review_queue.total }}</Badge>
          </div>

          <div class="mt-5 grid grid-cols-3 gap-3">
            <div class="rounded-lg border bg-muted/30 p-3">
              <p class="text-xs font-medium uppercase tracking-[0.12em] text-muted-foreground">
                {{ t('FINANCE.REVIEW_QUEUE.UNCATEGORIZED') }}
              </p>
              <p class="mt-2 text-2xl font-semibold">
                {{ store.dashboard.review_queue.uncategorized_count }}
              </p>
            </div>
            <div class="rounded-lg border bg-muted/30 p-3">
              <p class="text-xs font-medium uppercase tracking-[0.12em] text-muted-foreground">
                {{ t('FINANCE.REVIEW_QUEUE.INSTRUMENTS') }}
              </p>
              <p class="mt-2 text-2xl font-semibold">
                {{ store.dashboard.review_queue.incomplete_instruments_count }}
              </p>
            </div>
            <div class="rounded-lg border bg-muted/30 p-3">
              <p class="text-xs font-medium uppercase tracking-[0.12em] text-muted-foreground">
                {{ t('FINANCE.REVIEW_QUEUE.RECURRENCES') }}
              </p>
              <p class="mt-2 text-2xl font-semibold">
                {{ store.dashboard.review_queue.broken_recurrences_count }}
              </p>
            </div>
          </div>

          <div class="mt-4 space-y-2">
            <div
              v-for="item in store.dashboard.review_queue.items"
              :key="`${item.type}-${item.id}`"
              class="flex items-center justify-between gap-3 rounded-md border border-border/70 px-3 py-2 text-sm"
            >
              <span class="truncate">{{ item.title }}</span>
              <Badge variant="outline">
                {{ t(`FINANCE.REVIEW_STATUSES.${item.review_status}`) }}
              </Badge>
            </div>
          </div>
        </Card>
      </div>

      <section class="space-y-3">
        <div class="flex items-center justify-between">
          <h2 class="text-base font-semibold">{{ t('FINANCE.INSTRUMENT_SNAPSHOTS.TITLE') }}</h2>
          <RouterLink :to="{ name: 'finance-payment-methods' }" class="text-sm font-medium text-primary no-underline">
            {{ t('FINANCE.INSTRUMENT_SNAPSHOTS.CTA') }}
          </RouterLink>
        </div>

        <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          <Card
            v-for="instrument in store.dashboard.instrument_snapshots"
            :key="instrument.id"
            class="border-border/70 p-4"
          >
            <div class="space-y-4">
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                  <div class="flex items-center gap-2">
                    <span
                      class="size-2.5 shrink-0 rounded-full border border-black/10"
                      :style="{ backgroundColor: instrument.display_color }"
                    />
                    <h3 class="truncate text-base font-semibold">{{ instrument.name }}</h3>
                  </div>
                  <p class="text-sm text-muted-foreground">
                    {{ t(`FINANCE.PAYMENT_METHODS.GROUPS.${instrument.kind.toUpperCase()}`) }}
                  </p>
                </div>
                <Badge variant="outline">
                  {{ t(`FINANCE.REVIEW_STATUSES.${instrument.review_status}`) }}
                </Badge>
              </div>

              <div class="grid grid-cols-2 gap-x-4 gap-y-3 text-sm">
                <div>
                  <p class="text-muted-foreground">
                    {{ t('FINANCE.INSTRUMENT_SNAPSHOTS.REALIZED') }}
                  </p>
                  <p class="font-medium">{{ formatCurrency(instrument.realized_amount) }}</p>
                </div>
                <div>
                  <p class="text-muted-foreground">
                    {{ t('FINANCE.INSTRUMENT_SNAPSHOTS.PENDING') }}
                  </p>
                  <p class="font-medium">{{ formatCurrency(instrument.pending_amount) }}</p>
                </div>
                <div v-if="instrument.credit_limit !== null">
                  <p class="text-muted-foreground">
                    {{ t('FINANCE.PAYMENT_METHODS.CREDIT_LIMIT') }}
                  </p>
                  <p class="font-medium">{{ formatCurrency(instrument.credit_limit) }}</p>
                </div>
                <div v-if="instrument.utilization !== null">
                  <p class="text-muted-foreground">
                    {{ t('FINANCE.INSTRUMENT_SNAPSHOTS.UTILIZATION') }}
                  </p>
                  <p class="font-medium">{{ instrument.utilization.toFixed(1) }}%</p>
                </div>
              </div>
            </div>
          </Card>
        </div>
      </section>

      <div class="grid gap-4 xl:grid-cols-[1.1fr_0.9fr]">
        <Card class="border-border/70 p-4">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold">{{ t('FINANCE.TIMELINE.TITLE') }}</h2>
            <Badge variant="outline">{{ store.dashboard.upcoming_timeline.length }}</Badge>
          </div>

          <div class="mt-4 divide-y divide-border">
            <div
              v-for="entry in store.dashboard.upcoming_timeline"
              :key="`${entry.type}-${entry.id}`"
              class="grid gap-3 py-3 first:pt-0 last:pb-0 md:grid-cols-[5.5rem_1fr_auto_7rem] md:items-center"
            >
              <div class="text-sm font-medium text-muted-foreground">
                {{ formatDate(entry.commitment_date) }}
              </div>
              <div class="min-w-0">
                <p class="truncate font-medium">{{ entry.title }}</p>
                <p class="text-sm text-muted-foreground">
                  {{ entry.category_name }} • {{ entry.payment_method_name ?? '—' }}
                </p>
              </div>
              <Badge :variant="entryStateVariant(entry.entry_state)">
                {{ t(`FINANCE.ENTRY_STATES.${entry.entry_state}`) }}
              </Badge>
              <div class="text-right font-medium tabular-nums">
                {{ formatCurrency(entry.amount) }}
              </div>
            </div>
          </div>
        </Card>

        <Card class="border-border/70 p-4">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold">{{ t('FINANCE.BUDGET_HEALTH.TITLE') }}</h2>
            <RouterLink :to="{ name: 'finance-categories' }" class="text-sm font-medium text-primary no-underline">
              {{ t('FINANCE.BUDGET_HEALTH.CTA') }}
            </RouterLink>
          </div>

          <div class="mt-4 space-y-4">
            <div v-for="item in store.dashboard.budget_health" :key="item.id ?? item.label" class="space-y-2">
              <div class="flex items-center justify-between gap-3">
                <div class="flex min-w-0 items-center gap-2">
                  <span
                    class="inline-flex size-2.5 shrink-0 rounded-full border border-black/10"
                    :style="{ backgroundColor: item.color }"
                  />
                  <span class="truncate font-medium">{{ item.label }}</span>
                </div>
                <span class="shrink-0 text-sm text-muted-foreground">
                  {{ formatCurrency(item.spent) }}
                  <template v-if="item.monthly_limit !== null">/ {{ formatCurrency(item.monthly_limit) }}</template>
                </span>
              </div>
              <div class="h-2 rounded-full bg-muted">
                <div
                  class="h-full rounded-full"
                  :style="{ width: budgetBarWidth(item.utilization), backgroundColor: item.color }"
                />
              </div>
            </div>
          </div>
        </Card>
      </div>

      <div class="grid gap-4 xl:grid-cols-[0.95fr_1.05fr]">
        <Card class="border-border/70 p-4">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold">{{ t('FINANCE.RANKINGS.TITLE') }}</h2>
            <div class="flex rounded-md bg-muted p-1">
              <Button
                size="sm"
                :variant="rankingTab === 'categories' ? 'secondary' : 'ghost'"
                class="h-7 px-2.5 shadow-none"
                @click="rankingTab = 'categories'"
              >
                {{ t('FINANCE.RANKINGS.CATEGORIES') }}
              </Button>
              <Button
                size="sm"
                :variant="rankingTab === 'merchants' ? 'secondary' : 'ghost'"
                class="h-7 px-2.5 shadow-none"
                @click="rankingTab = 'merchants'"
              >
                {{ t('FINANCE.RANKINGS.MERCHANTS') }}
              </Button>
            </div>
          </div>

          <div class="mt-4 divide-y divide-border">
            <div
              v-for="(item, index) in store.dashboard.rankings[rankingTab]"
              :key="item.label"
              class="flex items-center justify-between gap-3 py-3 first:pt-0 last:pb-0"
            >
              <div class="flex min-w-0 items-center gap-3">
                <span
                  class="flex size-6 shrink-0 items-center justify-center rounded-md bg-muted text-xs font-medium text-muted-foreground"
                >
                  {{ index + 1 }}
                </span>
                <span class="truncate font-medium">{{ item.label }}</span>
              </div>
              <span class="shrink-0 text-sm font-medium tabular-nums">{{ formatCurrency(item.amount) }}</span>
            </div>
          </div>
        </Card>

        <Card class="border-border/70 p-4">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold">{{ t('FINANCE.RECENT_ACTIVITY.TITLE') }}</h2>
            <RouterLink :to="{ name: 'finance-recurrences' }" class="text-sm font-medium text-primary no-underline">
              {{ t('FINANCE.RECENT_ACTIVITY.CTA') }}
            </RouterLink>
          </div>

          <div class="mt-4 divide-y divide-border">
            <div
              v-for="entry in store.dashboard.recent_activity"
              :key="entry.id"
              class="grid gap-3 py-3 first:pt-0 last:pb-0 md:grid-cols-[5.5rem_1fr_auto_7rem] md:items-center"
            >
              <div class="text-sm text-muted-foreground">
                {{ formatDate(entry.payment_date) }}
              </div>
              <div class="min-w-0">
                <p class="truncate font-medium">{{ entry.description }}</p>
                <p class="text-sm text-muted-foreground">{{ entry.category }} • {{ entry.payment_method ?? '—' }}</p>
              </div>
              <Badge :variant="entryStateVariant(entry.entry_state)">
                {{ t(`FINANCE.ENTRY_STATES.${entry.entry_state}`) }}
              </Badge>
              <div class="text-right font-medium tabular-nums">
                {{ formatCurrency(entry.amount) }}
              </div>
            </div>
          </div>
        </Card>
      </div>
    </template>
  </div>
</template>
