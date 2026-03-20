# SR Radio Player - Agent Guide

## Project Overview

A native macOS/iOS radio player for Saarländischer Rundfunk (SR) stations, built with:
- **Frontend**: React 19 + TypeScript + Vite
- **Backend**: Tauri v2 (Rust)
- **UI**: Native macOS vibrancy effects

### Supported Stations
- **SR1 Europawelle** (Red) - News and pop music
- **SR2 KulturRadio** (Gold) - Culture and classical music  
- **SR3 Saarlandwelle** (Blue) - Regional music

## Architecture

```
sr2/
├── src/                      # React frontend
│   ├── components/
│   │   ├── RadioPlayer.tsx   # Main player component
│   │   └── AboutDialog.tsx   # About modal
│   ├── data/
│   │   └── stations.ts       # Station definitions
│   ├── App.tsx               # Root component
│   └── index.css             # Global styles
├── src-tauri/                # Rust backend
│   ├── src/
│   │   ├── main.rs           # Desktop entry point
│   │   └── lib.rs            # Shared library
│   ├── Cargo.toml            # Rust dependencies
│   └── tauri.conf.json       # Tauri configuration
├── public/                   # Static assets
│   ├── sr1_logo.png
│   ├── sr2_logo.png
│   └── sr3_logo.png
└── package.json
```

## Key Features

| Feature | Implementation |
|---------|---------------|
| Station switching | Dropdown selector with auto-play |
| Volume control | Range slider (0-100%) |
| Play/Pause | Click logo or Space key |
| About dialog | ℹ button + native menu |
| Keyboard shortcuts | Space, Cmd+Q, Cmd+M |
| Visual effects | Glass morphism, equalizer animation |

## Coding Conventions

### TypeScript
- Use strict types, avoid `any`
- Prefer interfaces over types
- Use functional components with hooks
- Export components as named exports

### CSS
- Use CSS variables for theming
- Mobile-first responsive design
- macOS vibrancy: `backdrop-filter: blur(20px)`
- Station colors via CSS custom properties

### Rust
- Follow Rust naming conventions
- Use `?` operator for error handling
- Platform-specific code behind `#[cfg(target_os = "macos")]`

## Development Commands

```bash
# Development (hot reload)
npm run tauri:dev

# Build release
npm run tauri:build

# Build universal macOS binary
npm run tauri:build:universal
```

## UI Patterns

### Color Scheme
- Background: `rgba(30, 30, 30, 0.65)` with blur
- Text primary: `rgba(255, 255, 255, 0.95)`
- Text secondary: `rgba(255, 255, 255, 0.6)`
- Station colors: SR1=#e60005, SR2=#ffb700, SR3=#0082c9

### Animations
- Use `cubic-bezier(0.34, 1.56, 0.64, 1)` for spring effects
- Respect `prefers-reduced-motion`
- Duration: 150ms fast, 250ms base, 400ms slow

## Adding New Stations

1. Add to `src/data/stations.ts`:
```typescript
{
  id: 'sr4',
  name: 'SR 4',
  shortName: 'SR4',
  description: 'Description',
  streamUrl: 'https://...',
  logoUrl: '/sr4_logo.png',
  color: '#00ff00',
  website: 'https://...'
}
```

2. Add logo to `public/`

## Common Tasks

### Update stream URLs
Edit `src/data/stations.ts` - URLs use `liveradio.sr.de` CDN

### Modify player behavior
Edit `src/components/RadioPlayer.tsx`
- `attemptPlay()` - Playback logic
- `handleStationSelect()` - Station switching

### Add keyboard shortcuts
Edit `src-tauri/src/lib.rs` for global shortcuts
Edit component `onKeyDown` handlers for local shortcuts

### Style the UI
Edit `src/index.css` - uses CSS variables for consistency

## Testing

Test on macOS with:
- Light/Dark mode
- Different window sizes (400x600 fixed)
- Keyboard navigation (Tab, Space, Enter)
- Multiple stations switching

## Build Output

```
src-tauri/target/release/bundle/
├── macos/SR2 Radio.app      # Main app bundle
└── dmg/                     # Installer (optional)
```

## Known Limitations

- iOS build needs proper bundle ID setup for device deployment
- Stream requires internet connection (no offline mode)
- Volume is app-level, not system-level

## Resources

- [Tauri Docs](https://tauri.app/v2/api/)
- [SR Streams](https://www.sr.de/sr/home/radio/index.html)
- Design: macOS Human Interface Guidelines
