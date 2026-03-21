#!/bin/bash
# Test CI workflows locally with act

set -e

echo "=== Testing CI Workflows Locally ==="
echo ""

# Check if act is installed
if ! command -v act &> /dev/null; then
    echo "❌ act is not installed. Install with:"
    echo "   brew install act    # macOS"
    echo "   or visit: https://github.com/nektos/act"
    exit 1
fi

echo "✓ act is installed ($(act --version))"
echo ""

# Dry run all workflows
echo "=== Dry Run (Syntax Check) ==="
act -n --container-architecture linux/amd64
echo ""

# Test specific jobs
echo "=== Available Test Commands ==="
echo ""
echo "Run test job (fast):"
echo "  act -j test --container-architecture linux/amd64"
echo ""
echo "Run visual tests:"
echo "  act -j visual-tests --container-architecture linux/amd64"
echo ""
echo "Run Linux build:"
echo "  act -j build-linux --container-architecture linux/amd64"
echo ""
echo "Run Android build:"
echo "  act -j build-android --container-architecture linux/amd64"
echo ""
echo "Note: macOS and Windows jobs cannot run locally (require specific runners)"
