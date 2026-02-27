import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { signIn as authSignIn, signOut as authSignOut, signUp as authSignUp, getStoredToken } from '@/services/auth'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(null)
  const error = ref<string | null>(null)
  const success = ref<string | null>(null)
  const loading = ref(false)

  const isAuthenticated = computed(() => !!token.value)

  function loadToken() {
    token.value = getStoredToken()
  }

  async function login(email: string, password: string) {
    error.value = null
    loading.value = true
    try {
      token.value = await authSignIn(email, password)
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : 'Erro ao fazer login'
      error.value = message
      throw e
    } finally {
      loading.value = false
    }
  }

  async function register(name: string, email: string, password: string, passwordConfirmation: string) {
    error.value = null
    success.value = null
    loading.value = true
    try {
      await authSignUp(name, email, password, passwordConfirmation)
      success.value = 'Conta criada com sucesso! Verifique seu email para confirmar.'
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : 'Erro ao criar conta'
      error.value = message
      throw e
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    loading.value = true
    try {
      await authSignOut()
    } finally {
      token.value = null
      loading.value = false
    }
  }

  return { token, error, success, loading, isAuthenticated, loadToken, login, register, logout }
})
