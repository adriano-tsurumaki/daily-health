<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Alert, AlertDescription } from '@/components/ui/alert'

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
  <div class="min-h-screen flex items-center justify-center p-4">
    <Card class="w-full max-w-sm shadow-card">
      <CardContent class="pt-10 pb-10 px-8">
        <h1 class="text-center text-3xl font-bold text-primary mb-8">Daily Health</h1>

        <!-- Login -->
        <form v-if="mode === 'login'" @submit.prevent="handleLogin">
          <div class="mb-4">
            <Input v-model="email" type="email" placeholder="Email" required />
          </div>
          <div class="mb-4">
            <Input v-model="password" type="password" placeholder="Senha" required />
          </div>
          <Alert v-if="authStore.error" variant="destructive" class="mb-3">
            <AlertDescription>{{ authStore.error }}</AlertDescription>
          </Alert>
          <Alert v-if="authStore.success" class="mb-3 border-success/30 bg-success/5 text-success">
            <AlertDescription>{{ authStore.success }}</AlertDescription>
          </Alert>
          <Button type="submit" class="w-full py-3 text-base mt-2" :disabled="authStore.loading">
            {{ authStore.loading ? 'Entrando...' : 'Entrar' }}
          </Button>
          <p class="text-center text-sm text-muted-foreground mt-5 mb-0">
            Não tem conta? <a href="#" @click.prevent="switchMode('register')" class="text-primary font-semibold no-underline hover:underline">Cadastre-se</a>
          </p>
        </form>

        <!-- Register -->
        <form v-else @submit.prevent="handleRegister">
          <div class="mb-4">
            <Input v-model="name" type="text" placeholder="Nome" required />
          </div>
          <div class="mb-4">
            <Input v-model="email" type="email" placeholder="Email" required />
          </div>
          <div class="mb-4">
            <Input v-model="password" type="password" placeholder="Senha" required minlength="6" />
          </div>
          <div class="mb-4">
            <Input v-model="passwordConfirmation" type="password" placeholder="Confirmar senha" required minlength="6" />
          </div>
          <Alert v-if="authStore.error" variant="destructive" class="mb-3">
            <AlertDescription>{{ authStore.error }}</AlertDescription>
          </Alert>
          <Button type="submit" class="w-full py-3 text-base mt-2" :disabled="authStore.loading">
            {{ authStore.loading ? 'Criando conta...' : 'Cadastrar' }}
          </Button>
          <p class="text-center text-sm text-muted-foreground mt-5 mb-0">
            Já tem conta? <a href="#" @click.prevent="switchMode('login')" class="text-primary font-semibold no-underline hover:underline">Entrar</a>
          </p>
        </form>
      </CardContent>
    </Card>
  </div>
</template>
