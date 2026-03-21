# SR Radio

A native SwiftUI macOS/iOS radio player for Saarländischer Rundfunk (SR) stations.

## Stations

- SR1 Europawelle
- SR2 KulturRadio
- SR3 Saarlandwelle

## Build

### macOS

```bash
xcodebuild -project SRRadio/SRRadio.xcodeproj -scheme SRRadio -configuration Debug build
```

### iOS Simulator

```bash
xcodebuild -project SRRadio/SRRadio.xcodeproj -target "SRRadio iOS" -destination "platform=iOS Simulator,name=iPhone 16 Pro" -configuration Debug build
```

## Project Layout

```
SRRadio/
  Sources/
  Resources/
  SRRadio.xcodeproj/
```
