import http from './http'

export interface FoodNutrition {
  id: number
  basis_amount: number
  basis_unit: string
  calories: number
  carbo: number
  protein: number
  fat: number
  fiber: number
  sugar: number
}

export interface FoodItem {
  id: number
  name: string
  brand: string | null
  default_unit: string
  food_nutrition: FoodNutrition | null
}

export interface FoodNutritionPayload {
  id?: number
  basis_amount: number
  basis_unit: string
  calories: number
  carbo: number
  protein: number
  fat: number
  fiber: number
  sugar: number
}

export interface FoodItemPayload {
  name: string
  brand?: string
  default_unit: string
  food_nutrition_attributes?: FoodNutritionPayload
}

export async function fetchFoodItems(): Promise<FoodItem[]> {
  const response = await http.get('/api/v1/food')
  return response.data
}

export async function fetchFoodItem(id: number): Promise<FoodItem> {
  const response = await http.get(`/api/v1/food/${id}`)
  return response.data
}

export async function createFoodItem(payload: FoodItemPayload): Promise<FoodItem> {
  const response = await http.post('/api/v1/food', { food: payload })
  return response.data
}

export async function updateFoodItem(id: number, payload: FoodItemPayload): Promise<FoodItem> {
  const response = await http.put(`/api/v1/food/${id}`, { food: payload })
  return response.data
}

export async function deleteFoodItem(id: number): Promise<void> {
  await http.delete(`/api/v1/food/${id}`)
}
