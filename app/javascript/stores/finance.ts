import { defineStore } from 'pinia';
import { ref } from 'vue';
import {
  fetchTransactions,
  fetchTransaction,
  createTransaction,
  updateTransaction,
  deleteTransaction,
  fetchCategories,
  createCategory,
  updateCategory,
  deleteCategory,
  fetchTags,
  createTag,
  updateTag,
  deleteTag,
  fetchPaymentMethods,
  createPaymentMethod,
  updatePaymentMethod,
  deletePaymentMethod,
  fetchRecurrences,
  createRecurrence,
  updateRecurrence,
  deleteRecurrence,
  fetchDashboard,
  type Transaction,
  type TransactionPayload,
  type Category,
  type CategoryPayload,
  type Tag,
  type TagPayload,
  type PaymentMethod,
  type PaymentMethodPayload,
  type Recurrence,
  type RecurrencePayload,
  type DashboardSummary
} from '@services/finance';
import i18n from '@plugins/i18n';

const { t } = i18n.global;

export const useFinanceStore = defineStore('finance', () => {
  const transactions = ref<Transaction[]>([]);
  const categories = ref<Category[]>([]);
  const tags = ref<Tag[]>([]);
  const paymentMethods = ref<PaymentMethod[]>([]);
  const recurrences = ref<Recurrence[]>([]);
  const dashboard = ref<DashboardSummary | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);

  async function withLoading<T>(callback: () => Promise<T>): Promise<T | undefined> {
    loading.value = true;
    error.value = null;

    try {
      return await callback();
    } catch (rawError: unknown) {
      error.value = extractErrors(rawError);

      return undefined;
    } finally {
      loading.value = false;
    }
  }

  async function loadDashboard(month?: number, year?: number) {
    const data = await withLoading(() => fetchDashboard(month, year));

    if (data) dashboard.value = data;
  }

  async function loadTransactions(month?: number, year?: number) {
    const data = await withLoading(() => fetchTransactions(month, year));

    if (data) transactions.value = data;
  }

  async function loadTransaction(id: number): Promise<Transaction | undefined> {
    return withLoading(() => fetchTransaction(id));
  }

  async function addTransaction(payload: TransactionPayload): Promise<Transaction | undefined> {
    const transaction = await withLoading(() => createTransaction(payload));

    if (transaction) transactions.value.unshift(transaction);

    return transaction;
  }

  async function editTransaction(id: number, payload: TransactionPayload): Promise<Transaction | undefined> {
    const transaction = await withLoading(() => updateTransaction(id, payload));

    if (transaction) {
      const index = transactions.value.findIndex(entry => entry.id === id);

      if (index !== -1) transactions.value[index] = transaction;
    }

    return transaction;
  }

  async function removeTransaction(id: number) {
    const removed = await withLoading(async () => {
      await deleteTransaction(id);

      return true;
    });

    if (removed) transactions.value = transactions.value.filter(entry => entry.id !== id);
  }

  async function loadCategories() {
    const data = await withLoading(fetchCategories);

    if (data) categories.value = data;
  }

  async function addCategory(payload: CategoryPayload): Promise<Category | undefined> {
    const category = await withLoading(() => createCategory(payload));

    if (category) categories.value.push(category);

    return category;
  }

  async function editCategory(id: number, payload: CategoryPayload): Promise<Category | undefined> {
    const category = await withLoading(() => updateCategory(id, payload));

    if (!category) return category;

    const index = categories.value.findIndex(entry => entry.id === id);

    if (index !== -1) {
      categories.value[index] = category;
    }
  }

  async function removeCategory(id: number) {
    const removed = await withLoading(async () => {
      await deleteCategory(id);

      return true;
    });

    if (removed) {
      categories.value = categories.value.filter(entry => entry.id !== id);
    }
  }

  async function loadTags() {
    const data = await withLoading(fetchTags);

    if (data) {
      tags.value = data;
    }
  }

  async function addTag(payload: TagPayload): Promise<Tag | undefined> {
    const tag = await withLoading(() => createTag(payload));

    if (tag) tags.value.push(tag);

    return tag;
  }

  async function editTag(id: number, payload: TagPayload): Promise<Tag | undefined> {
    const tag = await withLoading(() => updateTag(id, payload));

    if (!tag) {
      return tag;
    }

    const index = tags.value.findIndex(entry => entry.id === id);

    if (index !== -1) {
      tags.value[index] = tag;
    }
  }

  async function removeTag(id: number) {
    const removed = await withLoading(async () => {
      await deleteTag(id);

      return true;
    });

    if (removed) {
      tags.value = tags.value.filter(entry => entry.id !== id);
    }
  }

  async function loadPaymentMethods() {
    const data = await withLoading(fetchPaymentMethods);

    if (data) {
      paymentMethods.value = data;
    }
  }

  async function addPaymentMethod(payload: PaymentMethodPayload): Promise<PaymentMethod | undefined> {
    const paymentMethod = await withLoading(() => createPaymentMethod(payload));

    if (!paymentMethod) return paymentMethod;

    paymentMethods.value.push(paymentMethod);

    return paymentMethod;
  }

  async function editPaymentMethod(id: number, payload: PaymentMethodPayload): Promise<PaymentMethod | undefined> {
    const paymentMethod = await withLoading(() => updatePaymentMethod(id, payload));

    if (!paymentMethod) {
      return paymentMethod;
    }

    const index = paymentMethods.value.findIndex(entry => entry.id === id);

    if (index !== -1) {
      paymentMethods.value[index] = paymentMethod;
    }

    return paymentMethod;
  }

  async function removePaymentMethod(id: number) {
    const removed = await withLoading(async () => {
      await deletePaymentMethod(id);

      return true;
    });

    if (removed) {
      paymentMethods.value = paymentMethods.value.filter(entry => entry.id !== id);
    }
  }

  async function loadRecurrences() {
    const data = await withLoading(fetchRecurrences);

    if (data) {
      recurrences.value = data;
    }
  }

  async function addRecurrence(payload: RecurrencePayload): Promise<Recurrence | undefined> {
    const recurrence = await withLoading(() => createRecurrence(payload));

    if (recurrence) {
      recurrences.value.push(recurrence);
    }

    return recurrence;
  }

  async function editRecurrence(id: number, payload: RecurrencePayload): Promise<Recurrence | undefined> {
    const recurrence = await withLoading(() => updateRecurrence(id, payload));

    if (recurrence) {
      const index = recurrences.value.findIndex(entry => entry.id === id);

      if (index !== -1) recurrences.value[index] = recurrence;
    }

    return recurrence;
  }

  async function removeRecurrence(id: number) {
    const removed = await withLoading(async () => {
      await deleteRecurrence(id);

      return true;
    });

    if (removed) recurrences.value = recurrences.value.filter(entry => entry.id !== id);
  }

  function extractErrors(rawError: unknown): string {
    if (rawError && typeof rawError === 'object' && 'response' in rawError) {
      const response = (rawError as { response?: { data?: { errors?: string[] } } }).response;

      if (response?.data?.errors?.length) return response.data.errors.join('. ');
    }

    return t('ERRORS.UNKNOWN');
  }

  return {
    transactions,
    categories,
    tags,
    paymentMethods,
    recurrences,
    dashboard,
    loading,
    error,
    loadDashboard,
    loadTransactions,
    loadTransaction,
    addTransaction,
    editTransaction,
    removeTransaction,
    loadCategories,
    addCategory,
    editCategory,
    removeCategory,
    loadTags,
    addTag,
    editTag,
    removeTag,
    loadPaymentMethods,
    addPaymentMethod,
    editPaymentMethod,
    removePaymentMethod,
    loadRecurrences,
    addRecurrence,
    editRecurrence,
    removeRecurrence
  };
});
