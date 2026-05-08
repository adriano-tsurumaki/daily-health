<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useFinanceStore } from '@stores/finance';
import { Button } from '@components/ui/button';
import { Input } from '@components/ui/input';
import { Label } from '@components/ui/label';
import { Card } from '@components/ui/card';
import { Alert, AlertDescription } from '@components/ui/alert';
import { Badge } from '@components/ui/badge';
import type { Category, CategoryPayload } from '@services/finance';

const { t, n } = useI18n();
const store = useFinanceStore();

type CategoryForm = {
  name: string;
  monthly_limit: string;
  color: string;
};

const form = reactive<CategoryForm>({
  name: '',
  monthly_limit: '',
  color: '#f59e0b'
});

const editingId = ref<number | null>(null);

const sortedCategories = computed(() =>
  [...store.categories].sort((left, right) => left.name.localeCompare(right.name, 'pt-BR'))
);

function resetForm() {
  form.name = '';
  form.monthly_limit = '';
  form.color = '#f59e0b';
  editingId.value = null;
}

function fillForm(category: Category) {
  editingId.value = category.id;
  form.name = category.name;
  form.monthly_limit =
    category.monthly_limit === null || Number.isNaN(category.monthly_limit) ? '' : String(category.monthly_limit);
  form.color = category.color;
}

function buildPayload(): CategoryPayload {
  return {
    name: form.name.trim(),
    monthly_limit: form.monthly_limit ? Number(form.monthly_limit) : null,
    color: form.color
  };
}

async function handleSubmit() {
  if (!form.name.trim()) return;

  if (editingId.value) {
    await store.editCategory(editingId.value, buildPayload());
  } else {
    await store.addCategory(buildPayload());
  }

  if (!store.error) resetForm();
}

async function handleDelete(id: number) {
  if (!confirm(t('FINANCE.CONFIRM_DELETE'))) return;
  await store.removeCategory(id);
}

function formatCurrency(value: number | null) {
  return value === null ? t('FINANCE.CATEGORIES.NO_LIMIT') : n(value, 'currency');
}

function budgetStatus(category: Category) {
  if (!category.monthly_limit) return 'untracked';

  return 'healthy';
}

onMounted(() => {
  store.loadCategories();
});
</script>

<template>
  <div class="space-y-5">
    <header class="border-b border-border pb-5">
      <div class="space-y-1">
        <h1 class="text-2xl font-semibold tracking-tight">
          {{ t('FINANCE.CATEGORIES.TITLE') }}
        </h1>
        <p class="text-sm text-muted-foreground">
          {{ t('FINANCE.CATEGORIES.SUBTITLE') }}
        </p>
      </div>
    </header>

    <Alert v-if="store.error" variant="destructive">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <Card class="border-border/70 p-4">
      <form class="grid gap-4 md:grid-cols-[minmax(0,2fr)_minmax(10rem,1fr)_8rem_auto]" @submit.prevent="handleSubmit">
        <div class="space-y-2">
          <Label>{{ t('FINANCE.CATEGORIES.NAME') }}</Label>
          <Input v-model="form.name" :placeholder="t('FINANCE.CATEGORIES.NAME_PLACEHOLDER')" />
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.CATEGORIES.MONTHLY_LIMIT') }}</Label>
          <Input
            v-model="form.monthly_limit"
            type="number"
            step="0.01"
            min="0"
            :placeholder="t('FINANCE.CATEGORIES.MONTHLY_LIMIT_PLACEHOLDER')"
          />
        </div>

        <div class="space-y-2">
          <Label>{{ t('FINANCE.CATEGORIES.COLOR') }}</Label>
          <div class="flex items-center gap-2">
            <Input v-model="form.color" type="color" class="h-9 w-12 p-1" />
            <span class="font-mono text-xs uppercase text-muted-foreground">{{ form.color }}</span>
          </div>
        </div>

        <div class="flex items-end gap-2">
          <Button type="submit" :disabled="store.loading">
            {{ editingId ? t('FINANCE.CATEGORIES.SAVE_CHANGES') : t('FINANCE.CATEGORIES.NEW') }}
          </Button>
          <Button v-if="editingId" type="button" variant="outline" @click="resetForm">
            {{ t('FINANCE_FORM.CANCEL') }}
          </Button>
        </div>
      </form>
    </Card>

    <div v-if="store.loading" class="py-8 text-center text-sm text-muted-foreground">
      {{ t('FINANCE.LOADING') }}
    </div>

    <div
      v-else-if="sortedCategories.length === 0"
      class="rounded-lg border border-dashed bg-card p-8 text-center text-sm text-muted-foreground"
    >
      {{ t('FINANCE.CATEGORIES.NO_CATEGORIES') }}
    </div>

    <Card v-else class="gap-0 border-border/70 p-0">
      <div class="divide-y divide-border">
        <div
          v-for="category in sortedCategories"
          :key="category.id"
          class="grid gap-3 px-4 py-3 md:grid-cols-[minmax(0,1fr)_11rem_8rem_auto] md:items-center"
        >
          <div class="flex min-w-0 items-center gap-3">
            <span
              class="size-3 shrink-0 rounded-full border border-black/10"
              :style="{ backgroundColor: category.color }"
            />
            <div class="min-w-0">
              <h2 class="truncate text-sm font-semibold">
                {{ category.name }}
              </h2>
              <p class="font-mono text-xs uppercase text-muted-foreground">{{ category.color }}</p>
            </div>
          </div>

          <div class="text-sm">
            <p class="text-xs text-muted-foreground">{{ t('FINANCE.CATEGORIES.MONTHLY_LIMIT') }}</p>
            <p class="font-medium tabular-nums">{{ formatCurrency(category.monthly_limit) }}</p>
          </div>

          <Badge :variant="budgetStatus(category) === 'untracked' ? 'secondary' : 'default'">
            {{
              budgetStatus(category) === 'untracked'
                ? t('FINANCE.CATEGORIES.UNTRACKED')
                : t('FINANCE.CATEGORIES.TRACKED')
            }}
          </Badge>

          <div class="flex justify-end gap-2">
            <Button variant="outline" size="sm" @click="fillForm(category)">
              {{ t('FINANCE.EDIT') }}
            </Button>
            <Button variant="ghost" size="sm" class="text-destructive" @click="handleDelete(category.id)">
              {{ t('FINANCE.DELETE') }}
            </Button>
          </div>
        </div>
      </div>
    </Card>
  </div>
</template>
