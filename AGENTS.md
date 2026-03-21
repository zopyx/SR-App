# SR Radio Player - Agent Guide

## Project Overview

A native macOS/iOS radio player for Saarländischer Rundfunk (SR) stations, built with:
- **App**: SwiftUI (shared iOS + macOS code)
- **UI**: Native macOS vibrancy effects

### Supported Stations
- **SR1 Europawelle** (Red) - News and pop music
- **SR2 KulturRadio** (Gold) - Culture and classical music
- **SR3 Saarlandwelle** (Blue) - Regional music

## Architecture

```
sr2/
└── SRRadio/
    ├── Sources/
    │   ├── App/              # App entry point
    │   ├── Models/           # Station model
    │   ├── Services/         # Audio + now playing
    │   ├── Utils/            # Helpers (e.g. VisualEffectView)
    │   ├── Views/            # SwiftUI views
    │   └── Design/           # Theme constants
    ├── Resources/
    │   ├── Assets.xcassets   # Logos + AppIcon
    │   ├── LaunchScreen.storyboard
    │   ├── Info.plist        # macOS Info.plist
    │   └── Info-iOS.plist    # iOS Info.plist
    └── SRRadio.xcodeproj
```

## Key Features

| Feature | Implementation |
|---------|---------------|
| Station switching | SwiftUI picker with auto-play |
| Volume control | Custom SwiftUI slider (0-100%) |
| Play/Pause | Tap logo |
| About dialog | SwiftUI modal |
| Keyboard shortcuts | macOS app menu |
| Visual effects | macOS vibrancy via `VisualEffectView` |

## Coding Conventions

### Swift
- Use SwiftUI for UI
- Keep platform-specific code under `#if os(macOS)` / `#if os(iOS)`
- Prefer `struct` views and `ObservableObject` for state
- Avoid force unwraps unless proven safe

## Development Commands

```bash
# Build macOS app
xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadio -configuration Debug build

# Build iOS simulator app (target name may be "SRRadio iOS")
xcodebuild -project SRRadio/SRRadio.xcodeproj -target "SRRadio iOS" -destination "platform=iOS Simulator,name=iPhone 16 Pro" -configuration Debug build
```

## Common Tasks

### Update stream URLs
Edit `SRRadio/Sources/Models/Station.swift`

### Modify player behavior
Edit `SRRadio/Sources/Views/PlayerView.swift`

### Style the UI
Edit `SRRadio/Sources/Design/Theme.swift`

## Testing

Run tests via Xcode (no CLI tests configured yet).

## Known Limitations

- Stream requires internet connection (no offline mode)
- Volume is app-level, not system-level

## Agent Workflow (Yolo Mode)

This project uses **Yolo Mode** - agents should be decisive and make minimal changes to achieve goals efficiently.

### Versioning

- Use semantic versioning for releases and tags (e.g., `1.2.3`).
- Update version in Xcode build settings / Info.plist.

### Git Workflow

**Do not commit and push at your own will:**
- Only commit and push when explicitly requested by the user.
- Wait for user confirmation before making git mutations.

**No commit, no push if tests are failing:**
- Always run tests before committing.
- All tests must pass before commit and push.

### UI Constraints

**No scrolling in default window:**
- All UI elements must fit within the fixed window size (320x480).
- No overflow-y or scrollbars in the main player view.
- Use compact mode or truncation for long text.

## Resources

- [SR Streams](https://www.sr.de/sr/home/radio/index.html)
- Design: macOS Human Interface Guidelines
