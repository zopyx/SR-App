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

export function subscribeToNowPlaying(
  station: Station,
  callback: (data: NowPlayingData) => void
): () => void {
  console.log(`[NowPlaying] Subscribing to station: ${station.id}`);
  
  // Add listener
  listeners.push(callback);
  
  // Start polling if not already started or station changed
  if (currentStationId !== station.id) {
    currentStationId = station.id;
    if (pollTimeout) {
      clearTimeout(pollTimeout);
    }
    fetchNowPlaying(station.id);
  }
  
  // Return unsubscribe function
  return () => {
    listeners = listeners.filter(l => l !== callback);
    if (listeners.length === 0 && pollTimeout) {
      clearTimeout(pollTimeout);
      pollTimeout = null;
      currentStationId = null;
    }
  };
}

async function fetchNowPlaying(stationId: string): Promise<void> {
  console.log(`[NowPlaying] Fetching data for ${stationId} via Rust backend...`);
  
  try {
    const data = await invoke<NowPlayingData>('fetch_now_playing', { stationId });
    console.log(`[NowPlaying] Received data from backend:`, data);
    
    // Notify all listeners
    listeners.forEach(listener => listener(data));
  } catch (error) {
    console.error('[NowPlaying] Failed to fetch now playing:', error);
    // Still notify with empty data to clear loading state
    listeners.forEach(listener => listener({
      title: '',
      artist: '',
      show: '',
      moderator: ''
    }));
  }
  
  // Schedule next poll
  pollTimeout = setTimeout(() => fetchNowPlaying(stationId), POLL_INTERVAL);
}

export async function fetchCurrentSong(stationId: string): Promise<NowPlayingData | null> {
  try {
    return await invoke<NowPlayingData>('fetch_now_playing', { stationId });
  } catch (error) {
    console.error('[NowPlaying] Failed to fetch current song:', error);
    return null;
  }
}
