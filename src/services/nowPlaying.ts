import type { Station } from '../data/stations';

export interface NowPlayingData {
  title: string;
  artist: string;
  show: string;
  moderator: string;
}

interface SongApiResponse {
  [key: string]: {
    titel: string;
    interpret: string;
  };
}

interface ShowApiResponse {
  'now playing': {
    [key: string]: {
      titel: string;
      moderator: string;
      start: string;
      ende: string;
    };
  };
}

const SONG_API_URL = 'http://musikrecherche.sr-online.de/sophora/titelinterpret.php';
const SHOW_API_URL = 'https://www.sr.de/sr/epg/nowPlaying.jsp';
const POLL_INTERVAL = 30000; // 30 seconds

let currentStationId: string | null = null;
let pollTimeout: ReturnType<typeof setTimeout> | null = null;
let listeners: ((data: NowPlayingData) => void)[] = [];

export function subscribeToNowPlaying(
  station: Station,
  callback: (data: NowPlayingData) => void
): () => void {
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
  try {
    // Fetch both song and show info
    const [songData, showData] = await Promise.all([
      fetchSongInfo(stationId),
      fetchShowInfo(stationId)
    ]);
    
    const data: NowPlayingData = {
      title: songData?.title || '',
      artist: songData?.artist || '',
      show: showData?.show || '',
      moderator: showData?.moderator || ''
    };
    
    // Notify all listeners
    listeners.forEach(listener => listener(data));
  } catch (error) {
    console.error('Failed to fetch now playing:', error);
  }
  
  // Schedule next poll
  pollTimeout = setTimeout(() => fetchNowPlaying(stationId), POLL_INTERVAL);
}

async function fetchSongInfo(stationId: string): Promise<{ title: string; artist: string } | null> {
  try {
    const response = await fetch(SONG_API_URL);
    if (!response.ok) return null;
    
    const data: SongApiResponse = await response.json();
    const stationData = data[stationId];
    
    if (stationData && stationData.titel) {
      return {
        title: stationData.titel,
        artist: stationData.interpret
      };
    }
    return null;
  } catch {
    return null;
  }
}

async function fetchShowInfo(stationId: string): Promise<{ show: string; moderator: string } | null> {
  try {
    const response = await fetch(`${SHOW_API_URL}?welle=${stationId}`);
    if (!response.ok) return null;
    
    const data: ShowApiResponse = await response.json();
    const stationData = data['now playing']?.[stationId];
    
    if (stationData && stationData.titel) {
      return {
        show: stationData.titel,
        moderator: stationData.moderator
      };
    }
    return null;
  } catch {
    return null;
  }
}

export async function fetchCurrentSong(stationId: string): Promise<NowPlayingData | null> {
  try {
    const [songData, showData] = await Promise.all([
      fetchSongInfo(stationId),
      fetchShowInfo(stationId)
    ]);
    
    if (!songData && !showData) return null;
    
    return {
      title: songData?.title || '',
      artist: songData?.artist || '',
      show: showData?.show || '',
      moderator: showData?.moderator || ''
    };
  } catch (error) {
    console.error('Failed to fetch current song:', error);
    return null;
  }
}
