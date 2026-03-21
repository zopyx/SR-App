import React, { useState, useRef, useEffect, useCallback } from 'react';
import type { Station } from '../data/stations';
import { subscribeToNowPlaying, type NowPlayingData } from '../services/nowPlaying';

interface RadioPlayerProps {
  station: Station;
  onStationChange?: (station: Station) => void;
  allStations?: Station[];
  isCompactMode?: boolean;
  onCompactModeChange?: (compact: boolean) => void;
}



const MAX_RETRIES = 3;
const RETRY_DELAY = 2000;

export const RadioPlayer: React.FC<RadioPlayerProps> = ({ 
  station, 
  onStationChange,
  allStations = [],
  isCompactMode = false,
  onCompactModeChange
}) => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [retryCount, setRetryCount] = useState(0);
  const [showStationSelector, setShowStationSelector] = useState(false);
  const [volume, setVolume] = useState(0.8); // Default 80% volume
  const [isMuted, setIsMuted] = useState(false);
  const [nowPlaying, setNowPlaying] = useState<NowPlayingData | null>(null);
  const [nowPlayingLoading, setNowPlayingLoading] = useState(true);
  const preMuteVolumeRef = useRef(0.8);
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const audioContextRef = useRef<AudioContext | null>(null);
  const gainNodeRef = useRef<GainNode | null>(null);
  const mediaSourceRef = useRef<MediaElementAudioSourceNode | null>(null);
  const useGainRef = useRef(false);
  const retryTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const autoPlayTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const stationChangeTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const attemptPlayRef = useRef<((isRetry?: boolean) => Promise<void>) | null>(null);

  // Subscribe to now playing updates
  useEffect(() => {
    setNowPlayingLoading(true);
    setNowPlaying(null);
    
    const unsubscribe = subscribeToNowPlaying(station, (data) => {
      if (import.meta.env.DEV) {
        console.log('[RadioPlayer] Received now playing data:', data);
      }
      setNowPlaying(data);
      setNowPlayingLoading(false);
    });
    
    return () => {
      unsubscribe();
    };
  }, [station]);

  // Reset audio when station changes
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.pause();
      audioRef.current.src = station.streamUrl;
      audioRef.current.load();
      setIsPlaying(false);
      setIsLoading(false);
      setError(null);
      setRetryCount(0);
    }
  }, [station]);

  const getErrorMessage = (code: number): string => {
    switch (code) {
      case MediaError.MEDIA_ERR_ABORTED:
        return 'Playback was aborted';
      case MediaError.MEDIA_ERR_NETWORK:
        return 'Network error - check connection';
      case MediaError.MEDIA_ERR_DECODE:
        return 'Audio format not supported';
      case MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED:
        return 'Stream format not supported';
      default:
        return `Error (code: ${code})`;
    }
  };

  const logEvent = (eventName: string, data?: unknown) => {
    if (import.meta.env.DEV) {
      const timestamp = new Date().toISOString();
      console.log(`[${timestamp}] 🎵 ${station.shortName} - ${eventName}`, data || '');
    }
  };

  // Store retryCount in a ref to avoid dependency issues
  const retryCountRef = useRef(retryCount);
  useEffect(() => {
    retryCountRef.current = retryCount;
  }, [retryCount]);

  const ensureAudioGraph = useCallback(() => {
    if (!audioRef.current) return;
    const AudioContextCtor =
      window.AudioContext ||
      (window as typeof window & { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
    if (!audioContextRef.current && AudioContextCtor) {
      audioContextRef.current = new AudioContextCtor();
    }
    const audioContext = audioContextRef.current;
    if (!audioContext) return;
    if (!gainNodeRef.current) {
      gainNodeRef.current = audioContext.createGain();
      gainNodeRef.current.gain.value = volume;
    }
    if (!mediaSourceRef.current) {
      try {
        mediaSourceRef.current = audioContext.createMediaElementSource(audioRef.current);
        mediaSourceRef.current.connect(gainNodeRef.current);
        gainNodeRef.current.connect(audioContext.destination);
        useGainRef.current = true;
        audioRef.current.volume = 1;
      } catch {
        // Some WebViews restrict MediaElementSource; fall back to element volume.
        useGainRef.current = false;
      }
    }
  }, [volume]);

  const attemptPlay = useCallback(async (isRetry = false) => {
    if (!audioRef.current) return;

    if (isRetry) {
      logEvent('Retry attempt', { attempt: retryCountRef.current + 1 });
    }

    setError(null);
    setIsLoading(true);

    try {
      ensureAudioGraph();
      if (audioContextRef.current?.state === 'suspended') {
        await audioContextRef.current.resume();
      }
      await audioRef.current.play();
      setIsPlaying(true);
      setIsLoading(false);
      setRetryCount(0);
      logEvent('Playback started');
    } catch (err) {
      const errorMsg = err instanceof Error ? err.message : 'Unknown error';
      logEvent('Play failed', errorMsg);
      
      setIsPlaying(false);
      setIsLoading(false);

      const currentRetryCount = retryCountRef.current;
      if (currentRetryCount < MAX_RETRIES) {
        setRetryCount(currentRetryCount + 1);
        setError(`Retrying... (${currentRetryCount + 1}/${MAX_RETRIES})`);
        
        retryTimeoutRef.current = setTimeout(() => {
          attemptPlayRef.current?.(true);
        }, RETRY_DELAY);
      } else {
        setError(`Failed: ${errorMsg}`);
      }
    }
  }, [station]);

  // Store attemptPlay in ref to avoid circular dependency
  useEffect(() => {
    attemptPlayRef.current = attemptPlay;
  }, [attemptPlay]);

  // Initialize audio element (runs once on mount)
  useEffect(() => {
    if (!audioRef.current) {
      audioRef.current = new Audio(station.streamUrl);
      audioRef.current.preload = 'none';
      audioRef.current.crossOrigin = 'anonymous';
      audioRef.current.volume = volume;

      audioRef.current.addEventListener('waiting', () => {
        setIsLoading(true);
      });

      audioRef.current.addEventListener('playing', () => {
        setIsLoading(false);
        setRetryCount(0);
      });

      audioRef.current.addEventListener('error', () => {
        const audio = audioRef.current;
        if (audio?.error) {
          setError(getErrorMessage(audio.error.code));
        }
        setIsLoading(false);
        setIsPlaying(false);
      });

      audioRef.current.addEventListener('pause', () => {
        setIsPlaying(false);
      });

      // Auto-play on app start
      logEvent('Auto-starting on app launch');
      autoPlayTimeoutRef.current = setTimeout(() => {
        attemptPlayRef.current?.();
      }, 500);
    }

    return () => {
      if (retryTimeoutRef.current) {
        clearTimeout(retryTimeoutRef.current);
      }
      if (autoPlayTimeoutRef.current) {
        clearTimeout(autoPlayTimeoutRef.current);
      }
    };
  }, []); // Empty deps - only run once on mount

  // Update audio source when station changes
  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.src = station.streamUrl;
    }
  }, [station]);

  // Update volume without reloading stream
  useEffect(() => {
    if (useGainRef.current) {
      if (gainNodeRef.current) {
        gainNodeRef.current.gain.value = volume;
      }
      if (audioRef.current) {
        audioRef.current.volume = 1;
      }
    } else if (audioRef.current) {
      audioRef.current.volume = volume;
    }
  }, [volume]);

  const togglePlay = async () => {
    if (!audioRef.current) return;

    if (isPlaying) {
      if (retryTimeoutRef.current) {
        clearTimeout(retryTimeoutRef.current);
        retryTimeoutRef.current = null;
      }
      audioRef.current.pause();
      setIsPlaying(false);
      setRetryCount(0);
    } else {
      setRetryCount(0);
      ensureAudioGraph();
      if (audioContextRef.current?.state === 'suspended') {
        await audioContextRef.current.resume();
      }
      await attemptPlay();
    }
  };

  // Track if we should auto-play after station change
  const shouldAutoPlayRef = useRef(false);

  // Handle volume change
  const handleVolumeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newVolume = parseFloat(e.target.value);
    setVolume(newVolume);
    if (isMuted && newVolume > 0) {
      setIsMuted(false);
    }
    ensureAudioGraph();
    if (useGainRef.current) {
      if (gainNodeRef.current) {
        gainNodeRef.current.gain.value = newVolume;
      }
      if (audioRef.current) {
        audioRef.current.volume = 1;
        audioRef.current.muted = newVolume === 0;
      }
    } else if (audioRef.current) {
      audioRef.current.volume = newVolume;
    }
    // Update CSS variable for track fill
    e.target.style.setProperty('--volume-percent', `${newVolume * 100}%`);
  };

  // Toggle mute
  const toggleMute = () => {
    if (!audioRef.current) return;
    ensureAudioGraph();
    
    if (isMuted) {
      // Unmute - restore previous volume
      const restoredVolume = preMuteVolumeRef.current || 0.8;
      setIsMuted(false);
      setVolume(restoredVolume);
      if (useGainRef.current) {
        if (gainNodeRef.current) {
          gainNodeRef.current.gain.value = restoredVolume;
        }
        audioRef.current.volume = 1;
        audioRef.current.muted = false;
      } else {
        audioRef.current.volume = restoredVolume;
        audioRef.current.muted = false;
      }
    } else {
      // Mute - save current volume first
      preMuteVolumeRef.current = volume;
      setIsMuted(true);
      setVolume(0);
      if (useGainRef.current) {
        if (gainNodeRef.current) {
          gainNodeRef.current.gain.value = 0;
        }
        audioRef.current.volume = 1;
        audioRef.current.muted = true;
      } else {
        audioRef.current.volume = 0;
        audioRef.current.muted = true;
      }
    }
  };

  const handleStationSelect = (newStation: Station) => {
    if (newStation.id !== station.id) {
      shouldAutoPlayRef.current = true;
      if (onStationChange) {
        onStationChange(newStation);
      }
    }
    setShowStationSelector(false);
  };

  // Auto-play when station changes (if requested)
  useEffect(() => {
    if (shouldAutoPlayRef.current && audioRef.current) {
      shouldAutoPlayRef.current = false;
      logEvent('Auto-starting playback after station change');
      // Small delay to let the audio element initialize with new source
      stationChangeTimeoutRef.current = setTimeout(() => {
        attemptPlayRef.current?.();
      }, 100);
    }

    return () => {
      if (stationChangeTimeoutRef.current) {
        clearTimeout(stationChangeTimeoutRef.current);
      }
    };
  }, [station]);

  // Format now playing text
  const getNowPlayingText = (): string | null => {
    if (!nowPlaying) return null;
    
    if (nowPlaying.artist && nowPlaying.title) {
      return `${nowPlaying.artist} — ${nowPlaying.title}`;
    }
    if (nowPlaying.title) {
      return nowPlaying.title;
    }
    if (nowPlaying.show) {
      return nowPlaying.show;
    }
    return null;
  };

  const nowPlayingText = getNowPlayingText();
  const volumeLevel = isMuted ? 'mute' : volume < 0.3 ? 'low' : volume < 0.7 ? 'medium' : 'high';
  const renderVolumeIcon = () => {
    if (volumeLevel === 'mute') {
      return (
        <svg className="mute-svg" viewBox="0 0 24 24" aria-hidden="true">
          <path className="speaker" d="M4 9h4l5-4v14l-5-4H4z" fill="currentColor" />
          <path className="mute-x" d="M16 9l5 6M21 9l-5 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
        </svg>
      );
    }
    if (volumeLevel === 'low') {
      return (
        <svg className="mute-svg" viewBox="0 0 24 24" aria-hidden="true">
          <path className="speaker" d="M4 9h4l5-4v14l-5-4H4z" fill="currentColor" />
          <path className="wave" d="M16 10.5c1 .9 1 2.1 0 3" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill="none" />
        </svg>
      );
    }
    if (volumeLevel === 'medium') {
      return (
        <svg className="mute-svg" viewBox="0 0 24 24" aria-hidden="true">
          <path className="speaker" d="M4 9h4l5-4v14l-5-4H4z" fill="currentColor" />
          <path className="wave" d="M15.5 9c1.6 1.5 1.6 4.5 0 6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill="none" />
          <path className="wave" d="M18.5 7c2.4 2.3 2.4 7.7 0 10" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill="none" opacity="0.7" />
        </svg>
      );
    }
    return (
      <svg className="mute-svg" viewBox="0 0 24 24" aria-hidden="true">
        <path className="speaker" d="M4 9h4l5-4v14l-5-4H4z" fill="currentColor" />
        <path className="wave" d="M15.5 8c2.1 2 2.1 6 0 8" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill="none" />
        <path className="wave" d="M19 5.5c3.2 3 3.2 10 0 13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill="none" opacity="0.7" />
        <path className="wave" d="M12.8 10.2c.8.7.8 2.9 0 3.6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" fill="none" opacity="0.5" />
      </svg>
    );
  };

  return (
    <div className="player-container">
      {/* Station Selector Toggle */}
      {allStations.length > 1 && (
        <button 
          className="station-selector-toggle"
          onClick={() => setShowStationSelector(!showStationSelector)}
          style={{ '--station-color': station.color } as React.CSSProperties}
        >
          <span className="current-station-indicator" style={{ background: station.color }}></span>
          {station.shortName}
          <span className="dropdown-arrow">▼</span>
        </button>
      )}

      {/* Station Selector Dropdown */}
      {showStationSelector && allStations.length > 1 && (
        <div className="station-selector-dropdown">
          {allStations.map((s) => (
            <button
              key={s.id}
              className={`station-option ${s.id === station.id ? 'active' : ''}`}
              onClick={() => handleStationSelect(s)}
            >
              <span className="station-color-dot" style={{ background: s.color }}></span>
              <div className="station-info">
                <span className="station-name-short">{s.shortName}</span>
                <span className="station-desc">{s.description}</span>
              </div>
            </button>
          ))}
        </div>
      )}

      {/* Main Logo / Play Button */}
      <div 
        className={`logo-wrapper ${isPlaying ? 'playing' : ''} ${isLoading ? 'loading' : ''}`}
        onClick={togglePlay}
        role="button"
        tabIndex={0}
        aria-label={`Play ${station.name}`}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            togglePlay();
          }
        }}
        style={{ '--station-color': station.color } as React.CSSProperties}
      >
        <img src={station.logoUrl} alt={`${station.name} Logo`} className="station-logo" />
        {isLoading && <div className="spinner"></div>}
        {!isPlaying && !isLoading && (
          <div className="play-overlay" style={{ color: station.color }}>▶</div>
        )}
        
        {/* Animated Equalizer */}
        <div className="equalizer">
          <div className="equalizer-bar" style={{ background: station.color }}></div>
          <div className="equalizer-bar" style={{ background: station.color }}></div>
          <div className="equalizer-bar" style={{ background: station.color }}></div>
          <div className="equalizer-bar" style={{ background: station.color }}></div>
          <div className="equalizer-bar" style={{ background: station.color }}></div>
        </div>
      </div>
      
      {/* Compact Mode Toggle */}
      <button 
        className="compact-toggle"
        onClick={() => onCompactModeChange?.(!isCompactMode)}
        aria-label={isCompactMode ? 'Expand UI' : 'Minimize UI'}
        title={isCompactMode ? 'Expand' : 'Minimize'}
      >
        {isCompactMode ? '□' : '—'}
      </button>

      {!isCompactMode && (
        <>
          <h1 className="station-name">{station.name}</h1>
          
          {/* Now Playing Info */}
          <div className="now-playing-container">
            <div className="now-playing-label">Now Playing</div>
            <div className="now-playing-text" style={{ color: station.color }}>
              {nowPlayingLoading 
                ? 'Loading...' 
                : nowPlayingText 
                  ? nowPlayingText 
                  : 'No track information'}
            </div>
          </div>
          
          {error && (
            <div className="error-message" onClick={() => setError(null)} role="button" tabIndex={0}>
              ⚠️ {error}
            </div>
          )}
        </>
      )}
      
      {/* Volume Control */}
      <div className={`volume-control ${isCompactMode ? 'compact' : ''}`}>
        <button 
          className="mute-button"
          onClick={toggleMute}
          aria-label={isMuted ? 'Unmute' : 'Mute'}
          title={isMuted ? 'Unmute' : 'Mute'}
        >
          <span className="mute-icon">
            {renderVolumeIcon()}
          </span>
        </button>
        <input
          type="range"
          className="volume-slider"
          min="0"
          max="1"
          step="0.01"
          value={volume}
          onChange={handleVolumeChange}
          style={{ '--station-color': station.color, '--volume-percent': `${volume * 100}%` } as React.CSSProperties}
        />
        <span className="volume-value">{isMuted ? 'Muted' : `${Math.round(volume * 100)}%`}</span>
      </div>

      {!isCompactMode && (
        <div className={`status-container ${isPlaying ? 'playing' : ''} ${isLoading ? 'loading' : ''}`}>
          <span className="status-dot" style={{ background: isPlaying ? station.color : undefined }}></span>
          <span className="status-indicator">
            {isLoading ? 'Buffering...' : isPlaying ? 'On Air' : 'Tap to Play'}
          </span>
        </div>
      )}
    </div>
  );
};
