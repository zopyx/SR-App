import { describe, it, expect } from 'vitest';
import { stations, defaultStation, type Station } from '../src/data/stations';

describe('Stations Data', () => {
  it('should have exactly 3 stations', () => {
    expect(stations).toHaveLength(3);
  });

  it('should have SR1, SR2, and SR3 stations', () => {
    const ids = stations.map(s => s.id);
    expect(ids).toContain('sr1');
    expect(ids).toContain('sr2');
    expect(ids).toContain('sr3');
  });

  it('each station should have required properties', () => {
    stations.forEach((station: Station) => {
      expect(station.id).toBeDefined();
      expect(station.name).toBeDefined();
      expect(station.shortName).toBeDefined();
      expect(station.description).toBeDefined();
      expect(station.streamUrl).toBeDefined();
      expect(station.logoUrl).toBeDefined();
      expect(station.color).toBeDefined();
      expect(station.website).toBeDefined();
    });
  });

  it('should have valid stream URLs', () => {
    stations.forEach((station: Station) => {
      expect(station.streamUrl).toMatch(/^https:\/\//);
      expect(station.streamUrl).toContain('.mp3');
    });
  });

  it('should have valid hex color codes', () => {
    stations.forEach((station: Station) => {
      expect(station.color).toMatch(/^#[0-9a-fA-F]{6}$/);
    });
  });

  it('should have correct logo URLs', () => {
    stations.forEach((station: Station) => {
      expect(station.logoUrl).toMatch(/^\/.+_logo\.png$/);
    });
  });

  it('should have SR2 as default station', () => {
    expect(defaultStation.id).toBe('sr2');
    expect(defaultStation.shortName).toBe('SR2');
  });

  it('SR1 should have red color', () => {
    const sr1 = stations.find(s => s.id === 'sr1');
    expect(sr1?.color.toLowerCase()).toBe('#e60005');
  });

  it('SR2 should have gold color', () => {
    const sr2 = stations.find(s => s.id === 'sr2');
    expect(sr2?.color.toLowerCase()).toBe('#ffb700');
  });

  it('SR3 should have blue color', () => {
    const sr3 = stations.find(s => s.id === 'sr3');
    expect(sr3?.color.toLowerCase()).toBe('#0082c9');
  });
});
