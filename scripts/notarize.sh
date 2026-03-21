#!/bin/bash
set -e

# Notarization script for SR2 Radio
# Usage: ./scripts/notarize.sh [path-to-dmg]

DMG_PATH="${1:-src-tauri/target/release/bundle/dmg/SR2 Radio_0.2.2_aarch64.dmg}"

if [ ! -f "$DMG_PATH" ]; then
    echo "❌ DMG not found: $DMG_PATH"
    echo "Build first with: npm run tauri:build"
    exit 1
fi

echo "🔐 Notarizing: $DMG_PATH"

# Check for credentials
if [ -z "$APPLE_ID" ] || [ -z "$APPLE_TEAM_ID" ] || [ -z "$APPLE_PASSWORD" ]; then
    echo "⚠️  Using keychain profile 'AC_PASSWORD'"
    echo "   Set up with: xcrun notarytool store-credentials AC_PASSWORD"
    
    # Submit with keychain
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "AC_PASSWORD" \
        --wait
else
    echo "⚠️  Using environment variables"
    
    # Submit with env vars
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --team-id "$APPLE_TEAM_ID" \
        --password "$APPLE_PASSWORD" \
        --wait
fi

echo "📎 Stapling ticket..."
xcrun stapler staple "$DMG_PATH"

echo "✅ Notarization complete!"
echo ""
echo "Verify with:"
echo "  spctl -a -t open --context context:primary-signature -v \"$DMG_PATH\""
