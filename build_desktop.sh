#!/bin/bash

echo "Building Calendar & Reminders for Desktop..."

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Generate Hive adapters
echo "Generating Hive adapters..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Build for macOS
echo "Building for macOS..."
flutter build macos --release

# Build for Windows (if on Windows or using cross-compilation)
echo "Building for Windows..."
flutter build windows --release

# Build for Linux (if on Linux or using cross-compilation)
echo "Building for Linux..."
flutter build linux --release

echo "Desktop builds complete!"
echo ""
echo "Build outputs:"
echo "- macOS: build/macos/Build/Products/Release/calendar_reminder_app.app"
echo "- Windows: build/windows/runner/Release/"
echo "- Linux: build/linux/x64/release/bundle/" 