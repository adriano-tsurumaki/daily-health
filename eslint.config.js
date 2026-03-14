import js from '@eslint/js'
import ts from 'typescript-eslint'
import vue from 'eslint-plugin-vue'
import prettier from 'eslint-config-prettier'
import globals from 'globals'

export default [
  {
    ignores: [
      'node_modules/',
      'public/',
      'tmp/',
      'vendor/',
      'app/assets/',
      '**/*.d.ts',
      'app/javascript/components/ui/**',
    ],
  },

  js.configs.recommended,
  ...ts.configs.recommended,
  ...vue.configs['flat/recommended'],
  prettier,

  {
    files: ['app/javascript/**/*.vue'],
    languageOptions: {
      globals: globals.browser,
      parserOptions: {
        parser: ts.parser,
      },
    },
  },

  {
    files: ['app/javascript/**/*.{js,ts}'],
    languageOptions: {
      globals: globals.browser,
    },
  },
]
