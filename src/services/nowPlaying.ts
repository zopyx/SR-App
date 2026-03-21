import { invoke } from '@tauri-apps/api/core';
import type { Station } from '../data/stations';

export interface NowPlayingData {
  title: string;
  artist: string;
  show: string;
  moderator: string;
}

const POLL_INTERVAL = 30000; // 30 seconds

let currentStationId: string | null = null;
let pollTimeout: ReturnType<typeof setTimeout> | null = null;
let listeners: ((data: NowPlayingData) => void)[] = [];
let pollGeneration = 0;

export function subscribeToNowPlaying(
  station: Station,
  callback: (data: NowPlayingData) => void
): () => void {
  if (import.meta.env.DEV) {
    console.log(`[NowPlaying] Subscribing to station: ${station.id}`);
  }
  
  // Add listener
  listeners.push(callback);
  
  // Start polling if not already started or station changed
  if (currentStationId !== station.id) {
    currentStationId = station.id;
    pollGeneration++; // Increment generation
    if (pollTimeout) {
      clearTimeout(pollTimeout);
    }
    fetchNowPlaying(station.id, pollGeneration);
  }
  
  // Return unsubscribe function
  return () => {
    listeners = listeners.filter(l => l !== callback);
    if (listeners.length === 0 && pollTimeout) {
      clearTimeout(pollTimeout);
      pollTimeout = null;
      currentStationId = null;
      // Invalidate any in-flight polling to prevent rescheduling
      pollGeneration++;
    }
  };
}

async function fetchNowPlaying(stationId: string, expectedGeneration: number): Promise<NowPlayingData | null> {
  // Only proceed if this is still the current generation
  if (expectedGeneration !== pollGeneration) {
    return null;
  }

  if (import.meta.env.DEV) {
    console.log(`[NowPlaying] Fetching data for ${stationId} via Rust backend...`);
  }

  try {
    const data = await invoke<NowPlayingData>('fetch_now_playing', { stationId });
    if (import.meta.env.DEV) {
      console.log(`[NowPlaying] Received data from backend:`, data);
    }

    // Notify all listeners
    listeners.forEach(listener => listener(data));

    // Schedule next poll only if generation hasn't changed and there are listeners
    if (listeners.length > 0) {
      pollTimeout = setTimeout(() => {
        if (expectedGeneration === pollGeneration && listeners.length > 0) {
          fetchNowPlaying(stationId, expectedGeneration);
        }
      }, POLL_INTERVAL);
    }

    return data;
  } catch (error) {
    console.error('[NowPlaying] Failed to fetch now playing:', error);
    // Still notify with empty data to clear loading state
    const emptyData = {
      title: '',
      artist: '',
      show: '',
      moderator: ''
    };
    listeners.forEach(listener => listener(emptyData));

    // Schedule next poll only if generation hasn't changed and there are listeners
    if (listeners.length > 0) {
      pollTimeout = setTimeout(() => {
        if (expectedGeneration === pollGeneration && listeners.length > 0) {
          fetchNowPlaying(stationId, expectedGeneration);
        }
      }, POLL_INTERVAL);
    }

    return emptyData;
  }
}

export async function fetchCurrentSong(stationId: string): Promise<NowPlayingData | null> {
  try {
    // Direct invoke for one-off fetches (not part of polling)
    return await invoke<NowPlayingData>('fetch_now_playing', { stationId });
  } catch (error) {
    console.error('[NowPlaying] Failed to fetch current song:', error);
    return null;
  }
}
