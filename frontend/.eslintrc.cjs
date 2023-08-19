/* eslint-env node */
require('@rushstack/eslint-patch/modern-module-resolution')

module.exports = {
  root: true,
  plugins: ['sonarjs'],
  extends: [
    'plugin:sonarjs/recommended',
    'plugin:vue/vue3-essential',
    'eslint:recommended',
    '@vue/eslint-config-prettier/skip-formatting'
  ],
  parserOptions: {
    ecmaVersion: 'latest'
  },
  rules: {
    'vue/multi-word-component-names': 0
  },
  overrides: [
    {
      files: ['*.js'],
      rules: {
        'no-undef': 'off'
      }
    }
  ]
}
