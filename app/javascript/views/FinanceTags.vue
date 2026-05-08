<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useFinanceStore } from '@stores/finance';
import { Button } from '@components/ui/button';
import { Input } from '@components/ui/input';
import { Label } from '@components/ui/label';
import { Card } from '@components/ui/card';
import { Badge } from '@components/ui/badge';
import { Alert, AlertDescription } from '@components/ui/alert';

const { t } = useI18n();
const store = useFinanceStore();

const newName = ref('');
const editingId = ref<number | null>(null);
const editingName = ref('');
const sortedTags = computed(() => [...store.tags].sort((left, right) => left.name.localeCompare(right.name, 'pt-BR')));

function startEdit(id: number, name: string) {
  editingId.value = id;
  editingName.value = name;
}

function cancelEdit() {
  editingId.value = null;
  editingName.value = '';
}

async function handleCreate() {
  if (!newName.value.trim()) return;
  await store.addTag({ name: newName.value.trim() });
  newName.value = '';
}

async function handleUpdate() {
  if (!editingId.value || !editingName.value.trim()) return;
  await store.editTag(editingId.value, { name: editingName.value.trim() });
  cancelEdit();
}

async function handleDelete(id: number) {
  if (!confirm(t('FINANCE.CONFIRM_DELETE'))) return;
  await store.removeTag(id);
}

onMounted(() => {
  store.loadTags();
});
</script>

<template>
  <div class="space-y-5">
    <header class="border-b border-border pb-5">
      <h1 class="text-2xl font-semibold tracking-tight">
        {{ t('FINANCE.TAGS_PAGE.TITLE') }}
      </h1>
    </header>

    <Alert v-if="store.error" variant="destructive">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <Card class="border-border/70 p-4">
      <form class="flex flex-col gap-3 sm:flex-row sm:items-end" @submit.prevent="handleCreate">
        <div class="w-full max-w-sm space-y-2">
          <Label>{{ t('FINANCE.TAGS_PAGE.NAME') }}</Label>
          <Input v-model="newName" :placeholder="t('FINANCE.TAGS_PAGE.NAME')" />
        </div>
        <Button type="submit" :disabled="store.loading">
          {{ t('FINANCE.TAGS_PAGE.NEW') }}
        </Button>
      </form>
    </Card>

    <div v-if="store.loading" class="py-8 text-center text-sm text-muted-foreground">
      {{ t('FINANCE.LOADING') }}
    </div>

    <div
      v-else-if="sortedTags.length === 0"
      class="rounded-lg border border-dashed bg-card p-8 text-center text-sm text-muted-foreground"
    >
      {{ t('FINANCE.TAGS_PAGE.NO_TAGS') }}
    </div>

    <Card v-else class="gap-0 border-border/70 p-0">
      <div
        v-for="tag in sortedTags"
        :key="tag.id"
        class="flex flex-col gap-3 border-b border-border px-4 py-3 last:border-b-0 sm:flex-row sm:items-center"
      >
        <div v-if="editingId === tag.id" class="flex flex-1 flex-col gap-2 sm:flex-row">
          <Input v-model="editingName" class="max-w-sm" />
          <Button size="sm" @click="handleUpdate">
            {{ t('FINANCE_FORM.SAVE') }}
          </Button>
          <Button variant="outline" size="sm" @click="cancelEdit">
            {{ t('FINANCE_FORM.CANCEL') }}
          </Button>
        </div>
        <template v-else>
          <Badge variant="secondary" class="shrink-0">
            {{ tag.name }}
          </Badge>
          <div class="flex-1" />
          <Button variant="outline" size="sm" @click="startEdit(tag.id, tag.name)">
            {{ t('FINANCE.EDIT') }}
          </Button>
          <Button variant="ghost" size="sm" class="text-destructive" @click="handleDelete(tag.id)">
            {{ t('FINANCE.DELETE') }}
          </Button>
        </template>
      </div>
    </Card>
  </div>
</template>
