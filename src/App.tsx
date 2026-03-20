import { useState } from 'react'
import { RadioPlayer } from './components/RadioPlayer'
import { AboutDialog } from './components/AboutDialog'
import { stations, defaultStation, type Station } from './data/stations'
import './App.css'

function App() {
  const [currentStation, setCurrentStation] = useState<Station>(defaultStation)
  const [isAboutOpen, setIsAboutOpen] = useState(false)

  return (
    <div className="app-container">
      <button 
        className="info-button" 
        onClick={() => setIsAboutOpen(true)}
        aria-label="About SR Radio"
        title="About"
      >
        ℹ
      </button>
      
      <RadioPlayer
        station={currentStation}
        onStationChange={setCurrentStation}
        allStations={stations}
      />
      
      <footer className="app-footer">
        <p>SR Radio Player • {stations.length} Stations</p>
      </footer>
      
      <AboutDialog 
        isOpen={isAboutOpen} 
        onClose={() => setIsAboutOpen(false)}
        stations={stations}
        currentStation={currentStation}
      />
    </div>
  )
}

export default App
