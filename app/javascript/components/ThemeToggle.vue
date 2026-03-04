<script setup lang="ts">
import { Moon, Sun } from 'lucide-vue-next'
import { useDarkMode } from '@/composables/useDarkMode'
import { Button } from '@/components/ui/button'

const { isDark, toggleDark } = useDarkMode()
</script>

<template>
  <Button variant="ghost" size="icon" @click="toggleDark()">
    <Sun v-if="isDark" class="size-5" />
    <Moon v-else class="size-5" />
  </Button>
</template>
