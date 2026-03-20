import { useState, useRef, useEffect, useCallback } from 'react';
import type { Station } from '../data/stations';

interface RadioPlayerProps {
  station: Station;
  onStationChange?: (station: Station) => void;
  allStations?: Station[];
}

interface AudioErrorDetails {
  code: number;
  message: string;
  networkState: number;
  readyState: number;
  currentSrc: string;
}

const MAX_RETRIES = 3;
const RETRY_DELAY = 2000;

export const RadioPlayer: React.FC<RadioPlayerProps> = ({ 
  station, 
  onStationChange,
  allStations = []
}) => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [retryCount, setRetryCount] = useState(0);
  const [showStationSelector, setShowStationSelector] = useState(false);
  const [volume, setVolume] = useState(0.8); // Default 80% volume
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const retryTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);

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
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] 🎵 ${station.shortName} - ${eventName}`, data || '');
  };

  const attemptPlay = useCallback(async (isRetry = false) => {
    if (!audioRef.current) return;

    if (isRetry) {
      logEvent('Retry attempt', { attempt: retryCount + 1 });
    }

    setError(null);
    setIsLoading(true);

    try {
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

      if (retryCount < MAX_RETRIES) {
        setRetryCount(prev => prev + 1);
        setError(`Retrying... (${retryCount + 1}/${MAX_RETRIES})`);
        
        retryTimeoutRef.current = setTimeout(() => {
          attemptPlay(true);
        }, RETRY_DELAY);
      } else {
        setError(`Failed: ${errorMsg}`);
      }
    }
  }, [retryCount, station]);

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
      setTimeout(() => {
        attemptPlay();
      }, 500);
    } else {
      // Update source when station changes
      audioRef.current.src = station.streamUrl;
    }

    return () => {
      if (retryTimeoutRef.current) {
        clearTimeout(retryTimeoutRef.current);
      }
    };
  }, [station]);

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
      await attemptPlay();
    }
  };

  // Track if we should auto-play after station change
  const shouldAutoPlayRef = useRef(false);

  // Handle volume change
  const handleVolumeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newVolume = parseFloat(e.target.value);
    setVolume(newVolume);
    if (audioRef.current) {
      audioRef.current.volume = newVolume;
    }
    // Update CSS variable for track fill
    e.target.style.setProperty('--volume-percent', `${newVolume * 100}%`);
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
      setTimeout(() => {
        attemptPlay();
      }, 100);
    }
  }, [station, attemptPlay]);

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
      
      <h1 className="station-name">{station.name}</h1>
      
      {error && (
        <div className="error-message" onClick={() => setError(null)} role="button" tabIndex={0}>
          ⚠️ {error}
        </div>
      )}
      
      {/* Volume Control */}
      <div className="volume-control">
        <span className="volume-icon">🔊</span>
        <input
          type="range"
          className="volume-slider"
          min="0"
          max="1"
          step="0.01"
          value={volume}
          onChange={handleVolumeChange}
          style={{ '--station-color': station.color } as React.CSSProperties}
        />
        <span className="volume-value">{Math.round(volume * 100)}%</span>
      </div>

      <div className={`status-container ${isPlaying ? 'playing' : ''} ${isLoading ? 'loading' : ''}`}>
        <span className="status-dot" style={{ background: isPlaying ? station.color : undefined }}></span>
        <span className="status-indicator">
          {isLoading ? 'Buffering...' : isPlaying ? 'On Air' : 'Tap to Play'}
        </span>
      </div>
    </div>
  );
};
