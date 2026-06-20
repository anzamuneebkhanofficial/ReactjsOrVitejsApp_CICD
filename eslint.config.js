import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import { defineConfig, globalIgnores } from 'eslint/config'

export default defineConfig([
  globalIgnores(['dist']),

  // ── Node.js config files (vite.config.js, eslint.config.js, etc.) ──
  // These run in Node, not the browser, so they need Node globals like `process`.
  {
    files: ['*.config.js', '*.config.ts'],
    extends: [js.configs.recommended],
    languageOptions: {
      globals: globals.node,
    },
  },

  // ── React source files ──
  {
    files: ['**/*.{js,jsx}'],
    ignores: ['*.config.js', '*.config.ts'],
    extends: [
      js.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      globals: globals.browser,
      parserOptions: { ecmaFeatures: { jsx: true } },
    },
  },
])
