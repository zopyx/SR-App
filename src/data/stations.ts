export interface Station {
  id: string;
  name: string;
  shortName: string;
  description: string;
  streamUrl: string;
  logoUrl: string;
  color: string;
  website: string;
}

export const stations: Station[] = [
  {
    id: 'sr1',
    name: 'SR 1 Europawelle',
    shortName: 'SR1',
    description: 'Saarlands beste Musik und Nachrichten',
    streamUrl: 'https://liveradio.sr.de/sr/sr1/mp3/256/stream.mp3?aggregator=custom1',
    logoUrl: '/sr1_logo.png',
    color: '#e60005', // Red
    website: 'https://www.sr.de/sr1'
  },
  {
    id: 'sr2',
    name: 'SR 2 KulturRadio',
    shortName: 'SR2',
    description: 'Kultur, Wort und klassische Musik',
    streamUrl: 'https://liveradio.sr.de/sr/sr2/mp3/256/stream.mp3?aggregator=custom1',
    logoUrl: '/sr2_logo.png',
    color: '#ffb700', // Gold
    website: 'https://www.sr.de/sr2'
  },
  {
    id: 'sr3',
    name: 'SR 3 Saarlandwelle',
    shortName: 'SR3',
    description: 'Die beste Musik für das Saarland',
    streamUrl: 'https://liveradio.sr.de/sr/sr3/mp3/256/stream.mp3?aggregator=custom1',
    logoUrl: '/sr3_logo.png',
    color: '#0082c9', // Blue
    website: 'https://www.sr.de/sr3'
  }
];

export const defaultStation = stations[1]; // SR2 is default
