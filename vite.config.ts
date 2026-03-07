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
})
