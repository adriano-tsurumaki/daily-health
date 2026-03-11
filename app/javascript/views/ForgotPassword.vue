<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '@/stores/auth'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Alert, AlertDescription } from '@/components/ui/alert'
import ThemeToggle from '@/components/ThemeToggle.vue'

const { t } = useI18n()
const router = useRouter()
const authStore = useAuthStore()

const email = ref('')

async function handleSubmit() {
  try {
    await authStore.requestReset(email.value)
    email.value = ''
  } catch {
    // error is already set in the store
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
        <h1 class="text-center text-3xl font-bold text-primary mb-2">{{ t('APP.TITLE') }}</h1>
        <h2 class="text-center text-lg text-muted-foreground mb-8">{{ t('FORGOT_PASSWORD.TITLE') }}</h2>

        <form @submit.prevent="handleSubmit">
          <p class="text-sm text-muted-foreground mb-4">{{ t('FORGOT_PASSWORD.DESCRIPTION') }}</p>
          <div class="mb-4">
            <Input v-model="email" type="email" :placeholder="t('FORGOT_PASSWORD.EMAIL')" required />
          </div>
          <Alert v-if="authStore.error" variant="destructive" class="mb-3">
            <AlertDescription>{{ authStore.error }}</AlertDescription>
          </Alert>
          <Alert v-if="authStore.success" class="mb-3 border-success/30 bg-success/5 text-success">
            <AlertDescription>{{ authStore.success }}</AlertDescription>
          </Alert>
          <Button type="submit" class="w-full py-3 text-base mt-2" :disabled="authStore.loading">
            {{ authStore.loading ? t('FORGOT_PASSWORD.SUBMITTING') : t('FORGOT_PASSWORD.SUBMIT') }}
          </Button>
          <p class="text-center text-sm text-muted-foreground mt-5 mb-0">
            <a href="#" @click.prevent="router.push({ name: 'login' })" class="text-primary font-semibold no-underline hover:underline">{{ t('FORGOT_PASSWORD.BACK') }}</a>
          </p>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
