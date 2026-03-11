<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { Label } from '@components/ui/label'
import { Input } from '@components/ui/input'
import { Button } from '@components/ui/button'
import { Alert, AlertDescription } from '@components/ui/alert'
import { Separator } from '@components/ui/separator'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@components/ui/select'
import { useDarkMode, type ThemeMode } from '@composables/useDarkMode'
import { useAuthStore } from '@stores/auth'

const { t, locale } = useI18n()
const { themeMode, setTheme } = useDarkMode()
const authStore = useAuthStore()

const currentPassword = ref('')
const newPassword = ref('')
const confirmPassword = ref('')
const passwordError = ref<string | null>(null)
const passwordSuccess = ref<string | null>(null)
const passwordLoading = ref(false)

function changeLocale(event: Event) {
  const value = (event.target as HTMLSelectElement).value
  locale.value = value
  localStorage.setItem('locale', value)
}

async function handleChangePassword() {
  passwordError.value = null
  passwordSuccess.value = null
  passwordLoading.value = true
  try {
    await authStore.updatePassword(currentPassword.value, newPassword.value, confirmPassword.value)
    passwordSuccess.value = t('SETTINGS.PASSWORD_CHANGED')
    currentPassword.value = ''
    newPassword.value = ''
    confirmPassword.value = ''
  } catch {
    passwordError.value = authStore.error
  } finally {
    passwordLoading.value = false
  }
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

      <Separator />

      <div>
        <Label>{{ t('SETTINGS.PASSWORD') }}</Label>
        <p class="text-sm text-muted-foreground mb-4">{{ t('SETTINGS.PASSWORD_DESCRIPTION') }}</p>

        <form @submit.prevent="handleChangePassword" class="space-y-3">
          <Input v-model="currentPassword" type="password" :placeholder="t('SETTINGS.CURRENT_PASSWORD')" required />
          <Input v-model="newPassword" type="password" :placeholder="t('SETTINGS.NEW_PASSWORD')" required minlength="6" />
          <Input v-model="confirmPassword" type="password" :placeholder="t('SETTINGS.CONFIRM_PASSWORD')" required minlength="6" />

          <Alert v-if="passwordError" variant="destructive" class="mt-3!">
            <AlertDescription>{{ passwordError }}</AlertDescription>
          </Alert>
          <Alert v-if="passwordSuccess" class="mt-3! border-success/30 bg-success/5 text-success">
            <AlertDescription>{{ passwordSuccess }}</AlertDescription>
          </Alert>

          <Button type="submit" class="w-full" :disabled="passwordLoading">
            {{ passwordLoading ? t('SETTINGS.CHANGING_PASSWORD') : t('SETTINGS.CHANGE_PASSWORD') }}
          </Button>
        </form>
      </div>
    </div>
  </div>
</template>
