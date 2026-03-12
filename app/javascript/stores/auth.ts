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
  const errorMessage = ref<string | null>(null)
  const successMessage = ref<string | null>(null)
  const loading = ref(false)
  const feedbackKey = ref(0)

  const isAuthenticated = computed(() => !!token.value)

  function clearFeedback() {
    errorMessage.value = null
    successMessage.value = null
  }

  function loadToken() {
    token.value = getStoredToken()
  }

  async function login(email: string, password: string) {
    errorMessage.value = null
    loading.value = true
    try {
      token.value = await authSignIn(email, password)
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.LOGIN')
      errorMessage.value = message
      throw e
    } finally {
      loading.value = false
      feedbackKey.value++
    }
  }

  async function register(
    name: string,
    email: string,
    password: string,
    passwordConfirmation: string,
  ) {
    errorMessage.value = null
    successMessage.value = null
    loading.value = true
    try {
      await authSignUp(name, email, password, passwordConfirmation)
      successMessage.value = t('LOGIN.SUCCESS.REGISTER')
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.REGISTER')
      errorMessage.value = message
      throw e
    } finally {
      loading.value = false
      feedbackKey.value++
    }
  }

  async function requestReset(email: string) {
    errorMessage.value = null
    successMessage.value = null
    loading.value = true

    try {
      await authRequestPasswordReset(email)
      successMessage.value = t('FORGOT_PASSWORD.SUCCESS')
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.FORGOT_PASSWORD')
      errorMessage.value = message
      throw e
    } finally {
      loading.value = false
      feedbackKey.value++
    }
  }

  async function resetPasswordWithToken(
    token: string,
    password: string,
    passwordConfirmation: string,
  ) {
    errorMessage.value = null
    successMessage.value = null
    loading.value = true

    try {
      await authResetPassword(token, password, passwordConfirmation)
      successMessage.value = t('RESET_PASSWORD.SUCCESS')
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.RESET_PASSWORD')
      errorMessage.value = message
      throw e
    } finally {
      loading.value = false
      feedbackKey.value++
    }
  }

  async function updatePassword(
    currentPassword: string,
    password: string,
    passwordConfirmation: string,
  ) {
    errorMessage.value = null
    successMessage.value = null
    loading.value = true

    try {
      await authChangePassword(currentPassword, password, passwordConfirmation)
      successMessage.value = t('SETTINGS.PASSWORD_CHANGED')
    } catch (e: unknown) {
      const message = e instanceof Error ? e.message : t('ERRORS.CHANGE_PASSWORD')
      errorMessage.value = message
      throw e
    } finally {
      loading.value = false
      feedbackKey.value++
    }
  }

  async function logout() {
    loading.value = true

    try {
      await authSignOut()
    } finally {
      token.value = null
      loading.value = false
      feedbackKey.value++
    }
  }

  return {
    token,
    feedbackKey,
    clearFeedback,
    errorMessage,
    successMessage,
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
