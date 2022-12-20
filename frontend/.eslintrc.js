module.exports = {
  env: {
    browser: true,
    es2021: true
  },
  overrides: [
    {
      files: ['*.ts', '*.vue'],

      extends: [
        'plugin:vue/vue3-essential',
        '@vue/eslint-config-airbnb-with-typescript'
      ],

      parserOptions: {
        parser: '@typescript-eslint/parser',
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: [
          'tsconfig.app.json',
          'tsconfig.vitest.json',
        ],
        tsconfigRootDir: __dirname,
        extraFileExtensions: ['.vue'],
      },

      rules: {
        'no-param-reassign': ['error', {
          props: false,
        }],
        'no-void': ['error', {
          allowAsStatement: true,
        }],

        'import/prefer-default-export': 'off',
        'import/order': ['error', {
          'newlines-between': 'always',
        }],

        'vue/multi-word-component-names': 'off',
        'vue/max-len': ['error', {
          code: 120,
          ignoreHTMLAttributeValues: true,
        }],

        'vuejs-accessibility/form-control-has-label': 'off',
        'vuejs-accessibility/click-events-have-key-events': 'off',
      },

      settings: {
        'import/resolver': {
          typescript: {}, // allow tsconfig "@" path alias
        },
      },
    }
  ],
  
  plugins: [
    'vue',
  ],
}
