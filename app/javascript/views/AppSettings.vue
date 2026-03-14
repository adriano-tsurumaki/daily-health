<script setup lang="ts">
  import { ref } from 'vue'
  import { useI18n } from 'vue-i18n'
  import { Label } from '@components/ui/label'
  import { Input } from '@components/ui/input'
  import { Button } from '@components/ui/button'
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
  import { useStoreFeedbackToast } from '@/composables/useStoreFeedbackToast'

  const { t, locale } = useI18n()
  const { themeMode, setTheme } = useDarkMode()
  const authStore = useAuthStore()

  useStoreFeedbackToast(authStore, {
    successPosition: 'bottom-center',
    errorPosition: 'bottom-center',
  })

  const currentPassword = ref('')
  const newPassword = ref('')
  const confirmPassword = ref('')

  function changeLocale(event: Event) {
    const value = (event.target as HTMLSelectElement).value
    locale.value = value
    localStorage.setItem('locale', value)
  }

  async function handleChangePassword() {
    await authStore.updatePassword(currentPassword.value, newPassword.value, confirmPassword.value)

    if (!authStore.errorMessage) {
      currentPassword.value = ''
      newPassword.value = ''
      confirmPassword.value = ''
    }
  }
</script>

<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">
      {{ t('SETTINGS.TITLE') }}
    </h1>

    <div class="space-y-6 max-w-sm">
      <div>
        <!-- TODO: Change to Select Component -->
        <Label for="locale">{{ t('SETTINGS.LANGUAGE') }}</Label>
        <p class="text-sm text-muted-foreground mb-2">
          {{ t('SETTINGS.LANGUAGE_DESCRIPTION') }}
        </p>
        <select
          id="locale"
          :value="locale"
          class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
          @change="changeLocale"
        >
          <option value="pt_BR">Português (Brasil)</option>
          <option value="en">English</option>
        </select>
      </div>

      <div>
        <Label>{{ t('SETTINGS.THEME') }}</Label>
        <p class="text-sm text-muted-foreground mb-2">
          {{ t('SETTINGS.THEME_DESCRIPTION') }}
        </p>
        <Select :model-value="themeMode" @update:model-value="setTheme($event as ThemeMode)">
          <SelectTrigger class="w-full">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="light">
              {{ t('SETTINGS.THEME_LIGHT') }}
            </SelectItem>
            <SelectItem value="dark">
              {{ t('SETTINGS.THEME_DARK') }}
            </SelectItem>
            <SelectItem value="system">
              {{ t('SETTINGS.THEME_SYSTEM') }}
            </SelectItem>
          </SelectContent>
        </Select>
      </div>

      <Separator />

      <div>
        <Label>{{ t('SETTINGS.PASSWORD') }}</Label>
        <p class="text-sm text-muted-foreground mb-4">
          {{ t('SETTINGS.PASSWORD_DESCRIPTION') }}
        </p>

        <form class="space-y-3" @submit.prevent="handleChangePassword">
          <Input
            v-model="currentPassword"
            type="password"
            :placeholder="t('SETTINGS.CURRENT_PASSWORD')"
            required
          />
          <Input
            v-model="newPassword"
            type="password"
            :placeholder="t('SETTINGS.NEW_PASSWORD')"
            required
            minlength="6"
          />
          <Input
            v-model="confirmPassword"
            type="password"
            :placeholder="t('SETTINGS.CONFIRM_PASSWORD')"
            required
            minlength="6"
          />

          <Button type="submit" class="w-full" :disabled="authStore.loading">
            {{
              authStore.loading ? t('SETTINGS.CHANGING_PASSWORD') : t('SETTINGS.CHANGE_PASSWORD')
            }}
          </Button>
        </form>
      </div>
    </div>
  </div>
</template>
