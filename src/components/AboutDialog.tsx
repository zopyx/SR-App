import { useEffect, useState } from 'react';
import { getVersion } from '@tauri-apps/api/app';
import type { Station } from '../data/stations';
import { fetchCurrentSong, type NowPlayingData } from '../services/nowPlaying';

// Build timestamp - injected at build time
const BUILD_DATE = import.meta.env.VITE_BUILD_DATE || new Date().toISOString();

interface AboutDialogProps {
  isOpen: boolean;
  onClose: () => void;
  stations: Station[];
  currentStation: Station;
  onStationChange?: (station: Station) => void;
}

export const AboutDialog: React.FC<AboutDialogProps> = ({ 
  isOpen, 
  onClose, 
  stations,
  currentStation,
  onStationChange
}) => {
  const [version, setVersion] = useState<string>('0.0.0');
  const [copiedUrl, setCopiedUrl] = useState<string | null>(null);
  const [nowPlaying, setNowPlaying] = useState<NowPlayingData | null>(null);

  useEffect(() => {
    if (isOpen) {
      getVersion().then(setVersion).catch(() => setVersion('0.0.0'));
      // Fetch current song when dialog opens
      fetchCurrentSong(currentStation.id).then(setNowPlaying);
    }
  }, [isOpen, currentStation.id]);

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose();
      }
    };
    window.addEventListener('keydown', handleEscape);
    return () => window.removeEventListener('keydown', handleEscape);
  }, [isOpen, onClose]);

  const handleCopy = (text: string) => {
    navigator.clipboard.writeText(text);
    setCopiedUrl(text);
    setTimeout(() => setCopiedUrl(null), 2000);
  };

  if (!isOpen) return null;

  return (
    <div className="about-overlay" onClick={onClose}>
      <div className="about-dialog about-dialog-wide" onClick={(e) => e.stopPropagation()}>
        <button className="about-close" onClick={onClose} aria-label="Close">
          ×
        </button>
        
        <div className="about-header" style={{ 
          background: `linear-gradient(180deg, ${currentStation.color}20 0%, transparent 100%)` 
        }}>
          <div className="about-logo" style={{ borderColor: currentStation.color }}>
            <img src={currentStation.logoUrl} alt={currentStation.name} />
          </div>
          <h1 className="about-title">SR Radio Player</h1>
          <span className="about-version">Version {version}</span>
        </div>

        <div className="about-content">
          {/* Stations List */}
          <section className="about-section">
            <h2>Available Stations ({stations.length})</h2>
            <div className="stations-list">
              {stations.map((station) => (
                <button 
                  key={station.id} 
                  className={`station-card ${station.id === currentStation.id ? 'active' : ''}`}
                  style={{ '--station-color': station.color } as React.CSSProperties}
                  onClick={() => {
                    if (onStationChange && station.id !== currentStation.id) {
                      onStationChange(station);
                      onClose();
                    }
                  }}
                  disabled={station.id === currentStation.id}
                  aria-label={`Select ${station.name}`}
                >
                  <span className="station-dot" style={{ background: station.color }}></span>
                  <div className="station-card-info">
                    <strong>{station.name}</strong>
                    <span>{station.description}</span>
                  </div>
                  {station.id === currentStation.id && (
                    <span className="station-active-badge">Active</span>
                  )}
                </button>
              ))}
            </div>
          </section>

          {/* Current Station Info */}
          <section className="about-section">
            <h2 style={{ color: currentStation.color }}>Current Station</h2>
            <div className="about-info-row">
              <span className="about-label">Name</span>
              <span className="about-value">{currentStation.name}</span>
            </div>
            <div className="about-info-row">
              <span className="about-label">Tagline</span>
              <span className="about-value">{currentStation.description}</span>
            </div>
            
            {/* Now Playing in About Dialog */}
            {nowPlaying && (nowPlaying.title || nowPlaying.show) && (
              <div className="about-info-row">
                <span className="about-label">Now Playing</span>
                <span className="about-value" style={{ color: currentStation.color }}>
                  {nowPlaying.artist && nowPlaying.title 
                    ? `${nowPlaying.artist} — ${nowPlaying.title}`
                    : nowPlaying.title || nowPlaying.show
                  }
                </span>
              </div>
            )}
            
            <div className="about-info-row">
              <span className="about-label">Quality</span>
              <span className="about-value">256 kbps MP3</span>
            </div>
            <div className="about-info-row">
              <span className="about-label">Website</span>
              <a 
                href={currentStation.website} 
                target="_blank" 
                rel="noopener noreferrer"
                className="about-link"
                style={{ color: currentStation.color }}
              >
                Visit →
              </a>
            </div>
            <div className="about-info-row">
              <span className="about-label">Stream URL</span>
              <button 
                className="about-copyable"
                onClick={() => handleCopy(currentStation.streamUrl)}
                title="Click to copy URL"
              >
                Copy URL
                {copiedUrl === currentStation.streamUrl && (
                  <span className="copied-tooltip">Copied!</span>
                )}
              </button>
            </div>
          </section>

          {/* About SR */}
          <section className="about-section">
            <h2>About Saarländischer Rundfunk</h2>
            <p>
              The Saarländischer Rundfunk (SR) is the public broadcaster for Saarland, Germany. 
              SR provides three radio stations offering news, culture, and entertainment 
              programming since 1957.
            </p>
          </section>

          {/* App Info */}
          <section className="about-section">
            <h2>App Information</h2>
            <div className="about-info-row">
              <span className="about-label">Built with</span>
              <span className="about-value">Tauri + React + TypeScript</span>
            </div>
            <div className="about-info-row">
              <span className="about-label">Platforms</span>
              <span className="about-value">macOS, iOS</span>
            </div>
            <div className="about-info-row">
              <span className="about-label">Author</span>
              <span className="about-value">Andreas Jung</span>
            </div>
            <div className="about-info-row">
              <span className="about-label">Website</span>
              <a 
                href="https://www.zopyx.com"
                target="_blank"
                rel="noopener noreferrer"
                className="about-link"
                style={{ color: currentStation.color }}
              >
                www.zopyx.com →
              </a>
            </div>
            <div className="about-info-row">
              <span className="about-label">Contact</span>
              <a 
                href="mailto:info@zopyx.com"
                className="about-link"
                style={{ color: currentStation.color }}
              >
                info@zopyx.com
              </a>
            </div>
            <div className="about-info-row">
              <span className="about-label">License</span>
              <span className="about-value">MIT</span>
            </div>
          </section>

          <section className="about-section about-credits">
            <p className="about-disclaimer">
              This is an unofficial third-party app. SR1, SR2, SR3 and Saarländischer Rundfunk 
              are trademarks of Saarländischer Rundfunk. All rights reserved.
            </p>
          </section>
        </div>

        <div className="about-footer">
          <span>Made with ♥ for radio lovers</span>
        </div>
      </div>
    </div>
  );
};
