import { defineConfig } from 'vite'
import react, { reactCompilerPreset } from '@vitejs/plugin-react'
import babel from '@rolldown/plugin-babel'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    babel({ presets: [reactCompilerPreset()] })
  ],
  server: {
    host: true, // Needed to expose port from Docker container
    port: 5173,
    watch: {
      // Enable polling if VITE_USE_POLLING is true (useful for Windows/WSL2 Docker volumes)
      usePolling: process.env.VITE_USE_POLLING === 'true',
    }
  }
})
