# SR2 Radio - Tauri App

A native macOS & iOS radio player for SR2 Kultur built with React, TypeScript, Vite, and Tauri.

## Features

- Clean, native macOS interface with vibrancy effects
- iOS app support (iPhone/iPad)
- Lightweight and fast (Rust backend)
- Single-station focus: SR2 Kultur radio stream
- Compact player window (400x600)
- Hidden title bar with overlay style
- Keyboard shortcuts (Space to play/pause, Cmd+Q to quit)

## Development

### Prerequisites

- [Node.js](https://nodejs.org/) (v18 or later)
- [Rust](https://rustup.rs/) (latest stable)
- macOS 10.15 or later

### Setup

```bash
# Install dependencies
npm install

# Run development server
npm run tauri:dev
```

### Building

```bash
# Build for macOS (ARM64 - Apple Silicon)
npm run tauri:build

# Build Universal macOS binary (Intel + Apple Silicon)
npm run tauri:build:universal
```

### iOS Build

```bash
# Initialize iOS project (one-time setup)
npm run tauri ios init

# Build and run on iOS Simulator
npm run tauri ios dev

# Build for device
npm run tauri ios build
```

To open in Xcode:
```bash
open src-tauri/gen/apple/sr2.xcodeproj
```

### Output

**macOS:**
- App Bundle: `src-tauri/target/release/bundle/macos/SR2 Radio.app`
- DMG Installer: `src-tauri/target/release/bundle/dmg/SR2 Radio_*.dmg`

**iOS:**
- Xcode Project: `src-tauri/gen/apple/sr2.xcodeproj`
- Build Archive: Use Xcode to export IPA

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

- **Frontend**: React 19 + TypeScript + Vite
- **Backend**: Tauri v2 (Rust)
- **Desktop**: macOS app with native vibrancy
- **Mobile**: iOS app (iPhone/iPad support)
- **Build**: Xcode + CocoaPods

## License

MIT
