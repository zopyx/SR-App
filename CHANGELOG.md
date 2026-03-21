# Changelog

All notable changes to the SR2 Radio project.

## [0.2.4] - 2026-03-21

### Bug Fixes
- **Fixed streaming**: Added CDN domains (*.rndfnk.com) to CSP allowlist
- **Fixed window dragging**: Window can now be moved by dragging

---

## [0.2.3] - 2026-03-21

### Security Improvements
- **Tightened CSP further**: `connect-src` now restricted to `'self'` only

### Code Quality
- **Safer polling lifecycle**: Prevent rescheduling when there are no listeners
- **Test coverage**: Added test asserting no timers on one-shot now-playing fetch
- **Test stability**: About dialog alignment test now asserts CSS rule

### Testing
- **All tests pass**: 39 unit tests passing (`npm test`)

---

## [0.2.2] - 2026-03-21

### Bug Fixes
- **Volume change no longer reloads stream**: Separated audio initialization, station changes, and volume updates into distinct effects
- **Right-aligned values in About dialog**: Tagline and other values now properly right-aligned

### Code Quality
- **Added regression test**: Test for right-aligned values in About dialog

---

## [0.2.1] - 2026-03-21

### Security Improvements
- **Tightened CSP**: Restricted to only required SR domains
- **Station ID validation**: Added allowlist check in Rust backend
- **HTTP timeouts**: Added 10-second timeout to all requests
- **Removed unused plugin**: Removed tauri_plugin_opener to reduce attack surface

### Code Quality
- **Fixed hook dependencies**: Resolved stale closure issues in RadioPlayer
- **Fixed polling race**: Added generation counter to prevent stale updates
- **Proper timeout cleanup**: All timeouts now cleaned up on unmount
- **Guarded console logs**: Production builds no longer log debug info
- **Fixed clipboard handling**: Added proper error handling for copy operations
- **Fixed React imports**: Added proper React imports for TypeScript

### Testing
- **All tests pass**: 38 unit tests passing
- **Test configuration**: Fixed Vitest to exclude Playwright tests

---

## [0.2.0] - 2026-03-21

### Features

#### Compact Slick UI
- **Smaller window**: 400x600 → 320x400 (sleeker, more compact)
- **Redesigned layout**: Vertically centered, better spacing
- **Smaller play button**: 180px → 100px (more proportional)
- **Aligned elements**: Station selector at top, info button top-right
- **No scrolling**: All elements fit in fixed window size

#### Compact/Minimize Mode
- Toggle button (—/□) to minimize UI
- Minimized view shows only: station selector, play button, volume
- Expand back to full view with one click

#### About Dialog Improvements
- **Station selector in About**: Click any station card to switch
- **www.zopyx.com link**: Added to App Information section
- **Build date display**: Shows build timestamp
- **Better disclaimer**: Clearer unofficial app notice

#### Native macOS Integration
- Traffic light buttons (close/minimize/maximize) visible
- Overlay title bar style with native macOS behavior
- Proper window styling for macOS vibrancy

### Testing

#### Comprehensive Test Suite
- **38 tests** across 5 test files
- Tests for: stations, now playing, RadioPlayer, AboutDialog, App
- Vitest + React Testing Library + jsdom
- Run with `npm test`

### Developer Experience

#### AGENTS.md Updates
- Yolo mode workflow documentation
- Subagent usage guidelines
- Testing requirements: "Write a test for every bug fix"
- UI constraints: "No scrolling in default window"

### Technical Changes

#### Dependencies
- Added: `vitest`, `@testing-library/react`, `@testing-library/jest-dom`, `jsdom`

#### Configuration
- Window size: 320x400 (was 400x600)
- Title bar: Overlay style with hidden title
- Top padding: 28px for traffic light clearance

---

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
- [ ] Code signing for distribution

### Platform Support
- [x] macOS (Apple Silicon)
- [ ] Windows
- [ ] Linux
