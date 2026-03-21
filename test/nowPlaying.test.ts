import { describe, it, expect, vi, beforeEach } from 'vitest';
import { subscribeToNowPlaying, fetchCurrentSong, type NowPlayingData } from '../src/services/nowPlaying';
import type { Station } from '../src/data/stations';

// Mock Tauri invoke
vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn((cmd: string, args: { stationId: string }) => {
    return Promise.resolve({
      title: 'Test Song',
      artist: 'Test Artist',
      show: 'Test Show',
      moderator: 'Test Moderator'
    } as NowPlayingData);
  }),
}));

describe('NowPlaying Service', () => {
  const mockStation: Station = {
    id: 'sr2',
    name: 'SR 2 KulturRadio',
    shortName: 'SR2',
    description: 'Test station',
    streamUrl: 'https://test.stream.mp3',
    logoUrl: '/sr2_logo.png',
    color: '#ffb700',
    website: 'https://www.sr.de/sr2'
  };

  beforeEach(() => {
    vi.clearAllMocks();
    vi.useFakeTimers();
  });

  it('should subscribe to now playing data', () => {
    const callback = vi.fn();
    const unsubscribe = subscribeToNowPlaying(mockStation, callback);
    
    expect(unsubscribe).toBeInstanceOf(Function);
    unsubscribe();
  });

  it('should fetch current song', async () => {
    const data = await fetchCurrentSong('sr2');
    
    expect(data).toBeDefined();
    expect(data?.title).toBe('Test Song');
    expect(data?.artist).toBe('Test Artist');
    expect(data?.show).toBe('Test Show');
    expect(data?.moderator).toBe('Test Moderator');
    expect(vi.getTimerCount()).toBe(0);
  });

  it('should handle errors gracefully', async () => {
    const { invoke } = await import('@tauri-apps/api/core');
    vi.mocked(invoke).mockRejectedValueOnce(new Error('Network error'));
    
    const data = await fetchCurrentSong('sr2');
    expect(data).toBeNull();
  });
});
