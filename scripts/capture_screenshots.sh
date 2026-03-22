#!/bin/bash

# Screenshot Capture Script for Saar Streams
# Generates 1242 × 2688px screenshots for App Store submission
# 
# Usage: ./scripts/capture_screenshots.sh [--clean]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SCHEME="SRRadio"
SIMULATOR_NAME="iPhone 16"
SIMULATOR_OS="18.5"
SCREENSHOTS_DIR="$PROJECT_DIR/screenshots"
OUTPUT_DIR="$PROJECT_DIR/screenshots/AppStoreScreenshots"

# Parse arguments
CLEAN=false
for arg in "$@"; do
    case $arg in
        --clean)
            CLEAN=true
            shift
            ;;
    esac
done

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Saar Streams Screenshot Generator        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo -e "${YELLOW}🗑️  Cleaning existing screenshots...${NC}"
    rm -rf "$SCREENSHOTS_DIR"
    rm -rf "$OUTPUT_DIR"
fi

# Create directories
mkdir -p "$SCREENSHOTS_DIR"
mkdir -p "$OUTPUT_DIR"

# Check if simulator is available
echo -e "${YELLOW}📱 Checking simulator availability...${NC}"
SIMULATOR_EXISTS=$(xcrun simctl list devices available | grep -c "$SIMULATOR_NAME" || true)

if [ "$SIMULATOR_EXISTS" -eq 0 ]; then
    echo -e "${RED}❌ Simulator '$SIMULATOR_NAME' not found${NC}"
    echo "Available simulators:"
    xcrun simctl list devices available | grep -A 5 "iOS"
    exit 1
fi

# Boot simulator
echo -e "${YELLOW}🚀 Booting $SIMULATOR_NAME simulator...${NC}"
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
sleep 2

# Open Simulator app
echo -e "${YELLOW}📱 Opening Simulator...${NC}"
open -a Simulator

# Build the app
echo -e "${YELLOW}🔨 Building app...${NC}"
cd "$PROJECT_DIR/SRRadio"

xcodebuild \
    -project "SRRadio.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS" \
    -configuration Debug \
    -quiet \
    build 2>&1 | tail -5

echo ""

# Run the screenshot generation tests
echo -e "${YELLOW}📸 Running screenshot generation tests...${NC}"
echo ""

xcodebuild \
    -project "SRRadio.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$SIMULATOR_NAME,OS=$SIMULATOR_OS" \
    test \
    -only-testing:SRRadioTests/ScreenshotGenerationTests/testGenerateAppStoreScreenshots \
    2>&1 | grep -E "(✅|❌|📸|Screenshots)" || true

echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Screenshot generation complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""

# Check for generated screenshots in simulator
echo -e "${YELLOW}📂 Checking for generated screenshots...${NC}"

# Try to extract screenshots from simulator
SIMULATOR_RUNTIME=$(xcrun simctl list devices -j | python3 -c "
import sys, json
devices = json.load(sys.stdin)['devices']
for runtime, device_list in devices.items():
    for device in device_list:
        if '$SIMULATOR_NAME' in device['name']:
            print(device['udid'])
            sys.exit(0)
" 2>/dev/null || echo "")

if [ -n "$SIMULATOR_RUNTIME" ]; then
    SIMULATOR_DATA_PATH="$HOME/Library/Developer/CoreSimulator/Devices/$SIMULATOR_RUNTIME/data"
    
    # Look for screenshots in documents directory
    APP_DATA_PATH=$(find "$SIMULATOR_DATA_PATH" -name "AppStoreScreenshots" -type d 2>/dev/null | head -1)
    
    if [ -n "$APP_DATA_PATH" ]; then
        echo -e "${GREEN}✅ Found screenshots in simulator${NC}"
        echo "   Copying to: $OUTPUT_DIR"
        cp "$APP_DATA_PATH"/*.png "$OUTPUT_DIR/" 2>/dev/null || true
    fi
fi

# List generated screenshots
echo ""
echo -e "${BLUE}📋 Generated Screenshots:${NC}"
if [ -d "$OUTPUT_DIR" ] && [ "$(ls -A $OUTPUT_DIR 2>/dev/null)" ]; then
    for file in "$OUTPUT_DIR"/*.png; do
        if [ -f "$file" ]; then
            SIZE=$(sips -g pixelWidth -g pixelHeight "$file" 2>/dev/null | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w" × "h}')
            BASENAME=$(basename "$file")
            echo -e "   ${GREEN}✓${NC} $BASENAME ($SIZE)"
        fi
    done
else
    echo -e "   ${YELLOW}⚠️  No screenshots found in output directory${NC}"
fi

echo ""
echo -e "${BLUE}📁 Output directory: $OUTPUT_DIR${NC}"
echo ""

# Instructions for manual capture
echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
echo -e "${YELLOW}ℹ️  Alternative: Manual Screenshot Capture${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════${NC}"
echo ""
echo "1. Run the app in the simulator:"
echo "   $ cd $PROJECT_DIR/SRRadio"
echo "   $ xcodebuild -scheme $SCHEME -destination 'platform=iOS Simulator,name=$SIMULATOR_NAME' run"
echo ""
echo "2. Navigate to each screen in the app:"
echo "   - Main Screen (default)"
echo "   - About Screen (tap info button)"
echo "   - Settings Screen (tap gear button)"
echo ""
echo "3. Capture screenshots:"
echo "   - Press Cmd+S in Simulator"
echo "   - Or use: File → Save Screen"
echo ""
echo "4. Screenshots are saved to your Desktop"
echo ""

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}🎯 Target Resolution: 1242 × 2688 pixels${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
