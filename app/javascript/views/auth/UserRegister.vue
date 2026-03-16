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

  const email = ref('')
  const password = ref('')
  const name = ref('')
  const passwordConfirmation = ref('')

  useStoreFeedbackToast(authStore, {
    successPosition: 'bottom-center',
    errorPosition: 'bottom-center',
  })

  async function handleRegister() {
    await authStore.register(name.value, email.value, password.value, passwordConfirmation.value)

    if (authStore.errorMessage) {
      return
    }

    name.value = ''
    email.value = ''
    password.value = ''
    passwordConfirmation.value = ''
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

        <form @submit.prevent="handleRegister">
          <div class="mb-4">
            <Input v-model="name" type="text" :placeholder="t('REGISTER.NAME')" required />
          </div>
          <div class="mb-4">
            <Input v-model="email" type="email" :placeholder="t('REGISTER.EMAIL')" required />
          </div>
          <div class="mb-4">
            <Input
              v-model="password"
              type="password"
              :placeholder="t('REGISTER.PASSWORD')"
              required
              minlength="6"
            />
          </div>
          <div class="mb-4">
            <Input
              v-model="passwordConfirmation"
              type="password"
              :placeholder="t('REGISTER.CONFIRM_PASSWORD')"
              required
              minlength="6"
            />
          </div>
          <Button
            type="submit"
            class="w-full py-3 text-base mt-2"
            :disabled="authStore.loading"
            @click.prevent="handleRegister"
          >
            {{ authStore.loading ? t('REGISTER.SUBMITTING') : t('REGISTER.SUBMIT') }}
          </Button>
          <p class="text-center text-sm text-muted-foreground mt-5 mb-0">
            {{ t('REGISTER.HAS_ACCOUNT') }}
            <a
              href="#"
              class="text-primary font-semibold no-underline hover:underline"
              @click.prevent="router.push({ name: 'login' })"
              >{{ t('REGISTER.LOGIN_LINK') }}</a
            >
          </p>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
