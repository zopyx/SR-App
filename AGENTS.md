# Saar Streams - Agent Guide

## Project Overview

A native iOS/iPadOS radio streaming app for Saarland radio stations, built with:
- **App**: SwiftUI (iOS-only)
- **Live Activity**: Dynamic Island + Lock Screen via ActivityKit
- **Streaming**: AVFoundation audio player

### Supported Stations (15)

**Saarländischer Rundfunk:** SR 1, SR kultur, SR 3 Saarlandwelle, SR UnserDing, Antenne Saar
**Privatsender:** Radio Salü, bigFM Saarland, CityRadio (Saarbrücken, Neunkirchen, Homburg, Saarlouis, St. Wendel), Radio Saarschleifenland, Classic Rock Radio, Radio Schlagerparadies

## Architecture

```
sr2/
└── SRRadio/
    ├── Sources/
    │   ├── App/              # App entry point (SRRadioApp.swift)
    │   ├── Models/           # Station model + ActivityAttributes
    │   ├── Services/         # AudioPlayer, NowPlayingService, LiveActivityManager
    │   ├── Utils/            # VisualEffectView
    │   ├── Views/            # SwiftUI views (PlayerView, StationSelector, AboutView, StationLogo, etc.)
    │   └── Design/           # Theme constants
    ├── Resources/
    │   ├── Assets.xcassets   # Logos (SR only) + AppIcon
    │   └── Info-iOS.plist    # iOS Info.plist
    ├── SRRadioLiveActivity/  # Widget Extension (Dynamic Island + Lock Screen)
    │   ├── SRRadioLiveActivity.swift
    │   ├── SRRadioLiveActivityBundle.swift
    │   └── Info.plist
    └── SRRadio.xcodeproj
```

## Key Features

| Feature | Implementation |
|---------|---------------|
| Station switching | Full-screen picker with search |
| Volume control | Custom SwiftUI slider (0-100%) |
| Play/Pause | Tap station logo |
| Now Playing | SR stations only (HTML scraping + EPG API) |
| Live Activity | Dynamic Island + Lock Screen (iOS 16.2+) |
| About dialog | Current stream info + app details |
| Station logos | SR stations: image assets; others: colored initials |

## Coding Conventions

### Swift
- SwiftUI for all UI
- iOS/iPadOS only — no macOS code
- `struct` views, `ObservableObject` for state
- German UI strings (hardcoded, no localization framework)
- Availability checks: `@available(iOS 16.2, *)` for Live Activity APIs

## Development Commands

```bash
# Build for iOS Simulator
xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadio -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" -configuration Debug build

# Archive for device
xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadio -destination "generic/platform=iOS" -configuration Release archive -archivePath /tmp/SRRadio.xcarchive
```

## Common Tasks

### Add/update stations
Edit `SRRadio/Sources/Models/Station.swift` — add to `Station.all` array. For SR stations, set `logoName` to asset name. For others, set `logoName` to `""` (shows colored initials via `StationLogo`).

### Modify player behavior
Edit `SRRadio/Sources/Views/PlayerView.swift`

### Update Live Activity UI
Edit `SRRadio/SRRadioLiveActivity/SRRadioLiveActivity.swift`

## CI/CD

- **Xcode Cloud** on branch `swift`
- Widget extension bundle ID: `com.sr2radio.SRRadioLiveActivity`
- Both App IDs must be registered at developer.apple.com
- Extension requires explicit `Info.plist` with `NSExtensionPointIdentifier`

## Known Limitations

- Stream requires internet (no offline mode)
- Volume is app-level, not system-level
- Now Playing metadata only for SR stations (others lack compatible API)
- Dynamic Island requires iPhone 14 Pro+ (falls back to Lock Screen banner)

## Agent Workflow

### Git Workflow
- **NEVER commit or push automatically** - Only commit/push when the user explicitly requests it
- Wait for explicit user confirmation before making any git mutations
- Do NOT commit after every fix - batch changes and wait for user instruction
- Always show the user what files would be committed before committing

### Test Requirement
**IMPORTANT:** Before claiming a task is complete or terminated:
1. Run the build: `xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadio -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" -configuration Debug build`
2. Verify **BUILD SUCCEEDED** with no errors
3. Run tests if test files were modified
4. Do NOT commit until all tests pass AND user explicitly requests commit

### UI Language
- All user-facing strings are in **German**
- Keep labels concise for mobile display

### Development with Subagents
For complex multi-file changes or large refactoring tasks, use subagents via the `Task` tool:
- Spawn subagents for independent workstreams (e.g., UI changes vs. model updates)
- Use context isolation to keep the main context clean
- Parallelize work when tasks are independent (e.g., multiple view updates)
- Example: When adding a new feature that touches Models, Views, and Services, spawn 3 subagents to work on each layer concurrently
