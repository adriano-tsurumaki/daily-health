import http from './http';

export interface TransactionItem {
  id: number;
  name: string;
  quantity: number;
  unit_of_measure: string;
  unit_price: number;
  total: number;
}

export interface Tag {
  id: number;
  name: string;
}

export interface Category {
  id: number;
  name: string;
  monthly_limit: number | null;
  color: string;
}

export interface PaymentMethod {
  id: number;
  name: string;
  locale: string;
  identifier: string;
  kind: 'account' | 'credit_card' | 'instant';
  is_active: boolean;
  display_color: string;
  closing_day: number | null;
  due_day: number | null;
  credit_limit: number | null;
  review_status: string;
}

export interface RecurrenceProjection {
  next_3_months: number;
  next_6_months: number;
  next_12_months: number;
}

export interface Recurrence {
  id: number;
  name: string;
  amount: number;
  frequency: string;
  recurrence_interval: number;
  next_due_date: string;
  end_date: string | null;
  is_active: boolean;
  review_status: string;
  category: Category | null;
  payment_method: PaymentMethod | null;
  projection: RecurrenceProjection;
  upcoming_occurrences: string[];
}

export interface InstallmentPlanSummary {
  id: number;
  name: string;
  total_amount: number;
  total_installments: number;
  current_installment: number | null;
  interval_in_months: number;
}

export interface Transaction {
  id: number;
  amount: number;
  description: string;
  merchant_name: string | null;
  payment_date: string;
  due_date: string | null;
  transaction_type: string;
  status: string;
  review_status: string;
  entry_state: 'realized' | 'committed' | 'predicted';
  period_bucket: string | null;
  payment_method: PaymentMethod | null;
  category: Category | null;
  recurrence: Recurrence | null;
  installment_plan: InstallmentPlanSummary | null;
  tags: Tag[];
  transaction_items: TransactionItem[];
}

export interface DashboardPeriod {
  month: number;
  year: number;
  bucket: string;
  starts_on: string;
  ends_on: string;
}

export interface DashboardSummaryCards {
  available: number;
  committed_this_month: number;
  upcoming_charges: number;
  projected_surplus: number;
  realized: {
    income: number;
    expense: number;
  };
  predicted: {
    income: number;
    expense: number;
  };
}

export interface DashboardAlert {
  id: string;
  level: string;
  title: string;
  description: string;
}

export interface DashboardReviewQueue {
  total: number;
  uncategorized_count: number;
  incomplete_instruments_count: number;
  broken_recurrences_count: number;
  items: {
    type: string;
    id: number;
    title: string;
    review_status: string;
  }[];
}

export interface DashboardInstrumentSnapshot {
  id: number;
  name: string;
  kind: string;
  is_active: boolean;
  display_color: string;
  review_status: string;
  closing_day: number | null;
  due_day: number | null;
  credit_limit: number | null;
  committed_amount: number;
  realized_amount: number;
  pending_amount: number;
  utilization: number | null;
  remaining_limit: number | null;
}

export interface DashboardTimelineItem {
  type: string;
  id: number;
  title: string;
  amount: number;
  commitment_date: string;
  entry_state: string;
  review_status: string;
  category_name: string;
  payment_method_name: string | null;
}

export interface DashboardBudgetHealthItem {
  id: number | null;
  label: string;
  color: string;
  monthly_limit: number | null;
  spent: number;
  utilization: number | null;
  status: string;
}

export interface DashboardRankingItem {
  label: string;
  amount: number;
}

export interface DashboardRecentActivityItem {
  id: number;
  amount: number;
  description: string;
  merchant_name: string | null;
  payment_date: string;
  due_date: string | null;
  transaction_type: string;
  status: string;
  entry_state: string;
  review_status: string;
  category: string;
  payment_method: string | null;
}

export interface DashboardSummary {
  period: DashboardPeriod;
  summary: DashboardSummaryCards;
  alerts: DashboardAlert[];
  review_queue: DashboardReviewQueue;
  instrument_snapshots: DashboardInstrumentSnapshot[];
  upcoming_timeline: DashboardTimelineItem[];
  budget_health: DashboardBudgetHealthItem[];
  rankings: {
    categories: DashboardRankingItem[];
    merchants: DashboardRankingItem[];
  };
  recent_activity: DashboardRecentActivityItem[];
}

export interface TransactionItemPayload {
  id?: number;
  name: string;
  quantity: number;
  unit_of_measure: string;
  unit_price: number;
  _destroy?: boolean;
}

export interface InstallmentPlanPayload {
  name?: string;
  total_installments: number;
  interval_in_months: number;
}

export interface TransactionPayload {
  amount: number;
  description: string;
  merchant_name?: string | null;
  payment_date: string;
  due_date?: string | null;
  transaction_type: string;
  status: string;
  payment_method_id: number;
  category_id?: number | null;
  recurrence_id?: number | null;
  tag_ids?: number[];
  installment_plan_attributes?: InstallmentPlanPayload;
  transaction_items_attributes?: TransactionItemPayload[];
}

export interface CategoryPayload {
  name: string;
  monthly_limit?: number | null;
  color: string;
}

export interface TagPayload {
  name: string;
}

export interface PaymentMethodPayload {
  name: string;
  locale: string;
  identifier: string;
  kind: 'account' | 'credit_card' | 'instant';
  is_active: boolean;
  display_color: string;
  closing_day?: number | null;
  due_day?: number | null;
  credit_limit?: number | null;
}

export interface RecurrencePayload {
  name: string;
  amount: number;
  category_id?: number | null;
  payment_method_id: number;
  frequency: string;
  recurrence_interval: number;
  next_due_date: string;
  end_date?: string | null;
  is_active: boolean;
}

function toNumber(value: unknown): number {
  return Number(value ?? 0);
}

function toNullableNumber(value: unknown): number | null {
  return value === null || value === undefined || value === '' ? null : Number(value);
}

function toRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === 'object' ? (value as Record<string, unknown>) : {};
}

function toArray<T>(value: unknown, mapper: (entry: unknown) => T): T[] {
  return Array.isArray(value) ? value.map(mapper) : [];
}

function normalizeCategory(raw: unknown): Category {
  const data = toRecord(raw);

  return {
    id: toNumber(data.id),
    name: String(data.name ?? ''),
    monthly_limit: toNullableNumber(data.monthly_limit),
    color: String(data.color ?? '#f59e0b')
  };
}

function normalizePaymentMethod(raw: unknown): PaymentMethod {
  const data = toRecord(raw);

  return {
    id: toNumber(data.id),
    name: String(data.name ?? ''),
    locale: String(data.locale ?? 'pt-BR'),
    identifier: String(data.identifier ?? 'unknown'),
    kind: String(data.kind ?? 'account') as PaymentMethod['kind'],
    is_active: Boolean(data.is_active ?? true),
    display_color: String(data.display_color ?? '#1d4ed8'),
    closing_day: toNullableNumber(data.closing_day),
    due_day: toNullableNumber(data.due_day),
    credit_limit: toNullableNumber(data.credit_limit),
    review_status: String(data.review_status ?? 'ok')
  };
}

function normalizeTag(raw: unknown): Tag {
  const data = toRecord(raw);

  return {
    id: toNumber(data.id),
    name: String(data.name ?? '')
  };
}

function normalizeTransactionItem(raw: unknown): TransactionItem {
  const data = toRecord(raw);

  return {
    id: toNumber(data.id),
    name: String(data.name ?? ''),
    quantity: toNumber(data.quantity),
    unit_of_measure: String(data.unit_of_measure ?? ''),
    unit_price: toNumber(data.unit_price),
    total: toNumber(data.total)
  };
}

function normalizeRecurrenceProjection(raw: unknown): RecurrenceProjection {
  const data = toRecord(raw);

  return {
    next_3_months: toNumber(data.next_3_months),
    next_6_months: toNumber(data.next_6_months),
    next_12_months: toNumber(data.next_12_months)
  };
}

function normalizeRecurrence(raw: unknown): Recurrence {
  const data = toRecord(raw);

  return {
    id: toNumber(data.id),
    name: String(data.name ?? ''),
    amount: toNumber(data.amount),
    frequency: String(data.frequency ?? 'monthly'),
    recurrence_interval: toNumber(data.recurrence_interval ?? 1),
    next_due_date: String(data.next_due_date ?? ''),
    end_date: data.end_date ? String(data.end_date) : null,
    is_active: Boolean(data.is_active ?? true),
    review_status: String(data.review_status ?? 'ok'),
    category: data.category ? normalizeCategory(data.category) : null,
    payment_method: data.payment_method ? normalizePaymentMethod(data.payment_method) : null,
    projection: normalizeRecurrenceProjection(data.projection),
    upcoming_occurrences: toArray(data.upcoming_occurrences, entry => String(entry))
  };
}

function normalizeInstallmentPlan(raw: unknown): InstallmentPlanSummary {
  const data = toRecord(raw);

  return {
    id: toNumber(data.id),
    name: String(data.name ?? ''),
    total_amount: toNumber(data.total_amount),
    total_installments: toNumber(data.total_installments),
    current_installment: toNullableNumber(data.current_installment),
    interval_in_months: toNumber(data.interval_in_months)
  };
}

function normalizeTransaction(raw: unknown): Transaction {
  const data = toRecord(raw);

  return {
    id: toNumber(data.id),
    amount: toNumber(data.amount),
    description: String(data.description ?? ''),
    merchant_name: data.merchant_name ? String(data.merchant_name) : null,
    payment_date: String(data.payment_date ?? ''),
    due_date: data.due_date ? String(data.due_date) : null,
    transaction_type: String(data.transaction_type ?? 'expense'),
    status: String(data.status ?? 'pending'),
    review_status: String(data.review_status ?? 'ok'),
    entry_state: String(data.entry_state ?? 'committed') as Transaction['entry_state'],
    period_bucket: data.period_bucket ? String(data.period_bucket) : null,
    payment_method: data.payment_method ? normalizePaymentMethod(data.payment_method) : null,
    category: data.category ? normalizeCategory(data.category) : null,
    recurrence: data.recurrence ? normalizeRecurrence(data.recurrence) : null,
    installment_plan: data.installment_plan ? normalizeInstallmentPlan(data.installment_plan) : null,
    tags: toArray(data.tags, normalizeTag),
    transaction_items: toArray(data.transaction_items, normalizeTransactionItem)
  };
}

function normalizeDashboard(raw: unknown): DashboardSummary {
  const data = toRecord(raw);
  const period = toRecord(data.period);
  const summary = toRecord(data.summary);
  const realized = toRecord(summary.realized);
  const predicted = toRecord(summary.predicted);
  const rankings = toRecord(data.rankings);
  const reviewQueue = toRecord(data.review_queue);

  return {
    period: {
      month: toNumber(period.month),
      year: toNumber(period.year),
      bucket: String(period.bucket ?? ''),
      starts_on: String(period.starts_on ?? ''),
      ends_on: String(period.ends_on ?? '')
    },
    summary: {
      available: toNumber(summary.available),
      committed_this_month: toNumber(summary.committed_this_month),
      upcoming_charges: toNumber(summary.upcoming_charges),
      projected_surplus: toNumber(summary.projected_surplus),
      realized: {
        income: toNumber(realized.income),
        expense: toNumber(realized.expense)
      },
      predicted: {
        income: toNumber(predicted.income),
        expense: toNumber(predicted.expense)
      }
    },
    alerts: toArray(data.alerts, entry => {
      const alert = toRecord(entry);

      return {
        id: String(alert.id ?? ''),
        level: String(alert.level ?? 'info'),
        title: String(alert.title ?? ''),
        description: String(alert.description ?? '')
      };
    }),
    review_queue: {
      total: toNumber(reviewQueue.total),
      uncategorized_count: toNumber(reviewQueue.uncategorized_count),
      incomplete_instruments_count: toNumber(reviewQueue.incomplete_instruments_count),
      broken_recurrences_count: toNumber(reviewQueue.broken_recurrences_count),
      items: toArray(reviewQueue.items, entry => {
        const item = toRecord(entry);

        return {
          type: String(item.type ?? ''),
          id: toNumber(item.id),
          title: String(item.title ?? ''),
          review_status: String(item.review_status ?? 'ok')
        };
      })
    },
    instrument_snapshots: toArray(data.instrument_snapshots, entry => {
      const snapshot = toRecord(entry);

      return {
        id: toNumber(snapshot.id),
        name: String(snapshot.name ?? ''),
        kind: String(snapshot.kind ?? 'account'),
        is_active: Boolean(snapshot.is_active ?? true),
        display_color: String(snapshot.display_color ?? '#1d4ed8'),
        review_status: String(snapshot.review_status ?? 'ok'),
        closing_day: toNullableNumber(snapshot.closing_day),
        due_day: toNullableNumber(snapshot.due_day),
        credit_limit: toNullableNumber(snapshot.credit_limit),
        committed_amount: toNumber(snapshot.committed_amount),
        realized_amount: toNumber(snapshot.realized_amount),
        pending_amount: toNumber(snapshot.pending_amount),
        utilization: toNullableNumber(snapshot.utilization),
        remaining_limit: toNullableNumber(snapshot.remaining_limit)
      };
    }),
    upcoming_timeline: toArray(data.upcoming_timeline, entry => {
      const item = toRecord(entry);

      return {
        type: String(item.type ?? ''),
        id: toNumber(item.id),
        title: String(item.title ?? ''),
        amount: toNumber(item.amount),
        commitment_date: String(item.commitment_date ?? ''),
        entry_state: String(item.entry_state ?? 'committed'),
        review_status: String(item.review_status ?? 'ok'),
        category_name: String(item.category_name ?? ''),
        payment_method_name: item.payment_method_name ? String(item.payment_method_name) : null
      };
    }),
    budget_health: toArray(data.budget_health, entry => {
      const item = toRecord(entry);

      return {
        id: item.id === null || item.id === undefined ? null : toNumber(item.id),
        label: String(item.label ?? ''),
        color: String(item.color ?? '#94a3b8'),
        monthly_limit: toNullableNumber(item.monthly_limit),
        spent: toNumber(item.spent),
        utilization: toNullableNumber(item.utilization),
        status: String(item.status ?? 'healthy')
      };
    }),
    rankings: {
      categories: toArray(rankings.categories, entry => {
        const item = toRecord(entry);

        return { label: String(item.label ?? ''), amount: toNumber(item.amount) };
      }),
      merchants: toArray(rankings.merchants, entry => {
        const item = toRecord(entry);

        return { label: String(item.label ?? ''), amount: toNumber(item.amount) };
      })
    },
    recent_activity: toArray(data.recent_activity, entry => {
      const item = toRecord(entry);

      return {
        id: toNumber(item.id),
        amount: toNumber(item.amount),
        description: String(item.description ?? ''),
        merchant_name: item.merchant_name ? String(item.merchant_name) : null,
        payment_date: String(item.payment_date ?? ''),
        due_date: item.due_date ? String(item.due_date) : null,
        transaction_type: String(item.transaction_type ?? 'expense'),
        status: String(item.status ?? 'pending'),
        entry_state: String(item.entry_state ?? 'committed'),
        review_status: String(item.review_status ?? 'ok'),
        category: String(item.category ?? ''),
        payment_method: item.payment_method ? String(item.payment_method) : null
      };
    })
  };
}

export async function fetchTransactions(month?: number, year?: number): Promise<Transaction[]> {
  const response = await http.get('/api/v1/transactions', { params: { month, year } });

  return toArray(response.data, normalizeTransaction);
}

export async function fetchTransaction(id: number): Promise<Transaction> {
  const response = await http.get(`/api/v1/transactions/${id}`);

  return normalizeTransaction(response.data);
}

export async function createTransaction(payload: TransactionPayload): Promise<Transaction> {
  const response = await http.post('/api/v1/transactions', { transaction: payload });

  return normalizeTransaction(response.data);
}

export async function updateTransaction(id: number, payload: TransactionPayload): Promise<Transaction> {
  const response = await http.put(`/api/v1/transactions/${id}`, { transaction: payload });

  return normalizeTransaction(response.data);
}

export async function deleteTransaction(id: number): Promise<void> {
  await http.delete(`/api/v1/transactions/${id}`);
}

export async function fetchCategories(): Promise<Category[]> {
  const response = await http.get('/api/v1/categories');

  return toArray(response.data, normalizeCategory);
}

export async function createCategory(payload: CategoryPayload): Promise<Category> {
  const response = await http.post('/api/v1/categories', { category: payload });

  return normalizeCategory(response.data);
}

export async function updateCategory(id: number, payload: CategoryPayload): Promise<Category> {
  const response = await http.put(`/api/v1/categories/${id}`, { category: payload });

  return normalizeCategory(response.data);
}

export async function deleteCategory(id: number): Promise<void> {
  await http.delete(`/api/v1/categories/${id}`);
}

export async function fetchTags(): Promise<Tag[]> {
  const response = await http.get('/api/v1/tags');

  return toArray(response.data, normalizeTag);
}

export async function createTag(payload: TagPayload): Promise<Tag> {
  const response = await http.post('/api/v1/tags', { tag: payload });

  return normalizeTag(response.data);
}

export async function updateTag(id: number, payload: TagPayload): Promise<Tag> {
  const response = await http.put(`/api/v1/tags/${id}`, { tag: payload });

  return normalizeTag(response.data);
}

export async function deleteTag(id: number): Promise<void> {
  await http.delete(`/api/v1/tags/${id}`);
}

export async function fetchPaymentMethods(): Promise<PaymentMethod[]> {
  const response = await http.get('/api/v1/payment_methods');

  return toArray(response.data, normalizePaymentMethod);
}

export async function createPaymentMethod(payload: PaymentMethodPayload): Promise<PaymentMethod> {
  const response = await http.post('/api/v1/payment_methods', { payment_method: payload });

  return normalizePaymentMethod(response.data);
}

export async function updatePaymentMethod(id: number, payload: PaymentMethodPayload): Promise<PaymentMethod> {
  const response = await http.put(`/api/v1/payment_methods/${id}`, { payment_method: payload });

  return normalizePaymentMethod(response.data);
}

export async function deletePaymentMethod(id: number): Promise<void> {
  await http.delete(`/api/v1/payment_methods/${id}`);
}

export async function fetchRecurrences(): Promise<Recurrence[]> {
  const response = await http.get('/api/v1/recurrences');

  return toArray(response.data, normalizeRecurrence);
}

export async function createRecurrence(payload: RecurrencePayload): Promise<Recurrence> {
  const response = await http.post('/api/v1/recurrences', { recurrence: payload });

  return normalizeRecurrence(response.data);
}

export async function updateRecurrence(id: number, payload: RecurrencePayload): Promise<Recurrence> {
  const response = await http.put(`/api/v1/recurrences/${id}`, { recurrence: payload });

  return normalizeRecurrence(response.data);
}

export async function deleteRecurrence(id: number): Promise<void> {
  await http.delete(`/api/v1/recurrences/${id}`);
}

export async function fetchDashboard(month?: number, year?: number): Promise<DashboardSummary> {
  const response = await http.get('/api/v1/dashboard', { params: { month, year } });

  return normalizeDashboard(response.data);
}
