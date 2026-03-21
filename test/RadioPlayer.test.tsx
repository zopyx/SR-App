import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { RadioPlayer } from '../src/components/RadioPlayer';
import type { Station } from '../src/data/stations';

// Mock nowPlaying service
vi.mock('../src/services/nowPlaying', () => ({
  subscribeToNowPlaying: vi.fn((station, callback) => {
    callback({
      title: 'Test Song',
      artist: 'Test Artist',
      show: 'Test Show',
      moderator: 'Test Moderator'
    });
    return () => {};
  }),
}));

describe('RadioPlayer Component', () => {
  const mockStation: Station = {
    id: 'sr2',
    name: 'SR 2 KulturRadio',
    shortName: 'SR2',
    description: 'Kultur, Wort und klassische Musik',
    streamUrl: 'https://liveradio.sr.de/sr/sr2/mp3/256/stream.mp3',
    logoUrl: '/sr2_logo.png',
    color: '#ffb700',
    website: 'https://www.sr.de/sr2'
  };

  const mockStations: Station[] = [
    mockStation,
    {
      id: 'sr1',
      name: 'SR 1 Europawelle',
      shortName: 'SR1',
      description: 'Saarlands beste Musik',
      streamUrl: 'https://liveradio.sr.de/sr/sr1/mp3/256/stream.mp3',
      logoUrl: '/sr1_logo.png',
      color: '#e60005',
      website: 'https://www.sr.de/sr1'
    },
    {
      id: 'sr3',
      name: 'SR 3 Saarlandwelle',
      shortName: 'SR3',
      description: 'Die beste Musik',
      streamUrl: 'https://liveradio.sr.de/sr/sr3/mp3/256/stream.mp3',
      logoUrl: '/sr3_logo.png',
      color: '#0082c9',
      website: 'https://www.sr.de/sr3'
    }
  ];

  it('renders station name', () => {
    render(<RadioPlayer station={mockStation} allStations={mockStations} />);
    expect(screen.getByText('SR 2 KulturRadio')).toBeInTheDocument();
  });

  it('renders station selector toggle', () => {
    render(<RadioPlayer station={mockStation} allStations={mockStations} />);
    expect(screen.getByText('SR2')).toBeInTheDocument();
  });

  it('shows now playing section', async () => {
    render(<RadioPlayer station={mockStation} allStations={mockStations} />);
    await waitFor(() => {
      expect(screen.getByText('Now Playing')).toBeInTheDocument();
    });
  });

  it('displays volume control', () => {
    render(<RadioPlayer station={mockStation} allStations={mockStations} />);
    expect(screen.getByRole('slider')).toBeInTheDocument();
  });

  it('shows status indicator', () => {
    render(<RadioPlayer station={mockStation} allStations={mockStations} />);
    expect(screen.getByText('Tap to Play')).toBeInTheDocument();
  });

  it('opens station selector on click', () => {
    render(<RadioPlayer station={mockStation} allStations={mockStations} />);
    const toggle = screen.getByText('SR2');
    fireEvent.click(toggle);
    
    // Should show other stations
    expect(screen.getByText('SR1')).toBeInTheDocument();
    expect(screen.getByText('SR3')).toBeInTheDocument();
  });

  it('calls onStationChange when selecting different station', () => {
    const onStationChange = vi.fn();
    render(
      <RadioPlayer 
        station={mockStation} 
        allStations={mockStations}
        onStationChange={onStationChange}
      />
    );
    
    const toggle = screen.getByText('SR2');
    fireEvent.click(toggle);
    
    const sr1Option = screen.getByText('SR1');
    fireEvent.click(sr1Option);
    
    expect(onStationChange).toHaveBeenCalled();
  });
});
