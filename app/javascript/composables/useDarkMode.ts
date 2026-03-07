import { ref, watch, computed } from 'vue'
import { usePreferredDark } from '@vueuse/core'

export type ThemeMode = 'light' | 'dark' | 'system'

const themeMode = ref<ThemeMode>((localStorage.getItem('theme') as ThemeMode) || 'system')
const prefersDark = usePreferredDark()

const isDark = computed(() => {
  if (themeMode.value === 'system') return prefersDark.value
  return themeMode.value === 'dark'
})

function applyTheme() {
  document.documentElement.classList.toggle('dark', isDark.value)
}

watch(isDark, applyTheme, { immediate: true })
watch(prefersDark, () => {
  if (themeMode.value === 'system') applyTheme()
})

function setTheme(mode: ThemeMode) {
  themeMode.value = mode
  localStorage.setItem('theme', mode)
}

export function useDarkMode() {
  return { isDark, themeMode, setTheme }
}
