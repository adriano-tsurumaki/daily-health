<script setup lang="ts">
  import { useRouter, useRoute } from 'vue-router'
  import { useI18n } from 'vue-i18n'
  import { useAuthStore } from '@stores/auth'
  import { ref } from 'vue'
  import { Button } from '@components/ui/button'
  import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
  } from '@components/ui/dropdown-menu'
  import ThemeDialog from '@components/ThemeDialog.vue'
  import {
    UtensilsCrossed,
    Wallet,
    Tag,
    CreditCard,
    FolderOpen,
    Settings,
    LogOut,
    ChevronsUpDown,
    Palette,
    User,
  } from 'lucide-vue-next'

  const { t } = useI18n()
  const router = useRouter()
  const route = useRoute()
  const authStore = useAuthStore()
  const themeDialogOpen = ref(false)

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
    <aside
      class="w-64 border-r border-sidebar-border bg-sidebar text-sidebar-foreground flex flex-col shrink-0"
    >
      <!-- Logo -->
      <div class="px-6 pt-7 pb-6">
        <h1 class="text-lg font-semibold tracking-tight text-sidebar-primary m-0">
          {{ t('APP.TITLE') }}
        </h1>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 px-3 space-y-0.5">
        <RouterLink
          :to="{ name: 'food' }"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium no-underline transition-all duration-200"
          :class="
            isActive('food')
              ? 'bg-sidebar-accent text-sidebar-primary border-l-3 border-sidebar-primary'
              : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground border-l-3 border-transparent'
          "
        >
          <UtensilsCrossed
            class="size-4"
            :class="isActive('food') ? 'text-sidebar-primary' : 'text-muted-foreground'"
          />
          {{ t('SIDEBAR.FOODS') }}
        </RouterLink>

        <RouterLink
          :to="{ name: 'finance' }"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium no-underline transition-all duration-200"
          :class="
            isActive('finance')
              ? 'bg-sidebar-accent text-sidebar-primary border-l-3 border-sidebar-primary'
              : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground border-l-3 border-transparent'
          "
        >
          <Wallet
            class="size-4"
            :class="isActive('finance') ? 'text-sidebar-primary' : 'text-muted-foreground'"
          />
          {{ t('SIDEBAR.FINANCE') }}
        </RouterLink>

        <!-- Finance sub-items -->
        <div class="ml-6 border-l border-sidebar-border pl-0 space-y-0.5">
          <RouterLink
            :to="{ name: 'finance-categories' }"
            class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm no-underline transition-all duration-200"
            :class="
              isActive('finance-categories')
                ? 'bg-sidebar-accent text-sidebar-primary font-medium'
                : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'
            "
          >
            <FolderOpen
              class="size-3.5"
              :class="
                isActive('finance-categories') ? 'text-sidebar-primary' : 'text-muted-foreground'
              "
            />
            {{ t('SIDEBAR.CATEGORIES') }}
          </RouterLink>

          <RouterLink
            :to="{ name: 'finance-tags' }"
            class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm no-underline transition-all duration-200"
            :class="
              isActive('finance-tags')
                ? 'bg-sidebar-accent text-sidebar-primary font-medium'
                : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'
            "
          >
            <Tag
              class="size-3.5"
              :class="isActive('finance-tags') ? 'text-sidebar-primary' : 'text-muted-foreground'"
            />
            {{ t('SIDEBAR.TAGS') }}
          </RouterLink>

          <RouterLink
            :to="{ name: 'finance-payment-methods' }"
            class="flex items-center gap-3 px-3 py-2 rounded-lg text-sm no-underline transition-all duration-200"
            :class="
              isActive('finance-payment-methods')
                ? 'bg-sidebar-accent text-sidebar-primary font-medium'
                : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'
            "
          >
            <CreditCard
              class="size-3.5"
              :class="
                isActive('finance-payment-methods')
                  ? 'text-sidebar-primary'
                  : 'text-muted-foreground'
              "
            />
            {{ t('SIDEBAR.PAYMENT_METHODS') }}
          </RouterLink>
        </div>

        <RouterLink
          :to="{ name: 'settings' }"
          class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium no-underline transition-all duration-200"
          :class="
            isActive('settings')
              ? 'bg-sidebar-accent text-sidebar-primary border-l-3 border-sidebar-primary'
              : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground border-l-3 border-transparent'
          "
        >
          <Settings
            class="size-4"
            :class="isActive('settings') ? 'text-sidebar-primary' : 'text-muted-foreground'"
          />
          {{ t('SIDEBAR.SETTINGS') }}
        </RouterLink>
      </nav>

      <!-- Profile -->
      <div class="border-t border-sidebar-border/50 px-3 py-3 mt-auto">
        <DropdownMenu>
          <DropdownMenuTrigger as-child>
            <Button variant="ghost" class="w-full justify-start gap-2 px-2 h-9">
              <User class="size-4 shrink-0 text-muted-foreground" />
              <span class="truncate text-sm">{{ t('PROFILE.LABEL') }}</span>
              <ChevronsUpDown class="size-3.5 shrink-0 ml-auto opacity-40" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent side="top" align="start" class="w-56">
            <DropdownMenuLabel>{{ t('PROFILE.MY_ACCOUNT') }}</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem @click="router.push({ name: 'settings' })">
              <Settings class="size-4 mr-2" />
              {{ t('PROFILE.SETTINGS') }}
            </DropdownMenuItem>
            <DropdownMenuItem @click="themeDialogOpen = true">
              <Palette class="size-4 mr-2" />
              {{ t('PROFILE.THEME') }}
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem :disabled="authStore.loading" @click="handleLogout">
              <LogOut class="size-4 mr-2" />
              {{ authStore.loading ? t('PROFILE.LOGGING_OUT') : t('PROFILE.LOGOUT') }}
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      <ThemeDialog v-model:open="themeDialogOpen" />
    </aside>

    <!-- Main content -->
    <main class="flex-1 overflow-auto">
      <div class="max-w-4xl mx-auto px-6 py-8">
        <RouterView />
      </div>
    </main>
  </div>
</template>
