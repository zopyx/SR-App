import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { AboutDialog } from '../src/components/AboutDialog';
import type { Station } from '../src/data/stations';

vi.mock('../src/services/nowPlaying', () => ({
  fetchCurrentSong: vi.fn(() => Promise.resolve({
    title: 'Test Song',
    artist: 'Test Artist',
    show: 'Test Show',
    moderator: 'Test Moderator'
  })),
}));

describe('AboutDialog Component', () => {
  const mockStations: Station[] = [
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
      id: 'sr2',
      name: 'SR 2 KulturRadio',
      shortName: 'SR2',
      description: 'Kultur, Wort und klassische Musik',
      streamUrl: 'https://liveradio.sr.de/sr/sr2/mp3/256/stream.mp3',
      logoUrl: '/sr2_logo.png',
      color: '#ffb700',
      website: 'https://www.sr.de/sr2'
    },
    {
      id: 'sr3',
      name: 'SR 3 Saarlandwelle',
      shortName: 'SR3',
      description: 'Die beste Musik für das Saarland',
      streamUrl: 'https://liveradio.sr.de/sr/sr3/mp3/256/stream.mp3',
      logoUrl: '/sr3_logo.png',
      color: '#0082c9',
      website: 'https://www.sr.de/sr3'
    }
  ];

  const mockCurrentStation = mockStations[1]; // SR2

  it('does not render when closed', () => {
    const { container } = render(
      <AboutDialog
        isOpen={false}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    expect(container).toBeEmptyDOMElement();
  });

  it('renders when open', () => {
    render(
      <AboutDialog
        isOpen={true}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    expect(screen.getByText('SR Radio Player')).toBeInTheDocument();
  });

  it('displays version', async () => {
    render(
      <AboutDialog
        isOpen={true}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    // Use getAllByText since "Version" appears in both header and App Info section
    const versionElements = await screen.findAllByText(/Version/);
    expect(versionElements.length).toBeGreaterThanOrEqual(1);
  });

  it('displays build date or shows app info section', async () => {
    render(
      <AboutDialog
        isOpen={true}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    // Build date may not be available in test env, but App Information section should exist
    expect(screen.getByText('App Information')).toBeInTheDocument();
  });

  it('displays all stations', () => {
    render(
      <AboutDialog
        isOpen={true}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    expect(screen.getByText('Available Stations (3)')).toBeInTheDocument();
    // Use getAllByText since station name appears in both list and current station info
    expect(screen.getAllByText('SR 1 Europawelle').length).toBeGreaterThan(0);
    expect(screen.getAllByText('SR 2 KulturRadio').length).toBeGreaterThan(0);
    expect(screen.getAllByText('SR 3 Saarlandwelle').length).toBeGreaterThan(0);
  });

  it('shows active badge for current station', () => {
    render(
      <AboutDialog
        isOpen={true}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    expect(screen.getByText('Active')).toBeInTheDocument();
  });

  it('displays zopyx.com link', () => {
    render(
      <AboutDialog
        isOpen={true}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    expect(screen.getByText('www.zopyx.com →')).toBeInTheDocument();
  });

  it('displays disclaimer', () => {
    render(
      <AboutDialog
        isOpen={true}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    expect(screen.getByText(/unofficial third-party app/i)).toBeInTheDocument();
  });

  it('calls onClose when clicking close button', () => {
    const onClose = vi.fn();
    render(
      <AboutDialog
        isOpen={true}
        onClose={onClose}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    const closeButton = screen.getByLabelText('Close');
    fireEvent.click(closeButton);
    expect(onClose).toHaveBeenCalled();
  });

  it('calls onClose when clicking overlay', () => {
    const onClose = vi.fn();
    render(
      <AboutDialog
        isOpen={true}
        onClose={onClose}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    const overlay = screen.getByLabelText('Close').parentElement?.parentElement;
    if (overlay) {
      fireEvent.click(overlay);
      expect(onClose).toHaveBeenCalled();
    }
  });

  it('displays station website link', () => {
    render(
      <AboutDialog
        isOpen={true}
        onClose={() => {}}
        stations={mockStations}
        currentStation={mockCurrentStation}
      />
    );
    const visitLink = screen.getByText('Visit →');
    expect(visitLink).toBeInTheDocument();
    expect(visitLink).toHaveAttribute('href', 'https://www.sr.de/sr2');
  });

  it('calls onStationChange and onClose when clicking a different station', () => {
    const onStationChange = vi.fn();
    const onClose = vi.fn();
    
    render(
      <AboutDialog
        isOpen={true}
        onClose={onClose}
        stations={mockStations}
        currentStation={mockCurrentStation}
        onStationChange={onStationChange}
      />
    );
    
    // Click on SR1 station card (not the active one)
    const sr1Button = screen.getByLabelText('Select SR 1 Europawelle');
    fireEvent.click(sr1Button);
    
    expect(onStationChange).toHaveBeenCalledWith(mockStations[0]);
    expect(onClose).toHaveBeenCalled();
  });

  it('does not call onStationChange when clicking the active station', () => {
    const onStationChange = vi.fn();
    const onClose = vi.fn();
    
    render(
      <AboutDialog
        isOpen={true}
        onClose={onClose}
        stations={mockStations}
        currentStation={mockCurrentStation}
        onStationChange={onStationChange}
      />
    );
    
    // Try to click on SR2 (the active station) - button should be disabled
    const sr2Button = screen.getByLabelText('Select SR 2 KulturRadio');
    expect(sr2Button).toBeDisabled();
    
    fireEvent.click(sr2Button);
    expect(onStationChange).not.toHaveBeenCalled();
    expect(onClose).not.toHaveBeenCalled();
  });
});
