<script setup lang="ts">
  import { onMounted, ref, computed } from 'vue'
  import { useI18n } from 'vue-i18n'
  import { useFinanceStore } from '@stores/finance'
  import { Button } from '@components/ui/button'
  import { Card } from '@components/ui/card'
  import { Alert, AlertDescription } from '@components/ui/alert'
  import { Badge } from '@components/ui/badge'
  import {
    Table,
    TableHeader,
    TableBody,
    TableRow,
    TableHead,
    TableCell,
  } from '@components/ui/table'

  const { t, n } = useI18n()
  const store = useFinanceStore()

  const currentMonth = ref(new Date().getMonth() + 1)
  const currentYear = ref(new Date().getFullYear())

  const monthLabel = computed(() => {
    const date = new Date(currentYear.value, currentMonth.value - 1)
    return date.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' })
  })

  function prevMonth() {
    if (currentMonth.value === 1) {
      currentMonth.value = 12
      currentYear.value--
    } else {
      currentMonth.value--
    }
    loadData()
  }

  function nextMonth() {
    if (currentMonth.value === 12) {
      currentMonth.value = 1
      currentYear.value++
    } else {
      currentMonth.value++
    }
    loadData()
  }

  function loadData() {
    store.loadDashboard(currentMonth.value, currentYear.value)
  }

  function formatCurrency(value: number) {
    return n(Number(value), 'currency', 'pt-BR')
  }

  function formatDate(date: string) {
    return new Date(date).toLocaleDateString('pt-BR')
  }

  onMounted(() => {
    loadData()
  })
</script>

<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">
        {{ t('FINANCE.TITLE') }}
      </h1>
      <Button as-child>
        <RouterLink :to="{ name: 'finance-transactions-new' }">
          {{
            t('FINANCE.NEW_TRANSACTION')
          }}
        </RouterLink>
      </Button>
    </div>

    <!-- Month selector -->
    <div class="flex items-center gap-4 mb-6">
      <Button variant="outline" size="sm" @click="prevMonth">
        &larr;
      </Button>
      <span class="text-lg font-medium capitalize">{{ monthLabel }}</span>
      <Button variant="outline" size="sm" @click="nextMonth">
        &rarr;
      </Button>
    </div>

    <Alert v-if="store.error" variant="destructive" class="mb-4">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <!-- Summary cards -->
    <div v-if="store.dashboard" class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
      <Card class="p-6">
        <p class="text-sm text-muted-foreground mb-1">
          {{ t('FINANCE.INCOME') }}
        </p>
        <p class="text-2xl font-bold text-green-600 dark:text-green-400">
          {{ formatCurrency(store.dashboard.total_income) }}
        </p>
      </Card>
      <Card class="p-6">
        <p class="text-sm text-muted-foreground mb-1">
          {{ t('FINANCE.EXPENSE') }}
        </p>
        <p class="text-2xl font-bold text-red-600 dark:text-red-400">
          {{ formatCurrency(store.dashboard.total_expense) }}
        </p>
      </Card>
      <Card class="p-6">
        <p class="text-sm text-muted-foreground mb-1">
          {{ t('FINANCE.BALANCE') }}
        </p>
        <p
          class="text-2xl font-bold"
          :class="
            store.dashboard.balance >= 0
              ? 'text-green-600 dark:text-green-400'
              : 'text-red-600 dark:text-red-400'
          "
        >
          {{ formatCurrency(store.dashboard.balance) }}
        </p>
      </Card>
    </div>

    <!-- Recent transactions -->
    <h2 class="text-lg font-semibold mb-4">
      {{ t('FINANCE.RECENT_TRANSACTIONS') }}
    </h2>

    <div v-if="store.loading" class="text-center py-8 text-muted-foreground">
      ...
    </div>

    <div
      v-else-if="!store.dashboard?.recent_transactions?.length"
      class="text-center py-8 text-muted-foreground"
    >
      {{ t('FINANCE.NO_TRANSACTIONS') }}
    </div>

    <div v-else class="overflow-x-auto">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>{{ t('FINANCE.DATE') }}</TableHead>
            <TableHead>{{ t('FINANCE.TYPE') }}</TableHead>
            <TableHead>{{ t('FINANCE.CATEGORY') }}</TableHead>
            <TableHead>{{ t('FINANCE.PAYMENT_METHOD') }}</TableHead>
            <TableHead>{{ t('FINANCE.STATUS') }}</TableHead>
            <TableHead class="text-right">
              {{ t('FINANCE.AMOUNT') }}
            </TableHead>
            <TableHead class="text-right">
              {{ t('FINANCE.ACTIONS') }}
            </TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="tx in store.dashboard.recent_transactions" :key="tx.id">
            <TableCell>{{ formatDate(tx.payment_date) }}</TableCell>
            <TableCell>
              <Badge :variant="tx.transaction_type === 'income' ? 'default' : 'secondary'">
                {{ t(`FINANCE.TYPES.${tx.transaction_type}`) }}
              </Badge>
            </TableCell>
            <TableCell>{{ tx.category ?? '-' }}</TableCell>
            <TableCell>{{ tx.payment_method ?? '-' }}</TableCell>
            <TableCell>
              <Badge variant="outline">
                {{ t(`FINANCE.STATUSES.${tx.status}`) }}
              </Badge>
            </TableCell>
            <TableCell
              class="text-right"
              :class="
                tx.transaction_type === 'income'
                  ? 'text-green-600 dark:text-green-400'
                  : 'text-red-600 dark:text-red-400'
              "
            >
              {{ formatCurrency(tx.amount) }}
            </TableCell>
            <TableCell class="text-right">
              <Button variant="link" as-child class="p-0 h-auto">
                <RouterLink :to="{ name: 'finance-transactions-edit', params: { id: tx.id } }">
                  {{
                    t('FINANCE.EDIT')
                  }}
                </RouterLink>
              </Button>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </div>
  </div>
</template>
