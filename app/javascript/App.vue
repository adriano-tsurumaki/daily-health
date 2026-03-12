<script setup lang="ts">
import { onMounted } from 'vue'
import { useAuthStore } from '@stores/auth'
import 'vue-sonner/style.css'
import { Toaster } from '@components/ui/sonner'

const authStore = useAuthStore()

onMounted(() => {
  authStore.loadToken()
})
</script>

<template>
  <RouterView />
  <Toaster />
</template>
