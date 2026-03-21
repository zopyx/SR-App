# Mac App Store Submission Guide

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Enroll at [developer.apple.com](https://developer.apple.com)
   - Complete organization verification if needed

2. **Certificates & Provisioning**
   - Open Xcode → Preferences → Accounts
   - Download certificates:
     - Apple Distribution
     - Mac Installer Distribution
   - Create Mac App Store provisioning profile

## Build Configuration

### 1. Update Signing Identity

Edit `src-tauri/tauri.conf.json`:
```json
{
  "bundle": {
    "macOS": {
      "signingIdentity": "Apple Distribution: Your Name (TEAM_ID)",
      "providerShortName": "TEAM_ID"
    }
  }
}
```

### 2. Build for App Store

```bash
# Build universal binary (Intel + Apple Silicon)
npm run tauri:build:universal

# Or build for specific architecture
npm run tauri:build -- --target aarch64-apple-darwin
```

### 3. Create App Package

```bash
# The .app bundle will be at:
src-tauri/target/universal-apple-darwin/release/bundle/macos/SR2 Radio.app
```

## App Store Connect

### 1. Create App Record

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps" → "+" → "New App"
3. Select macOS platform
4. Fill:
   - Name: SR2 Radio
   - Primary Language: English
   - Bundle ID: com.sr2radio
   - SKU: sr2-radio-001

### 2. Required Information

**App Information:**
- Subtitle: Listen to SR radio stations
- Category: Music
- Content Rights: No

**Pricing & Availability:**
- Price: Free
- Availability: All territories

**App Privacy:**
- Data collection: No data collected
- Privacy policy URL: (your website)

### 3. Screenshots

Required sizes:
- 1280x800 (16:10)
- 1440x900 (16:10)
- 2880x1800 (16:10, Retina)

Take screenshots of:
- Main player view
- Station selector
- About dialog

### 4. Upload Build

Option A: Transporter App
```bash
# Download Transporter from Mac App Store
# Drag .app bundle and submit
```

Option B: Xcode
```bash
# Create .pkg for App Store
productbuild --component "SR2 Radio.app" /Applications --sign "3rd Party Mac Developer Installer: Your Name" SR2Radio.pkg
```

## Review Guidelines Checklist

- [x] App uses public APIs only (no private API usage)
- [x] App is sandboxed with entitlements
- [x] App has appropriate CSP
- [x] No prohibited content
- [x] App performs as advertised
- [x] Metadata is accurate

## Common Issues

### Issue: "App uses non-public API"
**Solution:** Ensure `macOSPrivateApi: false` in tauri.conf.json

### Issue: "App is not sandboxed"
**Solution:** Verify entitlements.plist includes `com.apple.security.app-sandbox`

### Issue: "Network connections fail"
**Solution:** Ensure `com.apple.security.network.client` entitlement is set

### Issue: "Audio doesn't play"
**Solution:** Ensure `com.apple.security.device.audio` entitlement is set

## Post-Submission

- Review typically takes 24-48 hours
- Monitor App Store Connect for status updates
- Be prepared to provide additional information if requested
