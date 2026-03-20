# Changelog

All notable changes to the SR2 Radio project.

## [0.0.0] - 2026-03-20

### Major Changes

#### Converted from Electron to Tauri
- **Complete migration** from Electron to Tauri v2 for better performance and smaller bundle size
- Reduced app size from ~100MB+ to ~4.4MB
- Native Rust backend with React frontend
- macOS-optimized build with native window styling

#### Project Structure
```
Before:                    After:
├── electron/              ├── src-tauri/
│   ├── main.ts            │   ├── src/main.rs
│   └── preload.ts         │   ├── Cargo.toml
├── dist-electron/         │   ├── tauri.conf.json
└── ...                    │   └── icons/
                          └── ...
```

### Security

#### Fixed Stream Playback (HTTPS)
- Changed stream URL from `http://` to `https://`
- Updated CSP configuration to allow HTTPS media streams
- Resolves "unable to play stream" error caused by mixed content blocking

### Features

#### Keyboard Shortcuts
- **Space** - Toggle play/pause (window focus)
- **Cmd+Q** (macOS) - Quit application
- **Cmd+M** (macOS) - Minimize window
- **Media Keys** - Play/Pause and Stop support (system-wide)

#### Error Handling & Logging
- Detailed audio error logging with network state and ready state
- Automatic retry logic (3 attempts, 2s delay) for failed streams
- User-friendly error messages mapped from MediaError codes
- Backend logging commands for frontend events
- Debug info visible in development mode

#### UI/UX Improvements
- **Animated equalizer** - 5-bar visualization when playing
- **macOS vibrancy** - Glass-like backdrop blur effects
- **Smooth hover effects** - Spring-physics scale animations
- **Loading states** - Dual-ring spinner with status indicators
- **Dark mode optimized** - Native color scheme with gold accent
- **Accessibility** - Keyboard navigation and reduced motion support

### Configuration

#### Tauri Configuration (`tauri.conf.json`)
- Window: 400x600, non-resizable
- Title bar: Overlay style with hidden title
- Transparent window with macOS vibrancy
- CSP: `default-src 'self'; media-src 'self' https:; connect-src 'self' https:`

#### Build Scripts
```json
{
  "tauri:dev": "tauri dev",
  "tauri:build": "tauri build",
  "tauri:build:universal": "tauri build --target universal-apple-darwin"
}
```

### Dependencies

#### Added
- `@tauri-apps/cli` ^2.4.1
- `@tauri-apps/api` ^2.4.1
- `tauri-plugin-global-shortcut` ^2
- `chrono` ^0.4 (Rust)

#### Removed
- `electron` ^39.2.4
- `electron-builder` ^26.0.12
- `electron-squirrel-startup` ^1.0.1
- `concurrently` ^9.2.1
- `cross-env` ^10.1.0
- `wait-on` ^9.0.3
- `@types/node` ^24.10.1

### Technical Details

#### Rust Backend (`src-tauri/src/main.rs`)
- Window setup with macOS-specific styling
- Global shortcut manager for system-wide hotkeys
- Custom commands:
  - `log_event` - General event logging
  - `log_audio_event` - Audio-specific logging
  - `log_audio_error` - Detailed error logging
  - `get_app_info` - App version info

#### Frontend (`src/`)
- React 19 with TypeScript
- Vite build system
- Tauri API integration for native features

### Assets

#### Icons
Generated from `public/sr2_logo.png`:
- `32x32.png` - Toolbar icon
- `128x128.png` - App icon
- `128x128@2x.png` - Retina display
- `icon.icns` - macOS app bundle
- `icon.ico` - Windows icon

### Build Output
```
src-tauri/target/release/bundle/
├── macos/
│   └── SR2 Radio.app          (4.4MB)
└── dmg/
    └── SR2 Radio_0.0.0_aarch64.dmg
```

---

## Original Electron Version

### Features
- Basic radio player with HTML5 audio
- Play/pause toggle
- Error display
- Simple loading indicator

### Known Issues
- Large bundle size (~100MB+)
- HTTP stream blocked in production
- Limited error handling
- No keyboard shortcuts
- Basic UI styling

---

## Future Enhancements

### Potential Features
- [ ] Volume control with slider
- [ ] Station presets/favorites
- [ ] Sleep timer
- [ ] Now playing metadata display
- [ ] Menu bar icon (tray)
- [ ] Auto-updater integration
- [ ] Universal binary (Intel + Apple Silicon)
- [ ] Code signing for distribution

### Platform Support
- [x] macOS (Apple Silicon)
- [ ] macOS (Intel) - via universal build
- [ ] Windows
- [ ] Linux
