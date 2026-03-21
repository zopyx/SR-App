# SR Radio - Swift Implementation

A native macOS radio player for Saarländischer Rundfunk (SR) stations, built with SwiftUI and AppKit.

## Features

- **Three SR Radio Stations**: SR1 Europawelle, SR2 KulturRadio, SR3 Saarlandwelle
- **Live Audio Streaming**: 256 kbps MP3 streams
- **Now Playing Info**: Real-time track and show information
- **Native macOS UI**: Vibrancy effects, glass morphism design
- **Volume Control**: With mute/unmute functionality
- **Keyboard Shortcuts**: Space to play/pause
- **About Dialog**: Station information and app details

## Architecture

```
SRRadio/
├── Sources/
│   ├── App/
│   │   └── SRRadioApp.swift          # App entry point
│   ├── Models/
│   │   └── Station.swift             # Station data models
│   ├── Services/
│   │   ├── AudioPlayer.swift         # AVPlayer wrapper
│   │   └── NowPlayingService.swift   # Now playing API
│   ├── Utils/
│   │   └── VisualEffectView.swift    # NSVisualEffectView wrapper
│   └── Views/
│       ├── PlayerView.swift          # Main player UI
│       ├── AboutView.swift           # About dialog
│       ├── EqualizerView.swift       # Animated equalizer
│       ├── NowPlayingView.swift      # Now playing display
│       ├── StationSelector.swift     # Station dropdown
│       └── VolumeControl.swift       # Volume slider
├── Resources/
│   ├── Assets.xcassets/              # App icons and images
│   └── Info.plist                    # App configuration
└── SRRadio.xcodeproj/                # Xcode project
```

## Requirements

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9

## Building

### Using Xcode

1. Open `SRRadio.xcodeproj` in Xcode
2. Select your target device (My Mac)
3. Build and run (⌘R)

### Using Command Line

```bash
cd SRRadio
xcodebuild -project SRRadio.xcodeproj -scheme SRRadio -configuration Release
```

## Configuration

### Stations

Stations are defined in `Sources/Models/Station.swift`:

- SR1: Red (#e60005) - News and pop music
- SR2: Gold (#ffb700) - Culture and classical (default)
- SR3: Blue (#0082c9) - Regional music

### Stream URLs

Streams are fetched from `liveradio.sr.de` CDN at 256 kbps MP3 quality.

### Now Playing API

The app fetches now playing data from:
- Song info: `https://musikrecherche.sr-online.de/sophora/titelinterpret.php`
- Show info: `https://www.sr.de/sr/epg/nowPlaying.jsp`

## Design

The UI follows macOS design guidelines with:
- Vibrancy effects using `NSVisualEffectView`
- Fixed 320x400 window size
- Glass morphism styling
- Station-specific accent colors
- Smooth animations

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Space | Play/Pause |
| ⌘Q | Quit |
| ⌘W | Close Window |
| ⌘M | Minimize |

## License

MIT License - See LICENSE file for details.

## Disclaimer

This is an unofficial third-party app. SR1, SR2, SR3 and Saarländischer Rundfunk are trademarks of Saarländischer Rundfunk.
