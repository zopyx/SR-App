# macOS Notarization Guide

Distribute SR2 Radio outside the Mac App Store (direct download).

## Prerequisites

1. **Apple Developer Account** ($99/year)
2. **Developer ID certificates**:
   - Developer ID Application: Your Name
   - Developer ID Installer: Your Name

## Setup

### 1. Create App-Specific Password

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in → "App-Specific Passwords"
3. Generate password (e.g., "sr2-notarize")
4. Save it - you'll need it for notarization

### 2. Store Credentials

Create `~/.private_keys/notarization-creds.json`:
```json
{
  "appleId": "your-email@example.com",
  "teamId": "YOUR_TEAM_ID",
  "password": "xxxx-xxxx-xxxx-xxxx"
}
```

Or use environment variables:
```bash
export APPLE_ID="your-email@example.com"
export APPLE_TEAM_ID="YOUR_TEAM_ID"
export APPLE_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

### 3. Update Build Config

Edit `src-tauri/tauri.conf.json`:
```json
{
  "bundle": {
    "macOS": {
      "signingIdentity": "Developer ID Application: Your Name",
      "entitlements": "entitlements.plist"
    }
  }
}
```

## Build & Notarize

### Option 1: Using Tauri (Recommended)

```bash
# Build signed app
npm run tauri:build

# The .dmg will be at:
# src-tauri/target/release/bundle/dmg/SR2 Radio_0.2.2_aarch64.dmg
```

### Option 2: Manual Notarization

```bash
# 1. Build
npm run tauri:build

# 2. Create DMG (if not already)
cd src-tauri/target/release/bundle/macos
mkdir -p dmg
cp -r "SR2 Radio.app" dmg/
hdiutil create -volname "SR2 Radio" -srcfolder dmg -ov -format UDZO "SR2 Radio.dmg"

# 3. Submit for notarization
xcrun notarytool submit "SR2 Radio.dmg" \
  --apple-id "$APPLE_ID" \
  --team-id "$APPLE_TEAM_ID" \
  --password "$APPLE_PASSWORD" \
  --wait

# 4. Staple ticket to DMG
xcrun stapler staple "SR2 Radio.dmg"

# 5. Verify
spctl -a -t open --context context:primary-signature -v "SR2 Radio.dmg"
```

## Automated Notarization Script

Save as `scripts/notarize.sh`:
```bash
#!/bin/bash
set -e

APP_NAME="SR2 Radio"
DMG_PATH="src-tauri/target/release/bundle/dmg/${APP_NAME}_$(cat src-tauri/tauri.conf.json | grep version | head -1 | awk -F: '{print $2}' | tr -d '",' | xargs)_aarch64.dmg"

echo "Notarizing $DMG_PATH..."

# Submit
xcrun notarytool submit "$DMG_PATH" \
  --keychain-profile "AC_PASSWORD" \
  --wait

# Staple
xcrun stapler staple "$DMG_PATH"

echo "✅ Notarization complete!"
```

## Distribution

After notarization, users can:
1. Download the `.dmg`
2. Open it (Gatekeeper will allow it)
3. Drag to Applications
4. Run without warnings

## Troubleshooting

### "App is damaged" error
```bash
# Re-sign the app
codesign --force --deep --sign "Developer ID Application: Your Name" "SR2 Radio.app"
```

### Notarization fails
Check logs:
```bash
xcrun notarytool log SUBMISSION_ID \
  --apple-id "$APPLE_ID" \
  --team-id "$APPLE_TEAM_ID" \
  --password "$APPLE_PASSWORD"
```

### Stapling fails
Notarization might still be processing. Wait a few minutes and retry.

## Comparison with App Store

| Feature | Notarized DMG | Mac App Store |
|---------|---------------|---------------|
| **Ease** | Simple | Complex |
| **Private APIs** | ✅ Allowed | ❌ Blocked |
| **Updates** | Manual/Sparkle | Automatic |
| **Revenue** | Keep 100% | Apple takes 15-30% |
| **User trust** | High | Very High |
| **Review** | None | Required |

## Recommended: Dual Distribution

1. **Direct download** (notarized DMG) - Primary
2. **Mac App Store** - Additional reach

This gives you flexibility while maximizing distribution.
