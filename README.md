# Saar Streams

A native iOS/iPadOS radio streaming app for Saarland radio stations, built with SwiftUI and AVFoundation.

## Features

- **15 Radio Stations** from Saarländischer Rundfunk and private broadcasters
- **Live Activity** support for Dynamic Island and Lock Screen (iOS 16.2+)
- **Now Playing** metadata for SR stations (track title, artist, show, moderator)
- **Custom Volume Control** with mute functionality
- **Station Logos** for SR stations, colored initials for others
- **Dark Theme** with dynamic background colors per station
- **German UI** tailored for the Saarland region

## Supported Stations

### Saarländischer Rundfunk (SR)
| Station | Description |
|---------|-------------|
| SR 1 | Saarlands beste Musik und Nachrichten |
| SR kultur | Kultur, Wort und klassische Musik |
| SR 3 Saarlandwelle | Die beste Musik für das Saarland |
| SR UnserDing | Das junge Radio im Saarland |
| Antenne Saar | Hits und gute Laune |

### Private Sender
| Station | Description |
|---------|-------------|
| Radio Salü | Das Hitradio aus dem Saarland |
| bigFM Saarland | Deutschlands biggste Beats |
| CityRadio Saarbrücken | Dein Stadtradio für Saarbrücken |
| CityRadio Neunkirchen | Dein Stadtradio für Neunkirchen |
| CityRadio Homburg | Dein Stadtradio für Homburg |
| CityRadio Saarlouis | Dein Stadtradio für Saarlouis |
| CityRadio St. Wendel | Dein Stadtradio für St. Wendel |
| Radio Saarschleifenland | Radio aus dem Saarschleifenland |
| Classic Rock Radio | Die besten Classic Rock Hits |
| Radio Schlagerparadies | Die schönsten Schlager |

## Requirements

- iOS 16.0+ / iPadOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Build

### iOS Simulator

```bash
xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadio -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" -configuration Debug build
```

### Archive for Device

```bash
xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadio -destination "generic/platform=iOS" -configuration Release archive -archivePath /tmp/SaarStreams.xcarchive
```

### Run Tests

To run tests, first add the test target in Xcode:

1. Open `SRRadio/SRRadio.xcodeproj` in Xcode
2. File > New > Target...
3. Select "Unit Testing Bundle" for iOS
4. Name it "SRRadioTests"
5. Add all test files from the `Tests/` directory to the test target
6. Run tests with:

```bash
xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadioTests -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" test
```

## Project Structure

```
SRRadio/
├── Sources/
│   ├── App/              # App entry point (SRRadioApp.swift)
│   ├── Models/           # Station, NowPlayingData, PlayerState, RadioError
│   ├── Services/         # AudioPlayer, NowPlayingService, LiveActivityManager, Analytics
│   ├── Views/            # PlayerView, StationSelector, AboutView, StationLogo, etc.
│   ├── Utils/            # Color+Hex, Haptics, VisualEffectView
│   └── Design/           # Theme constants
├── Resources/
│   ├── Assets.xcassets   # Station logos (SR only) + AppIcon
│   └── Info-iOS.plist
├── SRRadioLiveActivity/  # Widget Extension (Dynamic Island + Lock Screen)
│   ├── SRRadioLiveActivity.swift
│   ├── SRRadioLiveActivityBundle.swift
│   └── Info.plist
├── Tests/                # Unit tests
└── ScreenshotUITests/    # UI screenshot generation tests
```

## Architecture

- **SwiftUI** for all user interfaces
- **ObservableObject** pattern for state management
- **Dependency Injection** via `Container` class (singleton/transient lifetimes)
- **Protocol-based design** for testability (`AudioPlayerProtocol`, `NowPlayingServiceProtocol`)
- **AVFoundation** for audio streaming
- **ActivityKit** for Live Activities

## Known Limitations

- Stream requires internet connection (no offline mode)
- Volume is app-level, not system-level
- Now Playing metadata only available for SR stations (others lack compatible API)
- Dynamic Island requires iPhone 14 Pro or newer (falls back to Lock Screen banner on other devices)

## Development

### Add/Update Stations

Edit `SRRadio/Sources/Models/Station.swift` — add to `Station.all` array:
- For SR stations: set `logoName` to asset name
- For private stations: set `logoName` to `""` (shows colored initials via `StationLogo`)

### Run Tests

```bash
xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadio -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" test
```

## CI/CD

- **Xcode Cloud** on branch `swift`
- Widget extension bundle ID: `com.sr2radio.SRRadioLiveActivity`
- Both App IDs must be registered at developer.apple.com

## License

This project is licensed under the [MIT License](LICENSE).

## Source Code

The source code is available on GitHub: [github.com/zopyx/SR-App](https://github.com/zopyx/SR-App/)

---

**Saar Streams** — Die besten Radio-Stationen aus dem Saarland.
