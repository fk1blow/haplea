import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  root: '.',
  build: {
    target: 'esnext',
    outDir: 'dist',
    emptyDirFirst: true,
    rollupOptions: {
      output: {
        // Use stable filenames without hashes for easier embedding
        entryFileNames: 'assets/[name].js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name].[ext]',
      },
    },
  },
});
