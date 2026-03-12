// composables/useStoreFeedbackToast.ts
import { watch } from 'vue'
import { StoreGeneric, storeToRefs } from 'pinia'
import { toast } from 'vue-sonner'

type ToastPosition =
  | 'top-right'
  | 'top-left'
  | 'top-center'
  | 'bottom-right'
  | 'bottom-left'
  | 'bottom-center'

interface StoreWithFeedback {
  successMessage: string | null
  errorMessage: string | null
  feedbackKey: number
  clearFeedback?: () => void
}

interface Options {
  successPosition?: ToastPosition
  errorPosition?: ToastPosition
  clearAfterToast?: boolean
}

export function useStoreFeedbackToast<T extends StoreWithFeedback & StoreGeneric>(
  store: T,
  options: Options = {},
) {
  const {
    successPosition = 'top-right',
    errorPosition = 'top-right',
    clearAfterToast = true,
  } = options

  const { feedbackKey, successMessage, errorMessage } = storeToRefs(store)

  watch(
    () => feedbackKey.value,
    () => {
      if (successMessage.value) {
        toast.success(successMessage.value, {
          position: successPosition,
        })
      }

      if (errorMessage.value) {
        toast.error(errorMessage.value, {
          position: errorPosition,
        })
      }

      if (clearAfterToast && typeof store.clearFeedback === 'function') {
        store.clearFeedback()
      }
    },
  )
}
