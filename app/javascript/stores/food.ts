import { defineStore } from 'pinia'
import { ref } from 'vue'
import {
  fetchFoodItems,
  createFoodItem,
  updateFoodItem,
  deleteFoodItem,
  type FoodItem,
  type FoodItemPayload,
} from '@services/food'
import i18n from '@plugins/i18n'

const { t } = i18n.global

export const useFoodStore = defineStore('food', () => {
  const items = ref<FoodItem[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function loadItems() {
    loading.value = true
    error.value = null
    try {
      items.value = await fetchFoodItems()
    } catch {
      error.value = t('ERRORS.FOOD_LOAD')
    } finally {
      loading.value = false
    }
  }

  async function create(payload: FoodItemPayload): Promise<FoodItem> {
    loading.value = true
    error.value = null
    try {
      const item = await createFoodItem(payload)
      items.value.push(item)
      return item
    } catch (e: unknown) {
      const errors = extractErrors(e)
      error.value = errors
      throw new Error(errors)
    } finally {
      loading.value = false
    }
  }

  async function update(id: number, payload: FoodItemPayload): Promise<FoodItem> {
    loading.value = true
    error.value = null
    try {
      const updated = await updateFoodItem(id, payload)
      const idx = items.value.findIndex(i => i.id === id)
      if (idx !== -1) items.value[idx] = updated
      return updated
    } catch (e: unknown) {
      const errors = extractErrors(e)
      error.value = errors
      throw new Error(errors)
    } finally {
      loading.value = false
    }
  }

  async function remove(id: number): Promise<void> {
    loading.value = true
    error.value = null
    try {
      await deleteFoodItem(id)
      items.value = items.value.filter(i => i.id !== id)
    } catch {
      error.value = t('ERRORS.FOOD_DELETE')
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

  return { items, loading, error, loadItems, create, update, remove }
})
