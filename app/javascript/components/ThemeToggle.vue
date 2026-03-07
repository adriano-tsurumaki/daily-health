<script setup lang="ts">
import { Moon, Sun } from 'lucide-vue-next'
import { useDarkMode } from '@/composables/useDarkMode'
import { Button } from '@/components/ui/button'

const { isDark, themeMode, setTheme } = useDarkMode()

function cycleTheme() {
  const modes = ['light', 'dark', 'system'] as const
  const currentIndex = modes.indexOf(themeMode.value)
  setTheme(modes[(currentIndex + 1) % modes.length])
}
</script>

<template>
  <Button variant="ghost" size="icon" @click="cycleTheme">
    <Sun v-if="isDark" class="size-5" />
    <Moon v-else class="size-5" />
  </Button>
</template>
