#!/bin/bash

# Screenshot Capture Script for Saar Streams
# Captures screenshots in 1242 × 2688px (iPhone 11 Pro Max / XS Max)

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="SRRadio"
DESTINATION="platform=iOS Simulator,name=iPhone 16,OS=18.5"
SCREENSHOTS_DIR="$PROJECT_DIR/screenshots"

echo "📸 Saar Streams Screenshot Capture"
echo "=================================="

# Create screenshots directory
mkdir -p "$SCREENSHOTS_DIR"

# Build the app first
echo "🔨 Building app..."
cd "$PROJECT_DIR"
xcodebuild \
    -project "SRRadio/SRRadio.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    build

echo ""
echo "ℹ️  To capture screenshots manually:"
echo "   1. Run the app in iPhone 16 Pro Max simulator"
echo "   2. Use Cmd+S to save screenshots"
echo "   3. Screenshots will be saved to Desktop"
echo ""
echo "📁 Target directory: $SCREENSHOTS_DIR"
echo ""
echo "Required screenshots:"
echo "   1. Main Screen - Player view with station playing"
echo "   2. About Screen - Info dialog showing app details"
echo "   3. Settings Screen - Settings pane with default station"
echo ""
echo "Resolution: 1242 × 2688 pixels (iPhone 11 Pro Max / XS Max)"
