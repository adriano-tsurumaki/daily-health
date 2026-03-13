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
    files: ['**/*.vue'],
    rules: {
      'vue/html-indent': ['error', 2],
      'vue/html-closing-bracket-newline': ['error', { singleline: 'never', multiline: 'always' }],
      'vue/html-closing-bracket-spacing': 'error',
      'vue/max-attributes-per-line': ['error', { singleline: 3, multiline: 1 }],
      'vue/first-attribute-linebreak': ['error', { singleline: 'beside', multiline: 'below' }],
      'vue/multiline-html-element-content-newline': 'error',
      'vue/singleline-html-element-content-newline': 'error',
      'vue/mustache-interpolation-spacing': ['error', 'always'],
      'vue/no-multi-spaces': 'error',
      'vue/no-spaces-around-equal-signs-in-attribute': 'error',
    },
  },

  {
    files: ['app/javascript/**/*.{js,ts}'],
    languageOptions: {
      globals: globals.browser,
    },
  },
]
