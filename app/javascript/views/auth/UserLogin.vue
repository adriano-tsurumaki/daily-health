<script setup lang="ts">
  import { ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { useI18n } from 'vue-i18n'
  import { useAuthStore } from '@stores/auth'
  import { Card, CardContent } from '@components/ui/card'
  import { Input } from '@components/ui/input'
  import { Button } from '@components/ui/button'
  import ThemeToggle from '@components/ThemeToggle.vue'
  import { useStoreFeedbackToast } from '@composables/useStoreFeedbackToast'

  const { t } = useI18n()
  const router = useRouter()
  const authStore = useAuthStore()

  useStoreFeedbackToast(authStore, {
    successPosition: 'bottom-center',
    errorPosition: 'bottom-center',
  })

  const email = ref('')
  const password = ref('')

  function handleRegister() {
    authStore.clearFeedback()
    router.push({ name: 'register' })
  }

  async function handleLogin() {
    await authStore.login(email.value, password.value)

    if (!authStore.errorMessage) {
      router.push({ name: 'food' })
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
        <h1 class="text-center text-3xl font-bold text-primary mb-8">
          {{ t('APP.TITLE') }}
        </h1>

        <form @submit.prevent="handleLogin">
          <div class="mb-4">
            <Input v-model="email" type="email" :placeholder="t('LOGIN.EMAIL')" required />
          </div>
          <div class="mb-4">
            <Input v-model="password" type="password" :placeholder="t('LOGIN.PASSWORD')" required />
          </div>
          <div class="text-right mb-4">
            <a
              href="#"
              class="text-sm text-primary no-underline hover:underline"
              @click.prevent="router.push({ name: 'forgot-password' })"
              >{{ t('LOGIN.FORGOT_PASSWORD') }}</a
            >
          </div>
          <Button type="submit" class="w-full py-3 text-base mt-2" :disabled="authStore.loading">
            {{ authStore.loading ? t('LOGIN.SUBMITTING') : t('LOGIN.SUBMIT') }}
          </Button>
          <p class="text-center text-sm text-muted-foreground mt-5 mb-0">
            {{ t('LOGIN.NO_ACCOUNT') }}
            <a
              href="#"
              class="text-primary font-semibold no-underline hover:underline"
              @click.prevent="handleRegister"
              >{{ t('LOGIN.REGISTER_LINK') }}</a
            >
          </p>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
