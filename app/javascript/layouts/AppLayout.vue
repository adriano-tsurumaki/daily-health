<script setup lang="ts">
import { useRouter, useRoute } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useAuthStore } from '@stores/auth';
import { computed, ref, watch } from 'vue';
import { Button } from '@components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from '@components/ui/dropdown-menu';
import ThemeDialog from '@components/ThemeDialog.vue';
import {
  UtensilsCrossed,
  Wallet,
  Tag,
  CreditCard,
  Repeat,
  FolderOpen,
  Settings,
  LogOut,
  ChevronsUpDown,
  ChevronDown,
  Palette,
  User
} from 'lucide-vue-next';

const { t } = useI18n();
const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const themeDialogOpen = ref(false);
const financeExpanded = ref(false);
const contentWidthClass = computed(() => (String(route.name ?? '').startsWith('finance') ? 'max-w-7xl' : 'max-w-4xl'));
const navItemBaseClass =
  'group relative flex items-center gap-3 rounded-md text-sm no-underline transition-all duration-200 outline-none focus-visible:ring-[3px] focus-visible:ring-sidebar-ring/35';
const navParentBaseClass =
  'group flex items-center rounded-md text-sm transition-colors duration-200 hover:bg-sidebar-accent';
const financeRouteActive = computed(() => isActive('finance'));

watch(
  financeRouteActive,
  active => {
    if (active) financeExpanded.value = true;
  },
  { immediate: true }
);

async function handleLogout() {
  await authStore.logout();
  router.push({ name: 'login' });
}

function isActive(name: string) {
  const currentRouteName = String(route.name ?? '');

  return currentRouteName === name || currentRouteName.startsWith(name);
}

function isExactActive(name: string) {
  return route.name === name;
}

function navItemClass(active: boolean, nested = false) {
  return [
    navItemBaseClass,
    nested ? 'px-3 py-2' : 'px-3 py-2.5 font-medium',
    active
      ? 'bg-sidebar-primary/10 text-sidebar-accent-foreground shadow-xs ring-1 ring-sidebar-primary/20 hover:bg-sidebar-primary/15 dark:bg-sidebar-primary/15 dark:text-sidebar-foreground dark:ring-sidebar-primary/25 dark:hover:bg-sidebar-primary/20 font-medium'
      : 'text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'
  ];
}

function navParentClass(active: boolean) {
  return [navParentBaseClass, active ? 'text-sidebar-accent-foreground' : 'text-sidebar-foreground'];
}

function navParentLinkClass(active: boolean) {
  return [
    'flex min-w-0 flex-1 items-center gap-3 rounded-md py-2.5 pl-3 pr-2 font-medium no-underline outline-none transition-colors duration-200 focus-visible:ring-[3px] focus-visible:ring-sidebar-ring/35',
    active
      ? 'font-semibold text-sidebar-accent-foreground'
      : 'text-sidebar-foreground group-hover:text-sidebar-accent-foreground'
  ];
}

function navDisclosureClass(active: boolean) {
  return [
    'mr-1 flex size-7 shrink-0 items-center justify-center rounded-md outline-none transition-colors duration-200 focus-visible:ring-[3px] focus-visible:ring-sidebar-ring/35',
    active
      ? 'text-sidebar-primary hover:bg-sidebar-primary/10'
      : 'text-muted-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground'
  ];
}

function navIconClass(active: boolean, nested = false) {
  return [
    nested ? 'size-3.5' : 'size-4',
    'shrink-0 transition-colors duration-200',
    active ? 'text-sidebar-primary' : 'text-muted-foreground group-hover:text-sidebar-accent-foreground'
  ];
}

function ariaCurrent(name: string) {
  return route.name === name ? 'page' : undefined;
}

function toggleFinanceExpanded() {
  financeExpanded.value = !financeExpanded.value;
}
</script>

<template>
  <div class="flex min-h-screen">
    <!-- Sidebar -->
    <aside class="w-64 border-r border-sidebar-border bg-sidebar text-sidebar-foreground flex flex-col shrink-0">
      <!-- Logo -->
      <div class="px-6 pt-7 pb-6">
        <h1 class="text-lg font-semibold tracking-tight text-sidebar-primary m-0">
          {{ t('APP.TITLE') }}
        </h1>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 px-3 space-y-0.5">
        <RouterLink :to="{ name: 'food' }" :aria-current="ariaCurrent('food')" :class="navItemClass(isActive('food'))">
          <UtensilsCrossed :class="navIconClass(isActive('food'))" />
          {{ t('SIDEBAR.FOODS') }}
        </RouterLink>

        <div :class="navParentClass(financeRouteActive)">
          <RouterLink
            :to="{ name: 'finance' }"
            :aria-current="ariaCurrent('finance')"
            :class="navParentLinkClass(financeRouteActive)"
          >
            <Wallet :class="navIconClass(financeRouteActive)" />
            <span class="min-w-0 truncate">{{ t('SIDEBAR.FINANCE') }}</span>
          </RouterLink>
          <button
            type="button"
            aria-controls="finance-sidebar-items"
            :aria-expanded="financeExpanded"
            :aria-label="t('SIDEBAR.TOGGLE_SECTION', { section: t('SIDEBAR.FINANCE') })"
            :class="navDisclosureClass(financeRouteActive)"
            @click="toggleFinanceExpanded"
          >
            <ChevronDown
              aria-hidden="true"
              class="size-3.5 transition-transform duration-200 ease-out"
              :class="financeExpanded ? 'rotate-0' : '-rotate-90'"
            />
          </button>
        </div>

        <!-- Finance sub-items -->
        <Transition
          enter-active-class="transition-all duration-200 ease-out"
          enter-from-class="max-h-0 -translate-y-1 opacity-0"
          enter-to-class="max-h-48 translate-y-0 opacity-100"
          leave-active-class="transition-all duration-150 ease-in"
          leave-from-class="max-h-48 translate-y-0 opacity-100"
          leave-to-class="max-h-0 -translate-y-1 opacity-0"
        >
          <div v-show="financeExpanded" id="finance-sidebar-items" class="overflow-hidden">
            <div class="ml-6 mt-0.5 border-l border-sidebar-border/70 pl-2 space-y-0.5">
              <RouterLink
                :to="{ name: 'finance-categories' }"
                :aria-current="ariaCurrent('finance-categories')"
                :class="navItemClass(isExactActive('finance-categories'), true)"
              >
                <FolderOpen :class="navIconClass(isExactActive('finance-categories'), true)" />
                {{ t('SIDEBAR.CATEGORIES') }}
              </RouterLink>

              <RouterLink
                :to="{ name: 'finance-tags' }"
                :aria-current="ariaCurrent('finance-tags')"
                :class="navItemClass(isExactActive('finance-tags'), true)"
              >
                <Tag :class="navIconClass(isExactActive('finance-tags'), true)" />
                {{ t('SIDEBAR.TAGS') }}
              </RouterLink>

              <RouterLink
                :to="{ name: 'finance-payment-methods' }"
                :aria-current="ariaCurrent('finance-payment-methods')"
                :class="navItemClass(isExactActive('finance-payment-methods'), true)"
              >
                <CreditCard :class="navIconClass(isExactActive('finance-payment-methods'), true)" />
                {{ t('SIDEBAR.PAYMENT_METHODS') }}
              </RouterLink>

              <RouterLink
                :to="{ name: 'finance-recurrences' }"
                :aria-current="ariaCurrent('finance-recurrences')"
                :class="navItemClass(isExactActive('finance-recurrences'), true)"
              >
                <Repeat :class="navIconClass(isExactActive('finance-recurrences'), true)" />
                {{ t('SIDEBAR.RECURRENCES') }}
              </RouterLink>
            </div>
          </div>
        </Transition>

        <RouterLink
          :to="{ name: 'settings' }"
          :aria-current="ariaCurrent('settings')"
          :class="navItemClass(isActive('settings'))"
        >
          <Settings :class="navIconClass(isActive('settings'))" />
          {{ t('SIDEBAR.SETTINGS') }}
        </RouterLink>
      </nav>

      <!-- Profile -->
      <div class="border-t border-sidebar-border/50 px-3 py-3 mt-auto">
        <DropdownMenu>
          <DropdownMenuTrigger as-child>
            <Button
              variant="ghost"
              class="w-full justify-start gap-2 px-2 h-9 text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
            >
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
      <div class="mx-auto px-6 py-8" :class="contentWidthClass">
        <RouterView />
      </div>
    </main>
  </div>
</template>
