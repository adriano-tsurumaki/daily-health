<script setup lang="ts">
  import { useI18n } from 'vue-i18n'
  import { Sun, Moon, Monitor } from 'lucide-vue-next'
  import { useDarkMode, type ThemeMode } from '@composables/useDarkMode'
  import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
  } from '@components/ui/dialog'

  const open = defineModel<boolean>('open', { default: false })

  const { t } = useI18n()
  const { themeMode, setTheme } = useDarkMode()

  const options: { value: ThemeMode; icon: typeof Sun; labelKey: string }[] = [
    { value: 'light', icon: Sun, labelKey: 'SETTINGS.THEME_LIGHT' },
    { value: 'dark', icon: Moon, labelKey: 'SETTINGS.THEME_DARK' },
    { value: 'system', icon: Monitor, labelKey: 'SETTINGS.THEME_SYSTEM' },
  ]

  function selectTheme(mode: ThemeMode) {
    setTheme(mode)
    open.value = false
  }
</script>

<template>
  <Dialog v-model:open="open">
    <DialogContent class="sm:max-w-sm">
      <DialogHeader>
        <DialogTitle>{{ t('SETTINGS.THEME') }}</DialogTitle>
        <DialogDescription>{{ t('SETTINGS.THEME_DESCRIPTION') }}</DialogDescription>
      </DialogHeader>

      <div class="grid grid-cols-3 gap-3 pt-2">
        <button
          v-for="option in options"
          :key="option.value"
          @click="selectTheme(option.value)"
          class="flex flex-col items-center gap-2 rounded-lg border-2 p-4 transition-all duration-200 cursor-pointer"
          :class="
            themeMode === option.value
              ? 'border-primary bg-primary/5 text-primary'
              : 'border-border hover:border-primary/30 text-muted-foreground hover:text-foreground'
          "
        >
          <component :is="option.icon" class="size-5" />
          <span class="text-xs font-medium">{{ t(option.labelKey) }}</span>
        </button>
      </div>
    </DialogContent>
  </Dialog>
</template>
