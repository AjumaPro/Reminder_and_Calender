#!/bin/bash

echo "=== Desktop Setup Test ==="
echo ""

echo "1. Checking Flutter configuration..."
flutter config --list | grep desktop

echo ""
echo "2. Checking available devices..."
flutter devices

echo ""
echo "3. Checking Xcode status..."
if command -v xcodebuild &> /dev/null; then
    echo "✅ xcodebuild found"
    xcodebuild -version
else
    echo "❌ xcodebuild not found"
    echo ""
    echo "=== XCODE INSTALLATION REQUIRED ==="
    echo "To build for macOS desktop, you need to install Xcode:"
    echo ""
    echo "Option 1: Install from App Store (Recommended)"
    echo "  - Open App Store"
    echo "  - Search for 'Xcode'"
    echo "  - Install (free, ~12GB download)"
    echo ""
    echo "Option 2: Install from developer.apple.com"
    echo "  - Visit https://developer.apple.com/xcode/"
    echo "  - Download and install"
    echo ""
    echo "After installation, run:"
    echo "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo "  sudo xcodebuild -runFirstLaunch"
    echo ""
fi

echo ""
echo "4. Testing web platform (works without Xcode)..."
echo "Run: flutter run -d chrome"

echo ""
echo "5. Testing Windows/Linux (if available)..."
echo "Run: flutter run -d windows"
echo "Run: flutter run -d linux"

echo ""
echo "=== NEXT STEPS ==="
echo "1. Install Xcode for macOS development"
echo "2. Test web version: flutter run -d chrome"
echo "3. Build for other platforms: ./build_desktop.sh" 