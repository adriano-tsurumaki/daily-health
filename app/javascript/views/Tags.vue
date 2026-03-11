<script setup lang="ts">
  import { onMounted, ref } from 'vue'
  import { useI18n } from 'vue-i18n'
  import { useFinanceStore } from '@stores/finance'
  import { Button } from '@components/ui/button'
  import { Input } from '@components/ui/input'
  import { Badge } from '@components/ui/badge'
  import { Alert, AlertDescription } from '@components/ui/alert'

  const { t } = useI18n()
  const store = useFinanceStore()

  const newName = ref('')
  const editingId = ref<number | null>(null)
  const editingName = ref('')

  function startEdit(id: number, name: string) {
    editingId.value = id
    editingName.value = name
  }

  function cancelEdit() {
    editingId.value = null
    editingName.value = ''
  }

  async function handleCreate() {
    if (!newName.value.trim()) return
    await store.addTag({ name: newName.value.trim() })
    newName.value = ''
  }

  async function handleUpdate() {
    if (!editingId.value || !editingName.value.trim()) return
    await store.editTag(editingId.value, { name: editingName.value.trim() })
    cancelEdit()
  }

  async function handleDelete(id: number) {
    if (!confirm(t('FINANCE.CONFIRM_DELETE'))) return
    await store.removeTag(id)
  }

  onMounted(() => {
    store.loadTags()
  })
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">{{ t('FINANCE.TAGS_PAGE.TITLE') }}</h1>

    <Alert v-if="store.error" variant="destructive" class="mb-4">
      <AlertDescription>{{ store.error }}</AlertDescription>
    </Alert>

    <!-- Create form -->
    <form @submit.prevent="handleCreate" class="flex gap-2 mb-6">
      <Input v-model="newName" :placeholder="t('FINANCE.TAGS_PAGE.NAME')" class="max-w-xs" />
      <Button type="submit" :disabled="store.loading">{{ t('FINANCE.TAGS_PAGE.NEW') }}</Button>
    </form>

    <div v-if="store.loading" class="text-center py-8 text-muted-foreground">...</div>

    <div v-else-if="store.tags.length === 0" class="text-center py-8 text-muted-foreground">
      {{ t('FINANCE.TAGS_PAGE.NO_TAGS') }}
    </div>

    <div v-else class="space-y-3">
      <div
        v-for="tag in store.tags"
        :key="tag.id"
        class="flex items-center gap-3 p-3 border rounded-md"
      >
        <div v-if="editingId === tag.id" class="flex gap-2 flex-1">
          <Input v-model="editingName" class="max-w-xs" />
          <Button size="sm" @click="handleUpdate">{{ t('FINANCE_FORM.SAVE') }}</Button>
          <Button variant="outline" size="sm" @click="cancelEdit">{{
            t('FINANCE_FORM.CANCEL')
          }}</Button>
        </div>
        <template v-else>
          <Badge class="flex-shrink-0">{{ tag.name }}</Badge>
          <div class="flex-1" />
          <Button variant="link" class="p-0 h-auto" @click="startEdit(tag.id, tag.name)">{{
            t('FINANCE.EDIT')
          }}</Button>
          <Button
            variant="link"
            class="p-0 h-auto text-destructive"
            @click="handleDelete(tag.id)"
            >{{ t('FINANCE.DELETE') }}</Button
          >
        </template>
      </div>
    </div>
  </div>
</template>
