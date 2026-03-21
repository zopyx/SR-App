import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import App from '../src/App';

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
  fetchCurrentSong: vi.fn(() => Promise.resolve({
    title: 'Test Song',
    artist: 'Test Artist',
    show: 'Test Show',
    moderator: 'Test Moderator'
  })),
}));

describe('App Component', () => {
  it('renders the app', () => {
    render(<App />);
    expect(document.querySelector('.app-container')).toBeInTheDocument();
  });

  it('renders info button', () => {
    render(<App />);
    expect(screen.getByLabelText('About SR Radio')).toBeInTheDocument();
  });

  it('opens about dialog when clicking info button', async () => {
    render(<App />);
    const infoButton = screen.getByLabelText('About SR Radio');
    fireEvent.click(infoButton);
    // Wait for dialog to open (it may take a moment for async data)
    const dialogTitle = await screen.findByText('SR Radio Player', {}, { timeout: 2000 });
    expect(dialogTitle).toBeInTheDocument();
  });

  it('renders footer', () => {
    render(<App />);
    expect(screen.getByText(/SR Radio Player • 3 Stations/i)).toBeInTheDocument();
  });

  it('renders RadioPlayer component', () => {
    render(<App />);
    expect(screen.getByText('SR 2 KulturRadio')).toBeInTheDocument();
  });
});
