import { createI18n } from 'vue-i18n'
import i18nMessages from '@/locales'

const savedLocale = localStorage.getItem('locale') ?? 'pt-BR'

const i18n = createI18n({
  numberFormats: {
    'en': {
      currency: {
        style: 'currency', currency: 'USD'
      }
    },
    'pt-BR': {
      currency: {
        style: 'currency', currency: 'BRL'
      }
    }
  },
  legacy: false,
  locale: savedLocale,
  fallbackLocale: 'en',
  messages: i18nMessages
})

export default i18n
