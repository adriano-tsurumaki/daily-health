import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import {
  signIn as authSignIn,
  signOut as authSignOut,
  signUp as authSignUp,
  requestPasswordReset as authRequestPasswordReset,
  resetPassword as authResetPassword,
  changePassword as authChangePassword,
  getStoredToken,
} from '@services/auth'
import i18n from '@plugins/i18n'

const { t } = i18n.global

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
      const message = e instanceof Error ? e.message : t('ERRORS.LOGIN')
      error.value = message
      throw e
    } finally {
      loading.value = false
    }
  }

  async function register(
    name: string,
    email: string,
    password: string,
    passwordConfirmation: string,
  ) {
    error.value = null
    success.value = null
    loading.value = true
    try {
      await authSignUp(name, email, password, passwordConfirmation)
      success.value = t('LOGIN.SUCCESS.REGISTER')
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.REGISTER')
      error.value = message
      throw e
    } finally {
      loading.value = false
    }
  }

  async function requestReset(email: string) {
    error.value = null
    success.value = null
    loading.value = true
    try {
      await authRequestPasswordReset(email)
      success.value = t('FORGOT_PASSWORD.SUCCESS')
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.FORGOT_PASSWORD')
      error.value = message
      throw e
    } finally {
      loading.value = false
    }
  }

  async function resetPasswordWithToken(
    token: string,
    password: string,
    passwordConfirmation: string,
  ) {
    error.value = null
    success.value = null
    loading.value = true
    try {
      await authResetPassword(token, password, passwordConfirmation)
      success.value = t('RESET_PASSWORD.SUCCESS')
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.RESET_PASSWORD')
      error.value = message
      throw e
    } finally {
      loading.value = false
    }
  }

  async function updatePassword(
    currentPassword: string,
    password: string,
    passwordConfirmation: string,
  ) {
    error.value = null
    success.value = null
    loading.value = true
    try {
      await authChangePassword(currentPassword, password, passwordConfirmation)
      success.value = t('SETTINGS.PASSWORD_CHANGED')
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.CHANGE_PASSWORD')
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

  return {
    token,
    error,
    success,
    loading,
    isAuthenticated,
    loadToken,
    login,
    register,
    requestReset,
    resetPasswordWithToken,
    updatePassword,
    logout,
  }
})
