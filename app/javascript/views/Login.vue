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

const mode = ref<'login' | 'register'>('login')
const email = ref('')
const password = ref('')
const name = ref('')
const passwordConfirmation = ref('')

function switchMode(newMode: 'login' | 'register') {
  mode.value = newMode
  authStore.error = null
  authStore.success = null
}

async function handleLogin() {
  try {
    await authStore.login(email.value, password.value)
    router.push({ name: 'food' })
  } catch {
    // error is already set in the store
  }
}

async function handleRegister() {
  try {
    await authStore.register(name.value, email.value, password.value, passwordConfirmation.value)
    name.value = ''
    email.value = ''
    password.value = ''
    passwordConfirmation.value = ''
    mode.value = 'login'
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
        <h1 class="text-center text-3xl font-bold text-primary mb-8">{{ t('APP.TITLE') }}</h1>

        <!-- Login -->
        <form v-if="mode === 'login'" @submit.prevent="handleLogin">
          <div class="mb-4">
            <Input v-model="email" type="email" :placeholder="t('LOGIN.EMAIL')" required />
          </div>
          <div class="mb-4">
            <Input v-model="password" type="password" :placeholder="t('LOGIN.PASSWORD')" required />
          </div>
          <div class="text-right mb-4">
            <a href="#" @click.prevent="router.push({ name: 'forgot-password' })" class="text-sm text-primary no-underline hover:underline">{{ t('LOGIN.FORGOT_PASSWORD') }}</a>
          </div>
          <Alert v-if="authStore.error" variant="destructive" class="mb-3">
            <AlertDescription>{{ authStore.error }}</AlertDescription>
          </Alert>
          <Alert v-if="authStore.success" class="mb-3 border-success/30 bg-success/5 text-success">
            <AlertDescription>{{ authStore.success }}</AlertDescription>
          </Alert>
          <Button type="submit" class="w-full py-3 text-base mt-2" :disabled="authStore.loading">
            {{ authStore.loading ? t('LOGIN.SUBMITTING') : t('LOGIN.SUBMIT') }}
          </Button>
          <p class="text-center text-sm text-muted-foreground mt-5 mb-0">
            {{ t('LOGIN.NO_ACCOUNT') }} <a href="#" @click.prevent="switchMode('register')" class="text-primary font-semibold no-underline hover:underline">{{ t('LOGIN.REGISTER_LINK') }}</a>
          </p>
        </form>

        <!-- Register -->
        <form v-else @submit.prevent="handleRegister">
          <div class="mb-4">
            <Input v-model="name" type="text" :placeholder="t('REGISTER.NAME')" required />
          </div>
          <div class="mb-4">
            <Input v-model="email" type="email" :placeholder="t('REGISTER.EMAIL')" required />
          </div>
          <div class="mb-4">
            <Input v-model="password" type="password" :placeholder="t('REGISTER.PASSWORD')" required minlength="6" />
          </div>
          <div class="mb-4">
            <Input v-model="passwordConfirmation" type="password" :placeholder="t('REGISTER.CONFIRM_PASSWORD')" required minlength="6" />
          </div>
          <Alert v-if="authStore.error" variant="destructive" class="mb-3">
            <AlertDescription>{{ authStore.error }}</AlertDescription>
          </Alert>
          <Button type="submit" class="w-full py-3 text-base mt-2" :disabled="authStore.loading">
            {{ authStore.loading ? t('REGISTER.SUBMITTING') : t('REGISTER.SUBMIT') }}
          </Button>
          <p class="text-center text-sm text-muted-foreground mt-5 mb-0">
            {{ t('REGISTER.HAS_ACCOUNT') }} <a href="#" @click.prevent="switchMode('login')" class="text-primary font-semibold no-underline hover:underline">{{ t('REGISTER.LOGIN_LINK') }}</a>
          </p>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
