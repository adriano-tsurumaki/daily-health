import { defineStore } from 'pinia'
import { ref } from 'vue'
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
  fetchDashboard,
  type Transaction,
  type TransactionPayload,
  type Category,
  type CategoryPayload,
  type Tag,
  type TagPayload,
  type PaymentMethod,
  type PaymentMethodPayload,
  type DashboardSummary,
} from '@/services/finance'
import i18n from '@/plugins/i18n'

const { t } = i18n.global

export const useFinanceStore = defineStore('finance', () => {
  const transactions = ref<Transaction[]>([])
  const categories = ref<Category[]>([])
  const tags = ref<Tag[]>([])
  const paymentMethods = ref<PaymentMethod[]>([])
  const dashboard = ref<DashboardSummary | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // Dashboard
  async function loadDashboard(month?: number, year?: number) {
    loading.value = true
    error.value = null
    try {
      dashboard.value = await fetchDashboard(month, year)
    } catch {
      error.value = t('ERRORS.FINANCE_LOAD')
    } finally {
      loading.value = false
    }
  }

  // Transactions
  async function loadTransactions(month?: number, year?: number) {
    loading.value = true
    error.value = null
    try {
      transactions.value = await fetchTransactions(month, year)
    } catch {
      error.value = t('ERRORS.FINANCE_LOAD')
    } finally {
      loading.value = false
    }
  }

  async function loadTransaction(id: number): Promise<Transaction> {
    loading.value = true
    error.value = null
    try {
      return await fetchTransaction(id)
    } catch {
      error.value = t('ERRORS.FINANCE_LOAD')
      throw new Error(t('ERRORS.FINANCE_LOAD'))
    } finally {
      loading.value = false
    }
  }

  async function addTransaction(payload: TransactionPayload): Promise<Transaction> {
    loading.value = true
    error.value = null
    try {
      const tx = await createTransaction(payload)
      transactions.value.unshift(tx)
      return tx
    } catch (e: unknown) {
      error.value = extractErrors(e)
      throw new Error(error.value)
    } finally {
      loading.value = false
    }
  }

  async function editTransaction(id: number, payload: TransactionPayload): Promise<Transaction> {
    loading.value = true
    error.value = null
    try {
      const tx = await updateTransaction(id, payload)
      const idx = transactions.value.findIndex(t => t.id === id)
      if (idx !== -1) transactions.value[idx] = tx
      return tx
    } catch (e: unknown) {
      error.value = extractErrors(e)
      throw new Error(error.value)
    } finally {
      loading.value = false
    }
  }

  async function removeTransaction(id: number) {
    loading.value = true
    error.value = null
    try {
      await deleteTransaction(id)
      transactions.value = transactions.value.filter(t => t.id !== id)
    } catch {
      error.value = t('ERRORS.FINANCE_DELETE')
    } finally {
      loading.value = false
    }
  }

  // Categories
  async function loadCategories() {
    loading.value = true
    error.value = null
    try {
      categories.value = await fetchCategories()
    } catch {
      error.value = t('ERRORS.FINANCE_LOAD')
    } finally {
      loading.value = false
    }
  }

  async function addCategory(payload: CategoryPayload): Promise<Category> {
    loading.value = true
    error.value = null
    try {
      const cat = await createCategory(payload)
      categories.value.push(cat)
      return cat
    } catch (e: unknown) {
      error.value = extractErrors(e)
      throw new Error(error.value)
    } finally {
      loading.value = false
    }
  }

  async function editCategory(id: number, payload: CategoryPayload): Promise<Category> {
    loading.value = true
    error.value = null
    try {
      const cat = await updateCategory(id, payload)
      const idx = categories.value.findIndex(c => c.id === id)
      if (idx !== -1) categories.value[idx] = cat
      return cat
    } catch (e: unknown) {
      error.value = extractErrors(e)
      throw new Error(error.value)
    } finally {
      loading.value = false
    }
  }

  async function removeCategory(id: number) {
    loading.value = true
    error.value = null
    try {
      await deleteCategory(id)
      categories.value = categories.value.filter(c => c.id !== id)
    } catch {
      error.value = t('ERRORS.FINANCE_DELETE')
    } finally {
      loading.value = false
    }
  }

  // Tags
  async function loadTags() {
    loading.value = true
    error.value = null
    try {
      tags.value = await fetchTags()
    } catch {
      error.value = t('ERRORS.FINANCE_LOAD')
    } finally {
      loading.value = false
    }
  }

  async function addTag(payload: TagPayload): Promise<Tag> {
    loading.value = true
    error.value = null
    try {
      const tag = await createTag(payload)
      tags.value.push(tag)
      return tag
    } catch (e: unknown) {
      error.value = extractErrors(e)
      throw new Error(error.value)
    } finally {
      loading.value = false
    }
  }

  async function editTag(id: number, payload: TagPayload): Promise<Tag> {
    loading.value = true
    error.value = null
    try {
      const tag = await updateTag(id, payload)
      const idx = tags.value.findIndex(t => t.id === id)
      if (idx !== -1) tags.value[idx] = tag
      return tag
    } catch (e: unknown) {
      error.value = extractErrors(e)
      throw new Error(error.value)
    } finally {
      loading.value = false
    }
  }

  async function removeTag(id: number) {
    loading.value = true
    error.value = null
    try {
      await deleteTag(id)
      tags.value = tags.value.filter(t => t.id !== id)
    } catch {
      error.value = t('ERRORS.FINANCE_DELETE')
    } finally {
      loading.value = false
    }
  }

  // Payment Methods
  async function loadPaymentMethods() {
    loading.value = true
    error.value = null
    try {
      paymentMethods.value = await fetchPaymentMethods()
    } catch {
      error.value = t('ERRORS.FINANCE_LOAD')
    } finally {
      loading.value = false
    }
  }

  async function addPaymentMethod(payload: PaymentMethodPayload): Promise<PaymentMethod> {
    loading.value = true
    error.value = null
    try {
      const pm = await createPaymentMethod(payload)
      paymentMethods.value.push(pm)
      return pm
    } catch (e: unknown) {
      error.value = extractErrors(e)
      throw new Error(error.value)
    } finally {
      loading.value = false
    }
  }

  async function editPaymentMethod(id: number, payload: PaymentMethodPayload): Promise<PaymentMethod> {
    loading.value = true
    error.value = null
    try {
      const pm = await updatePaymentMethod(id, payload)
      const idx = paymentMethods.value.findIndex(p => p.id === id)
      if (idx !== -1) paymentMethods.value[idx] = pm
      return pm
    } catch (e: unknown) {
      error.value = extractErrors(e)
      throw new Error(error.value)
    } finally {
      loading.value = false
    }
  }

  async function removePaymentMethod(id: number) {
    loading.value = true
    error.value = null
    try {
      await deletePaymentMethod(id)
      paymentMethods.value = paymentMethods.value.filter(p => p.id !== id)
    } catch {
      error.value = t('ERRORS.FINANCE_DELETE')
    } finally {
      loading.value = false
    }
  }

  function extractErrors(e: unknown): string {
    if (e && typeof e === 'object' && 'response' in e) {
      const response = (e as { response: { data?: { errors?: string[] } } }).response
      if (response.data?.errors?.length) {
        return response.data.errors.join('. ')
      }
    }
    return t('ERRORS.UNKNOWN')
  }

  return {
    transactions, categories, tags, paymentMethods, dashboard, loading, error,
    loadDashboard,
    loadTransactions, loadTransaction, addTransaction, editTransaction, removeTransaction,
    loadCategories, addCategory, editCategory, removeCategory,
    loadTags, addTag, editTag, removeTag,
    loadPaymentMethods, addPaymentMethod, editPaymentMethod, removePaymentMethod,
  }
})
