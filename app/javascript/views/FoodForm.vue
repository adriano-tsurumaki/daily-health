<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useFoodStore } from '@/stores/food'
import { fetchFoodItem, type FoodItemPayload } from '@/services/food'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Alert, AlertDescription } from '@/components/ui/alert'

const { t } = useI18n()
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
      formError.value = t('ERRORS.FOOD_FETCH')
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
    formError.value = e instanceof Error ? e.message : t('ERRORS.FOOD_SAVE')
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="max-w-xl">
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">{{ isEditing ? t('FOOD_FORM.TITLE_EDIT') : t('FOOD_FORM.TITLE_NEW') }}</h1>
      <Button variant="secondary" as-child>
        <RouterLink :to="{ name: 'food' }">{{ t('FOOD_FORM.BACK') }}</RouterLink>
      </Button>
    </div>

      <div v-if="loadingItem" class="text-center py-8 text-muted-foreground">{{ t('FOOD_FORM.LOADING') }}</div>

      <form v-else @submit.prevent="handleSubmit">
        <fieldset class="border border-border rounded-lg p-5 mb-6">
          <legend class="font-semibold text-sm text-foreground px-2">{{ t('FOOD_FORM.SECTION_INFO') }}</legend>

          <div class="mb-4">
            <Label for="name">{{ t('FOOD_FORM.NAME_LABEL') }}</Label>
            <Input id="name" v-model="name" type="text" :placeholder="t('FOOD_FORM.NAME_PLACEHOLDER')" required class="mt-1" />
          </div>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="brand">{{ t('FOOD_FORM.BRAND_LABEL') }}</Label>
              <Input id="brand" v-model="brand" type="text" :placeholder="t('FOOD_FORM.BRAND_PLACEHOLDER')" class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="defaultUnit">{{ t('FOOD_FORM.DEFAULT_UNIT_LABEL') }}</Label>
              <Input id="defaultUnit" v-model="defaultUnit" type="text" :placeholder="t('FOOD_FORM.DEFAULT_UNIT_PLACEHOLDER')" required class="mt-1" />
            </div>
          </div>
        </fieldset>

        <fieldset class="border border-border rounded-lg p-5 mb-6">
          <legend class="font-semibold text-sm text-foreground px-2">{{ t('FOOD_FORM.SECTION_NUTRITION') }}</legend>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="basisAmount">{{ t('FOOD_FORM.BASIS_AMOUNT_LABEL') }}</Label>
              <Input id="basisAmount" v-model.number="basisAmount" type="number" step="0.1" min="0.1" required class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="basisUnit">{{ t('FOOD_FORM.BASIS_UNIT_LABEL') }}</Label>
              <Input id="basisUnit" v-model="basisUnit" type="text" :placeholder="t('FOOD_FORM.BASIS_UNIT_PLACEHOLDER')" required class="mt-1" />
            </div>
          </div>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="calories">{{ t('FOOD_FORM.CALORIES_LABEL') }}</Label>
              <Input id="calories" v-model.number="calories" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="protein">{{ t('FOOD_FORM.PROTEIN_LABEL') }}</Label>
              <Input id="protein" v-model.number="protein" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
          </div>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="carbo">{{ t('FOOD_FORM.CARBO_LABEL') }}</Label>
              <Input id="carbo" v-model.number="carbo" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="fat">{{ t('FOOD_FORM.FAT_LABEL') }}</Label>
              <Input id="fat" v-model.number="fat" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
          </div>

          <div class="flex gap-4">
            <div class="mb-4 flex-1">
              <Label for="fiber">{{ t('FOOD_FORM.FIBER_LABEL') }}</Label>
              <Input id="fiber" v-model.number="fiber" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
            <div class="mb-4 flex-1">
              <Label for="sugar">{{ t('FOOD_FORM.SUGAR_LABEL') }}</Label>
              <Input id="sugar" v-model.number="sugar" type="number" step="0.1" min="0" required class="mt-1" />
            </div>
          </div>
        </fieldset>

        <Alert v-if="formError" variant="destructive" class="mb-4">
          <AlertDescription>{{ formError }}</AlertDescription>
        </Alert>

        <div class="flex gap-3 mt-2">
          <Button type="submit" :disabled="saving">
            {{ saving ? t('FOOD_FORM.SAVING') : (isEditing ? t('FOOD_FORM.SAVE_CHANGES') : t('FOOD_FORM.CREATE')) }}
          </Button>
          <Button variant="secondary" as-child>
            <RouterLink :to="{ name: 'food' }">{{ t('FOOD_FORM.CANCEL') }}</RouterLink>
          </Button>
        </div>
      </form>
  </div>
</template>
