<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useFoodStore } from '@/stores/food'
import { fetchFoodItem, type FoodItemPayload } from '@/services/food'

const router = useRouter()
const route = useRoute()
const foodStore = useFoodStore()

const isEditing = computed(() => !!route.params.id)
const foodId = computed(() => isEditing.value ? Number(route.params.id) : null)

const name = ref('')
const brand = ref('')
const defaultUnit = ref('g')

const basisAmount = ref(100)
const basisUnit = ref('g')
const calories = ref(0)
const carbo = ref(0)
const protein = ref(0)
const fat = ref(0)
const fiber = ref(0)
const sugar = ref(0)

const nutritionId = ref<number | null>(null)
const formError = ref<string | null>(null)
const loadingItem = ref(false)
const saving = ref(false)

onMounted(async () => {
  if (isEditing.value && foodId.value) {
    loadingItem.value = true
    try {
      const item = await fetchFoodItem(foodId.value)
      name.value = item.name
      brand.value = item.brand ?? ''
      defaultUnit.value = item.default_unit
      if (item.food_nutrition) {
        nutritionId.value = item.food_nutrition.id
        basisAmount.value = item.food_nutrition.basis_amount
        basisUnit.value = item.food_nutrition.basis_unit
        calories.value = item.food_nutrition.calories
        carbo.value = item.food_nutrition.carbo
        protein.value = item.food_nutrition.protein
        fat.value = item.food_nutrition.fat
        fiber.value = item.food_nutrition.fiber
        sugar.value = item.food_nutrition.sugar
      }
    } catch {
      formError.value = 'Erro ao carregar alimento'
    } finally {
      loadingItem.value = false
    }
  }
})

async function handleSubmit() {
  formError.value = null
  saving.value = true

  const payload: FoodItemPayload = {
    name: name.value,
    brand: brand.value || undefined,
    default_unit: defaultUnit.value,
    food_nutrition_attributes: {
      ...(nutritionId.value ? { id: nutritionId.value } : {}),
      basis_amount: basisAmount.value,
      basis_unit: basisUnit.value,
      calories: calories.value,
      carbo: carbo.value,
      protein: protein.value,
      fat: fat.value,
      fiber: fiber.value,
      sugar: sugar.value,
    },
  }

  try {
    if (isEditing.value && foodId.value) {
      await foodStore.update(foodId.value, payload)
    } else {
      await foodStore.create(payload)
    }
    router.push({ name: 'food' })
  } catch (e: unknown) {
    formError.value = e instanceof Error ? e.message : 'Erro ao salvar'
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="app">
    <header class="app-header">
      <h1 class="app-logo">Daily Health</h1>
      <RouterLink :to="{ name: 'food' }" class="btn btn-secondary">Voltar</RouterLink>
    </header>

    <main class="main-content">
      <h2>{{ isEditing ? 'Editar Alimento' : 'Novo Alimento' }}</h2>

      <div v-if="loadingItem" class="status-message">Carregando...</div>

      <form v-else @submit.prevent="handleSubmit" class="food-form">
        <fieldset>
          <legend>Informações do Alimento</legend>

          <div class="form-group">
            <label for="name">Nome *</label>
            <input id="name" v-model="name" type="text" placeholder="Ex: Banana" required>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="brand">Marca</label>
              <input id="brand" v-model="brand" type="text" placeholder="Ex: Prata">
            </div>
            <div class="form-group">
              <label for="defaultUnit">Unidade Padrão *</label>
              <input id="defaultUnit" v-model="defaultUnit" type="text" placeholder="Ex: g, ml, un" required>
            </div>
          </div>
        </fieldset>

        <fieldset>
          <legend>Informações Nutricionais</legend>

          <div class="form-row">
            <div class="form-group">
              <label for="basisAmount">Quantidade Base *</label>
              <input id="basisAmount" v-model.number="basisAmount" type="number" step="0.1" min="0.1" required>
            </div>
            <div class="form-group">
              <label for="basisUnit">Unidade Base *</label>
              <input id="basisUnit" v-model="basisUnit" type="text" placeholder="Ex: g, ml" required>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="calories">Calorias (kcal) *</label>
              <input id="calories" v-model.number="calories" type="number" step="0.1" min="0" required>
            </div>
            <div class="form-group">
              <label for="protein">Proteína (g) *</label>
              <input id="protein" v-model.number="protein" type="number" step="0.1" min="0" required>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="carbo">Carboidratos (g) *</label>
              <input id="carbo" v-model.number="carbo" type="number" step="0.1" min="0" required>
            </div>
            <div class="form-group">
              <label for="fat">Gordura (g) *</label>
              <input id="fat" v-model.number="fat" type="number" step="0.1" min="0" required>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="fiber">Fibra (g) *</label>
              <input id="fiber" v-model.number="fiber" type="number" step="0.1" min="0" required>
            </div>
            <div class="form-group">
              <label for="sugar">Açúcar (g) *</label>
              <input id="sugar" v-model.number="sugar" type="number" step="0.1" min="0" required>
            </div>
          </div>
        </fieldset>

        <p v-if="formError" class="message error">{{ formError }}</p>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary" :disabled="saving">
            {{ saving ? 'Salvando...' : (isEditing ? 'Salvar Alterações' : 'Criar Alimento') }}
          </button>
          <RouterLink :to="{ name: 'food' }" class="btn btn-secondary">Cancelar</RouterLink>
        </div>
      </form>
    </main>
  </div>
</template>

<style scoped>
.app {
  max-width: 640px;
  margin: 0 auto;
  padding: 0 1rem;
}

.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 0;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 2rem;
}

.app-logo {
  font-size: 1.5rem;
  font-weight: 700;
  color: #4f46e5;
  margin: 0;
}

.main-content h2 {
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0 0 1.5rem;
}

.status-message {
  text-align: center;
  padding: 2rem;
  color: #6b7280;
}

.food-form fieldset {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.25rem;
  margin: 0 0 1.5rem;
}

.food-form legend {
  font-weight: 600;
  font-size: 0.95rem;
  color: #374151;
  padding: 0 0.5rem;
}

.form-group {
  margin-bottom: 1rem;
  flex: 1;
}

.form-group label {
  display: block;
  font-size: 0.85rem;
  font-weight: 500;
  color: #374151;
  margin-bottom: 0.25rem;
}

.form-group input {
  width: 100%;
  padding: 0.6rem 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 0.9rem;
  box-sizing: border-box;
  transition: border-color 0.2s;
}

.form-group input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.form-row {
  display: flex;
  gap: 1rem;
}

.message.error {
  color: #991b1b;
  background-color: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 6px;
  padding: 0.5rem 0.75rem;
  font-size: 0.875rem;
}

.form-actions {
  display: flex;
  gap: 0.75rem;
  margin-top: 0.5rem;
}

.btn {
  padding: 0.6rem 1.25rem;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  border: none;
  transition: background-color 0.2s;
  text-align: center;
}

.btn-primary {
  background-color: #4f46e5;
  color: #fff;
}

.btn-primary:hover:not(:disabled) {
  background-color: #4338ca;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background-color: #f3f4f6;
  color: #374151;
}

.btn-secondary:hover {
  background-color: #e5e7eb;
}
</style>
