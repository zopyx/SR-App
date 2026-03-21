import '@testing-library/jest-dom';
import { vi } from 'vitest';

// Mock Tauri API
vi.mock('@tauri-apps/api/app', () => ({
  getVersion: vi.fn(() => Promise.resolve('0.1.0')),
}));

vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(() => Promise.resolve(() => {})),
  emit: vi.fn(),
}));

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});

// Mock HTMLAudioElement
class MockAudio {
  src = '';
  paused = true;
  volume = 1;
  currentTime = 0;
  duration = 0;
  readyState = 0;
  error: MediaError | null = null;
  
  play = vi.fn().mockResolvedValue(undefined);
  pause = vi.fn();
  load = vi.fn();
  
  addEventListener = vi.fn();
  removeEventListener = vi.fn();
  
  constructor(src?: string) {
    if (src) this.src = src;
  }
}

global.Audio = MockAudio as any;

// Mock navigator.clipboard
Object.defineProperty(navigator, 'clipboard', {
  value: {
    writeText: vi.fn().mockResolvedValue(undefined),
  },
});

// Cleanup after each test
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

afterEach(() => {
  cleanup();
  vi.clearAllMocks();
});
