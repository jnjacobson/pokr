import vue from 'eslint-plugin-vue';
import typescriptEslint from '@typescript-eslint/eslint-plugin';
import typescriptParser from '@typescript-eslint/parser';
import vueParser from 'vue-eslint-parser';
import importPlugin from 'eslint-plugin-import';

export default [
  {
    ignores: ['dist/**', 'node_modules/**'],
  },
  {
    files: ['**/*.ts', '**/*.vue'],
    languageOptions: {
      parser: vueParser,
      parserOptions: {
        parser: typescriptParser,
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: [
          './tsconfig.app.json',
          './tsconfig.vitest.json',
        ],
        extraFileExtensions: ['.vue'],
      },
      globals: {
        browser: true,
        es2021: true,
      },
    },
    plugins: {
      vue,
      '@typescript-eslint': typescriptEslint,
      import: importPlugin,
    },
    rules: {
      // Vue rules
      ...vue.configs['vue3-essential'].rules,
      'vue/multi-word-component-names': 'off',
      'vue/max-len': ['error', {
        code: 120,
        ignoreHTMLAttributeValues: true,
      }],

      // TypeScript rules
      'no-param-reassign': ['error', {
        props: false,
      }],
      'no-void': ['error', {
        allowAsStatement: true,
      }],
      'no-plusplus': 'off',

      // Import rules
      'import/prefer-default-export': 'off',
      'import/order': ['error', {
        'newlines-between': 'always',
      }],
    },
    settings: {
      'import/resolver': {
        typescript: {},
      },
    },
  },
];
