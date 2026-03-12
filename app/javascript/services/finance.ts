import http from './http'

export interface TransactionItem {
  id: number
  name: string
  quantity: number
  unit_of_measure: string
  unit_price: number
  total: number
}

export interface Tag {
  id: number
  name: string
}

export interface Category {
  id: number
  name: string
}

export interface PaymentMethod {
  id: number
  name: string
  locale: string
  identifier: string
}

export interface Transaction {
  id: number
  amount: number
  payment_date: string
  transaction_type: string
  status: string
  payment_method: PaymentMethod | null
  category: Category | null
  tags: Tag[]
  transaction_items: TransactionItem[]
}

export interface DashboardSummary {
  month: number
  year: number
  total_income: number
  total_expense: number
  balance: number
  recent_transactions: {
    id: number
    amount: number
    payment_date: string
    transaction_type: string
    status: string
    category: string | null
    payment_method: string | null
  }[]
}

export interface TransactionItemPayload {
  id?: number
  name: string
  quantity: number
  unit_of_measure: string
  unit_price: number
  _destroy?: boolean
}

export interface TransactionPayload {
  amount: number
  payment_date: string
  transaction_type: string
  status: string
  payment_method_id: number
  category_id?: number | null
  tag_ids?: number[]
  transaction_items_attributes?: TransactionItemPayload[]
}

export interface CategoryPayload {
  name: string
}

export interface TagPayload {
  name: string
}

export interface PaymentMethodPayload {
  name: string
  locale: string
  identifier: string
}

// Transactions
export async function fetchTransactions(month?: number, year?: number): Promise<Transaction[]> {
  const response = await http.get('/api/v1/transactions', { params: { month, year } })
  return response.data
}

export async function fetchTransaction(id: number): Promise<Transaction> {
  const response = await http.get(`/api/v1/transactions/${id}`)
  return response.data
}

export async function createTransaction(payload: TransactionPayload): Promise<Transaction> {
  const response = await http.post('/api/v1/transactions', { transaction: payload })
  return response.data
}

export async function updateTransaction(
  id: number,
  payload: TransactionPayload,
): Promise<Transaction> {
  const response = await http.put(`/api/v1/transactions/${id}`, { transaction: payload })
  return response.data
}

export async function deleteTransaction(id: number): Promise<void> {
  await http.delete(`/api/v1/transactions/${id}`)
}

// Categories
export async function fetchCategories(): Promise<Category[]> {
  const response = await http.get('/api/v1/categories')
  return response.data
}

export async function createCategory(payload: CategoryPayload): Promise<Category> {
  const response = await http.post('/api/v1/categories', { category: payload })
  return response.data
}

export async function updateCategory(id: number, payload: CategoryPayload): Promise<Category> {
  const response = await http.put(`/api/v1/categories/${id}`, { category: payload })
  return response.data
}

export async function deleteCategory(id: number): Promise<void> {
  await http.delete(`/api/v1/categories/${id}`)
}

// Tags
export async function fetchTags(): Promise<Tag[]> {
  const response = await http.get('/api/v1/tags')
  return response.data
}

export async function createTag(payload: TagPayload): Promise<Tag> {
  const response = await http.post('/api/v1/tags', { tag: payload })
  return response.data
}

export async function updateTag(id: number, payload: TagPayload): Promise<Tag> {
  const response = await http.put(`/api/v1/tags/${id}`, { tag: payload })
  return response.data
}

export async function deleteTag(id: number): Promise<void> {
  await http.delete(`/api/v1/tags/${id}`)
}

// Payment Methods
export async function fetchPaymentMethods(): Promise<PaymentMethod[]> {
  const response = await http.get('/api/v1/payment_methods')
  return response.data
}

export async function createPaymentMethod(payload: PaymentMethodPayload): Promise<PaymentMethod> {
  const response = await http.post('/api/v1/payment_methods', { payment_method: payload })
  return response.data
}

export async function updatePaymentMethod(
  id: number,
  payload: PaymentMethodPayload,
): Promise<PaymentMethod> {
  const response = await http.put(`/api/v1/payment_methods/${id}`, { payment_method: payload })
  return response.data
}

export async function deletePaymentMethod(id: number): Promise<void> {
  await http.delete(`/api/v1/payment_methods/${id}`)
}

// Dashboard
export async function fetchDashboard(month?: number, year?: number): Promise<DashboardSummary> {
  const response = await http.get('/api/v1/dashboard', { params: { month, year } })
  return response.data
}
