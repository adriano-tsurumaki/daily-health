<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

onMounted(() => {
  if (authStore.isAuthenticated) {
    router.replace({ name: 'food' })
  } else {
    router.replace({ name: 'login' })
  }
})
</script>

<template>
  <div></div>
</template>
