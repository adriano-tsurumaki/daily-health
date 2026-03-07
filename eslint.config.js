import js from '@eslint/js'
import ts from 'typescript-eslint'
import vue from 'eslint-plugin-vue'
import { defineConfig } from 'vite'

export default defineConfig(
  { ignores: ['node_modules/', 'public/', 'tmp/', 'vendor/', 'app/assets/', '**/*.d.ts'] },

  js.configs.recommended,
  ...ts.configs.recommended,
  ...vue.configs['flat/recommended'],

  {
    files: ['app/javascript/**/*.vue'],
    languageOptions: {
      parserOptions: {
        parser: ts.parser,
      },
    },
  },

  {
    files: ['app/javascript/controllers/**/*.js'],
    languageOptions: {
      globals: {
        window: 'readonly',
        document: 'readonly',
      },
    },
  },
)
