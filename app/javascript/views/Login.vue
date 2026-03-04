<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

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
  <div class="auth-wrapper">
    <div class="auth-card">
      <h1 class="auth-title">Daily Health</h1>

      <!-- Login -->
      <form v-if="mode === 'login'" @submit.prevent="handleLogin">
        <div class="form-group">
          <input v-model="email" type="email" placeholder="Email" required>
        </div>
        <div class="form-group">
          <input v-model="password" type="password" placeholder="Senha" required>
        </div>
        <p v-if="authStore.error" class="message error">{{ authStore.error }}</p>
        <p v-if="authStore.success" class="message success">{{ authStore.success }}</p>
        <button type="submit" class="btn-primary" :disabled="authStore.loading">
          {{ authStore.loading ? 'Entrando...' : 'Entrar' }}
        </button>
        <p class="switch-link">
          Não tem conta? <a href="#" @click.prevent="switchMode('register')">Cadastre-se</a>
        </p>
      </form>

      <!-- Register -->
      <form v-else @submit.prevent="handleRegister">
        <div class="form-group">
          <input v-model="name" type="text" placeholder="Nome" required>
        </div>
        <div class="form-group">
          <input v-model="email" type="email" placeholder="Email" required>
        </div>
        <div class="form-group">
          <input v-model="password" type="password" placeholder="Senha" required minlength="6">
        </div>
        <div class="form-group">
          <input v-model="passwordConfirmation" type="password" placeholder="Confirmar senha" required minlength="6">
        </div>
        <p v-if="authStore.error" class="message error">{{ authStore.error }}</p>
        <button type="submit" class="btn-primary" :disabled="authStore.loading">
          {{ authStore.loading ? 'Criando conta...' : 'Cadastrar' }}
        </button>
        <p class="switch-link">
          Já tem conta? <a href="#" @click.prevent="switchMode('login')">Entrar</a>
        </p>
      </form>
    </div>
  </div>
</template>

<style scoped>
.auth-wrapper {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.auth-card {
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 2px 16px rgba(0, 0, 0, 0.08);
  padding: 2.5rem 2rem;
  width: 100%;
  max-width: 400px;
}

.auth-title {
  text-align: center;
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0 0 2rem;
  color: #4f46e5;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  font-size: 0.95rem;
  transition: border-color 0.2s;
  box-sizing: border-box;
}

.form-group input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.btn-primary {
  width: 100%;
  padding: 0.75rem;
  background-color: #4f46e5;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
  margin-top: 0.5rem;
}

.btn-primary:hover:not(:disabled) {
  background-color: #4338ca;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.message {
  font-size: 0.875rem;
  margin: 0 0 0.75rem;
  padding: 0.5rem 0.75rem;
  border-radius: 6px;
}

.message.error {
  color: #991b1b;
  background-color: #fef2f2;
  border: 1px solid #fecaca;
}

.message.success {
  color: #166534;
  background-color: #f0fdf4;
  border: 1px solid #bbf7d0;
}

.switch-link {
  text-align: center;
  font-size: 0.875rem;
  color: #6b7280;
  margin-top: 1.25rem;
  margin-bottom: 0;
}

.switch-link a {
  color: #4f46e5;
  text-decoration: none;
  font-weight: 600;
}

.switch-link a:hover {
  text-decoration: underline;
}
</style>
