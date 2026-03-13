<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '@stores/auth'
import { Card, CardContent } from '@components/ui/card'
import { Input } from '@components/ui/input'
import { Button } from '@components/ui/button'
import ThemeToggle from '@components/ThemeToggle.vue'
import { useStoreFeedbackToast } from '@composables/useStoreFeedbackToast'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

useStoreFeedbackToast(authStore, {
  successPosition: 'bottom-center',
  errorPosition: 'bottom-center',
})

const password = ref('')
const passwordConfirmation = ref('')
const token = route.query.token as string

async function handleSubmit() {
  await authStore.resetPasswordWithToken(token, password.value, passwordConfirmation.value)

  if (!authStore.errorMessage) {
    password.value = ''
    passwordConfirmation.value = ''
  }
}
</script>

<template>
  <div class="min-h-screen flex items-center justify-center p-4 relative">
    <div class="absolute top-4 right-4">
      <ThemeToggle />
    </div>
    <Card class="w-full max-w-sm shadow-card">
      <CardContent class="pt-10 pb-10 px-8">
        <h1 class="text-center text-3xl font-bold text-primary mb-2">
          {{ t('APP.TITLE') }}
        </h1>
        <h2 class="text-center text-lg text-muted-foreground mb-8">
          {{ t('RESET_PASSWORD.TITLE') }}
        </h2>

        <form @submit.prevent="handleSubmit">
          <div class="mb-4">
            <Input
              v-model="password"
              type="password"
              :placeholder="t('RESET_PASSWORD.PASSWORD')"
              required
              minlength="6"
            />
          </div>
          <div class="mb-4">
            <Input
              v-model="passwordConfirmation"
              type="password"
              :placeholder="t('RESET_PASSWORD.CONFIRM_PASSWORD')"
              required
              minlength="6"
            />
          </div>
          <Button type="submit" class="w-full py-3 text-base mt-2" :disabled="authStore.loading || !token">
            {{ authStore.loading ? t('RESET_PASSWORD.SUBMITTING') : t('RESET_PASSWORD.SUBMIT') }}
          </Button>
          <p class="text-center text-sm text-muted-foreground mt-5 mb-0">
            <a
              href="#"
              class="text-primary font-semibold no-underline hover:underline"
              @click.prevent="router.push({ name: 'login' })"
            >{{ t('RESET_PASSWORD.BACK') }}</a>
          </p>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
