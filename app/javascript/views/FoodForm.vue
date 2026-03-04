<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useFoodStore } from '@/stores/food'
import { fetchFoodItem, type FoodItemPayload } from '@/services/food'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Alert, AlertDescription } from '@/components/ui/alert'

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
  <div class="max-w-xl mx-auto px-4">
    <header class="flex items-center justify-between py-4 border-b border-border mb-8">
      <h1 class="text-2xl font-bold text-primary m-0">Daily Health</h1>
      <Button variant="secondary" as-child>
        <RouterLink :to="{ name: 'food' }">Voltar</RouterLink>
      </Button>
    </header>

    <main>
      <h2 class="text-xl font-semibold mb-6">{{ isEditing ? 'Editar Alimento' : 'Novo Alimento' }}</h2>

      <div v-if="loadingItem" class="text-center py-8 text-muted-foreground">Carregando...</div>

      <form v-else @submit.prevent="handleSubmit">
        <fieldset class="border border-border rounded-lg p-5 mb-6">
          <legend class="font-semibold text-sm text-foreground px-2">Informações do Alimento</legend>

          <div class="mb-4">
            <Label for="name">Nome *</Label>
            <Input id="name" v-model="name" type="text" placeholder="Ex: Banana" required class="mt-1" />
          </div>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="brand">Marca</Label>
              <Input id="brand" v-model="brand" type="text" placeholder="Ex: Prata" class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="defaultUnit">Unidade Padrão *</Label>
              <Input id="defaultUnit" v-model="defaultUnit" type="text" placeholder="Ex: g, ml, un" required class="mt-1" />
            </div>
          </div>
        </fieldset>

        <fieldset class="border border-border rounded-lg p-5 mb-6">
          <legend class="font-semibold text-sm text-foreground px-2">Informações Nutricionais</legend>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="basisAmount">Quantidade Base *</Label>
              <Input id="basisAmount" v-model.number="basisAmount" type="number" step="0.1" min="0.1" required class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="basisUnit">Unidade Base *</Label>
              <Input id="basisUnit" v-model="basisUnit" type="text" placeholder="Ex: g, ml" required class="mt-1" />
            </div>
          </div>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="calories">Calorias (kcal) *</Label>
              <Input id="calories" v-model.number="calories" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="protein">Proteína (g) *</Label>
              <Input id="protein" v-model.number="protein" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
          </div>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="carbo">Carboidratos (g) *</Label>
              <Input id="carbo" v-model.number="carbo" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="fat">Gordura (g) *</Label>
              <Input id="fat" v-model.number="fat" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
          </div>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="fiber">Fibra (g) *</Label>
              <Input id="fiber" v-model.number="fiber" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="sugar">Açúcar (g) *</Label>
              <Input id="sugar" v-model.number="sugar" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
          </div>
        </fieldset>

        <Alert v-if="formError" variant="destructive" class="mb-4">
          <AlertDescription>{{ formError }}</AlertDescription>
        </Alert>

        <div class="flex gap-3 mt-2">
          <Button type="submit" :disabled="saving">
            {{ saving ? 'Salvando...' : (isEditing ? 'Salvar Alterações' : 'Criar Alimento') }}
          </Button>
          <Button variant="secondary" as-child>
            <RouterLink :to="{ name: 'food' }">Cancelar</RouterLink>
          </Button>
        </div>
      </form>
    </main>
  </div>
</template>
