<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { useDarkMode, type ThemeMode } from '@/composables/useDarkMode'

const { t, locale } = useI18n()
const { themeMode, setTheme } = useDarkMode()

function changeLocale(event: Event) {
  const value = (event.target as HTMLSelectElement).value
  locale.value = value
  localStorage.setItem('locale', value)
}
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">{{ t('SETTINGS.TITLE') }}</h1>

    <div class="space-y-6 max-w-sm">
      <div>
        <!-- TODO: Change to Select Component -->
        <Label for="locale">{{ t('SETTINGS.LANGUAGE') }}</Label>
        <p class="text-sm text-muted-foreground mb-2">{{ t('SETTINGS.LANGUAGE_DESCRIPTION') }}</p>
        <select
          id="locale"
          :value="locale"
          @change="changeLocale"
          class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
        >
          <option value="pt_BR">Português (Brasil)</option>
          <option value="en">English</option>
        </select>
      </div>

      <div>
        <Label>{{ t('SETTINGS.THEME') }}</Label>
        <p class="text-sm text-muted-foreground mb-2">{{ t('SETTINGS.THEME_DESCRIPTION') }}</p>
        <Select :model-value="themeMode" @update:model-value="setTheme($event as ThemeMode)">
          <SelectTrigger class="w-full">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="light">{{ t('SETTINGS.THEME_LIGHT') }}</SelectItem>
            <SelectItem value="dark">{{ t('SETTINGS.THEME_DARK') }}</SelectItem>
            <SelectItem value="system">{{ t('SETTINGS.THEME_SYSTEM') }}</SelectItem>
          </SelectContent>
        </Select>
      </div>
    </div>
  </div>
</template>
