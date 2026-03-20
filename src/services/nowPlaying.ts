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

const SONG_API_URL = 'https://musikrecherche.sr-online.de/sophora/titelinterpret.php';
const SHOW_API_URL = 'https://www.sr.de/sr/epg/nowPlaying.jsp';
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
  console.log(`[NowPlaying] Fetching data for ${stationId}...`);
  
  try {
    // Fetch both song and show info
    const [songData, showData] = await Promise.all([
      fetchSongInfo(stationId),
      fetchShowInfo(stationId)
    ]);
    
    console.log(`[NowPlaying] Song data:`, songData);
    console.log(`[NowPlaying] Show data:`, showData);
    
    const data: NowPlayingData = {
      title: songData?.title || '',
      artist: songData?.artist || '',
      show: showData?.show || '',
      moderator: showData?.moderator || ''
    };
    
    // Notify all listeners
    console.log(`[NowPlaying] Notifying listeners with:`, data);
    listeners.forEach(listener => listener(data));
  } catch (error) {
    console.error('[NowPlaying] Failed to fetch now playing:', error);
  }
  
  // Schedule next poll
  pollTimeout = setTimeout(() => fetchNowPlaying(stationId), POLL_INTERVAL);
}

async function fetchSongInfo(stationId: string): Promise<{ title: string; artist: string } | null> {
  try {
    console.log(`[NowPlaying] Fetching song from: ${SONG_API_URL}`);
    const response = await fetch(SONG_API_URL);
    console.log(`[NowPlaying] Song API response status:`, response.status);
    
    if (!response.ok) return null;
    
    const data: SongApiResponse = await response.json();
    console.log(`[NowPlaying] Song API data:`, data);
    
    const stationData = data[stationId];
    
    if (stationData && stationData.titel) {
      return {
        title: stationData.titel,
        artist: stationData.interpret
      };
    }
    return null;
  } catch (error) {
    console.error('[NowPlaying] Error fetching song info:', error);
    return null;
  }
}

async function fetchShowInfo(stationId: string): Promise<{ show: string; moderator: string } | null> {
  try {
    const url = `${SHOW_API_URL}?welle=${stationId}`;
    console.log(`[NowPlaying] Fetching show from: ${url}`);
    const response = await fetch(url);
    console.log(`[NowPlaying] Show API response status:`, response.status);
    
    if (!response.ok) return null;
    
    const data: ShowApiResponse = await response.json();
    console.log(`[NowPlaying] Show API data:`, data);
    
    const stationData = data['now playing']?.[stationId];
    
    if (stationData && stationData.titel) {
      return {
        show: stationData.titel,
        moderator: stationData.moderator
      };
    }
    return null;
  } catch (error) {
    console.error('[NowPlaying] Error fetching show info:', error);
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
    console.error('[NowPlaying] Failed to fetch current song:', error);
    return null;
  }
}
