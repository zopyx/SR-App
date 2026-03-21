import { useState, useEffect } from 'react'
import { listen } from '@tauri-apps/api/event'
import { RadioPlayer } from './components/RadioPlayer'
import { AboutDialog } from './components/AboutDialog'
import { stations, defaultStation, type Station } from './data/stations'
import './App.css'

function App() {
  const [currentStation, setCurrentStation] = useState<Station>(defaultStation)
  const [isAboutOpen, setIsAboutOpen] = useState(false)
  const [isCompactMode, setIsCompactMode] = useState(false)

  useEffect(() => {
    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent)
    document.body.classList.toggle('platform-ios', isIOS)
    document.documentElement.classList.toggle('platform-ios', isIOS)
  }, [])

  // Listen for menu About click events
  useEffect(() => {
    let unlisten: (() => void) | undefined

    const setupListener = async () => {
      unlisten = await listen('menu-about-clicked', () => {
        setIsAboutOpen(true)
      })
    }

    setupListener()

    return () => {
      if (unlisten) {
        unlisten()
      }
    }
  }, [])

  return (
    <div className="app-container" data-tauri-drag-region>
      {!isCompactMode && (
        <button 
          className="info-button" 
          onClick={() => setIsAboutOpen(true)}
          aria-label="About SR Radio"
          title="About"
        >
          ℹ
        </button>
      )}
      
      <RadioPlayer
        station={currentStation}
        onStationChange={setCurrentStation}
        allStations={stations}
        isCompactMode={isCompactMode}
        onCompactModeChange={setIsCompactMode}
      />
      
      {!isCompactMode && (
        <footer className="app-footer">
          <p>SR Radio Player • {stations.length} Stations</p>
        </footer>
      )}
      
      <AboutDialog 
        isOpen={isAboutOpen} 
        onClose={() => setIsAboutOpen(false)}
        stations={stations}
        currentStation={currentStation}
        onStationChange={setCurrentStation}
      />
    </div>
  )
}

export default App
