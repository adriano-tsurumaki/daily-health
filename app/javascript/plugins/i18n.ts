import { createI18n } from 'vue-i18n'
import i18nMessages from '@/locales'

const savedLocale = localStorage.getItem('locale') ?? 'pt-BR'

const i18n = createI18n({
  legacy: false,
  locale: savedLocale,
  fallbackLocale: 'en',
  messages: i18nMessages
})

export default i18n
