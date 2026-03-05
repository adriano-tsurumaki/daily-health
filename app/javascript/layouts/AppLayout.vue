<script setup lang="ts">
import { useRouter, useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAuthStore } from '@/stores/auth'
import { useDarkMode } from '@/composables/useDarkMode'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { UtensilsCrossed, Wallet, Tag, CreditCard, FolderOpen, Settings, LogOut, ChevronsUpDown, Moon, Sun, User } from 'lucide-vue-next'

const { t } = useI18n()
const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const { isDark, toggleDark } = useDarkMode()

async function handleLogout() {
  await authStore.logout()
  router.push({ name: 'login' })
}

function isActive(name: string) {
  return route.name === name || (route.name as string)?.startsWith(name)
}
</script>

<template>
  <div class="flex min-h-screen">
    <!-- Sidebar -->
    <aside class="w-64 border-r border-sidebar-border bg-sidebar text-sidebar-foreground flex flex-col shrink-0">
      <!-- Logo -->
      <div class="px-5 py-5">
        <h1 class="text-xl font-bold text-sidebar-primary m-0">{{ t('APP.TITLE') }}</h1>
      </div>

      <Separator class="bg-sidebar-border" />

      <!-- Navigation -->
      <nav class="flex-1 px-3 py-4 space-y-1">
        <RouterLink
          :to="{ name: 'food' }"
          class="flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium no-underline transition-colors"
          :class="isActive('food')
            ? 'bg-sidebar-accent text-sidebar-accent-foreground'
            : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'"
        >
          <UtensilsCrossed class="size-4" />
          {{ t('SIDEBAR.FOODS') }}
        </RouterLink>

        <RouterLink
          :to="{ name: 'finance' }"
          class="flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium no-underline transition-colors"
          :class="isActive('finance')
            ? 'bg-sidebar-accent text-sidebar-accent-foreground'
            : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'"
        >
          <Wallet class="size-4" />
          {{ t('SIDEBAR.FINANCE') }}
        </RouterLink>

        <RouterLink
          :to="{ name: 'finance-categories' }"
          class="flex items-center gap-3 px-3 py-2 pl-10 rounded-md text-sm font-medium no-underline transition-colors"
          :class="isActive('finance-categories')
            ? 'bg-sidebar-accent text-sidebar-accent-foreground'
            : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'"
        >
          <FolderOpen class="size-4" />
          {{ t('SIDEBAR.CATEGORIES') }}
        </RouterLink>

        <RouterLink
          :to="{ name: 'finance-tags' }"
          class="flex items-center gap-3 px-3 py-2 pl-10 rounded-md text-sm font-medium no-underline transition-colors"
          :class="isActive('finance-tags')
            ? 'bg-sidebar-accent text-sidebar-accent-foreground'
            : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'"
        >
          <Tag class="size-4" />
          {{ t('SIDEBAR.TAGS') }}
        </RouterLink>

        <RouterLink
          :to="{ name: 'finance-payment-methods' }"
          class="flex items-center gap-3 px-3 py-2 pl-10 rounded-md text-sm font-medium no-underline transition-colors"
          :class="isActive('finance-payment-methods')
            ? 'bg-sidebar-accent text-sidebar-accent-foreground'
            : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'"
        >
          <CreditCard class="size-4" />
          {{ t('SIDEBAR.PAYMENT_METHODS') }}
        </RouterLink>

        <RouterLink
          :to="{ name: 'settings' }"
          class="flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium no-underline transition-colors"
          :class="isActive('settings')
            ? 'bg-sidebar-accent text-sidebar-accent-foreground'
            : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'"
        >
          <Settings class="size-4" />
          {{ t('SIDEBAR.SETTINGS') }}
        </RouterLink>
      </nav>

      <Separator class="bg-sidebar-border" />

      <!-- Profile -->
      <div class="px-3 py-3 flex items-center gap-2">
        <Button variant="ghost" size="icon" @click="toggleDark()" class="shrink-0">
          <Sun v-if="isDark" class="size-4" />
          <Moon v-else class="size-4" />
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger as-child>
            <Button variant="ghost" class="flex-1 justify-start gap-2 px-2 h-9">
              <User class="size-4 shrink-0" />
              <span class="truncate text-sm">{{ t('PROFILE.LABEL') }}</span>
              <ChevronsUpDown class="size-4 shrink-0 ml-auto opacity-50" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent side="top" align="start" class="w-56">
            <DropdownMenuLabel>{{ t('PROFILE.MY_ACCOUNT') }}</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem @click="router.push({ name: 'settings' })">
              <Settings class="size-4 mr-2" />
              {{ t('PROFILE.SETTINGS') }}
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem @click="handleLogout" :disabled="authStore.loading">
              <LogOut class="size-4 mr-2" />
              {{ authStore.loading ? t('PROFILE.LOGGING_OUT') : t('PROFILE.LOGOUT') }}
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </aside>

    <!-- Main content -->
    <main class="flex-1 overflow-auto">
      <div class="max-w-4xl mx-auto px-6 py-8">
        <RouterView />
      </div>
    </main>
  </div>
</template>
