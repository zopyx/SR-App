# SR Radio Player

[![Visual Tests](https://github.com/zopyx/SR-App/actions/workflows/visual-tests.yml/badge.svg)](https://github.com/zopyx/SR-App/actions/workflows/visual-tests.yml)
[![Release](https://github.com/zopyx/SR-App/actions/workflows/release.yml/badge.svg)](https://github.com/zopyx/SR-App/actions/workflows/release.yml)

A native macOS and iOS radio player for Saarländischer Rundfunk (SR) stations, built with React, TypeScript, Vite, and Tauri.

## Stations

- SR1 Europawelle
- SR2 KulturRadio
- SR3 Saarlandwelle

## Features

- Station switching with auto-play
- Compact, fixed-size player window (320x480)
- Native macOS vibrancy and glass morphism effects
- Play/pause on station logo click
- Volume control (app-level)
- About dialog with station details
- Keyboard shortcuts for quick control

## Keyboard Shortcuts

- Space: Play/Pause
- Cmd+Q: Quit
- Cmd+M: Minimize

## Development

### Prerequisites

- Node.js 18+
- Rust (latest stable)
- macOS 10.15+ for desktop builds

### Setup

```bash
npm install
npm run tauri:dev
```

Makefile shortcuts:

```bash
make dev
make build
make test
make test-visual
make test-visual-update
```

### Build

```bash
npm run tauri:build
```

### iOS

```bash
npm run tauri ios init
npm run tauri ios dev
npm run tauri ios build
```

Open in Xcode:

```bash
open src-tauri/gen/apple/sr2.xcodeproj
```

## Testing

```bash
npm test
npm run test:visual
```

Update visual snapshots:

```bash
npm run test:visual:update
```

## CI/CD

- GitHub Actions runs visual regression tests and release packaging.
- You can run CI workflows locally with `act` before committing and pushing.

## Project Structure

```
sr2/
├── src/                   # React frontend source
│   ├── components/        # React components
│   ├── App.tsx            # Main app component
│   └── main.tsx           # Entry point
├── src-tauri/             # Tauri Rust backend
│   ├── src/main.rs        # Rust entry point
│   ├── Cargo.toml         # Rust dependencies
│   ├── tauri.conf.json    # Tauri configuration
│   └── gen/apple/         # iOS/macOS Xcode project
│       ├── sr2.xcodeproj  # Xcode project file
│       └── sr2_iOS/       # iOS-specific files
├── public/                # Static assets
└── dist/                  # Built frontend (generated)
```

## Technologies

- React 19 + TypeScript + Vite
- Tauri v2 (Rust backend)
- macOS and iOS builds via Xcode

## License

MIT
