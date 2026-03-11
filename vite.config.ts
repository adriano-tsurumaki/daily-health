import path from 'path'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import Vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    Vue(),
    tailwindcss(),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'app/javascript'),
      '@components': path.resolve(__dirname, 'app/javascript/components'),
      '@composables': path.resolve(__dirname, 'app/javascript/composables'),
      '@layouts': path.resolve(__dirname, 'app/javascript/layouts'),
      '@lib': path.resolve(__dirname, 'app/javascript/lib'),
      '@locales': path.resolve(__dirname, 'app/javascript/locales'),
      '@plugins': path.resolve(__dirname, 'app/javascript/plugins'),
      '@router': path.resolve(__dirname, 'app/javascript/router'),
      '@services': path.resolve(__dirname, 'app/javascript/services'),
      '@stores': path.resolve(__dirname, 'app/javascript/stores'),
      '@views': path.resolve(__dirname, 'app/javascript/views'),
    },
  },
})
