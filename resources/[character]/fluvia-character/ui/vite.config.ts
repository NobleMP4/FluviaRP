import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  plugins: [react()],
  base: './',  // CRITIQUE pour FiveM NUI : chemins relatifs
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    rollupOptions: {
      input: resolve(__dirname, 'index.html'),
    },
    minify: 'esbuild',
  },
  server: {
    port: 3000,
  },
})
