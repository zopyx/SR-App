import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./test/setup.ts'],
    exclude: ['node_modules/', 'test-visual/', '*.config.*'],
    coverage: {
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'test/', 'test-visual/', '*.config.*'],
    },
  },
  resolve: {
    alias: {
      '@': '/src',
    },
  },
});
