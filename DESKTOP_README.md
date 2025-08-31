# Desktop Installation Guide

## Calendar & Reminders App by Francis Sarpaning

This guide will help you install and run the Calendar & Reminders app on your desktop computer.

## System Requirements

### Windows
- Windows 10 or later (64-bit)
- 4GB RAM minimum, 8GB recommended
- 500MB free disk space

### macOS
- macOS 10.14 (Mojave) or later
- 4GB RAM minimum, 8GB recommended
- 500MB free disk space

### Linux
- Ubuntu 18.04+ or equivalent
- 4GB RAM minimum, 8GB recommended
- 500MB free disk space

## Installation

### Option 1: Build from Source (Recommended)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd calendar-reminder-app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Build for your platform**
   ```bash
   # For macOS
   flutter build macos --release
   
   # For Windows
   flutter build windows --release
   
   # For Linux
   flutter build linux --release
   ```

4. **Run the application**
   ```bash
   # For macOS
   open build/macos/Build/Products/Release/calendar_reminder_app.app
   
   # For Windows
   build/windows/runner/Release/calendar_reminder_app.exe
   
   # For Linux
   build/linux/x64/release/bundle/calendar_reminder_app
   ```

### Option 2: Quick Development Run

1. **Navigate to project directory**
   ```bash
   cd calendar-reminder-app
   ```

2. **Run in development mode**
   ```bash
   # For macOS
   flutter run -d macos
   
   # For Windows
   flutter run -d windows
   
   # For Linux
   flutter run -d linux
   ```

## Features

### 🖥️ Desktop-Specific Features
- **Window Management**: Minimize, maximize, close controls
- **Responsive Design**: Adapts to different screen sizes
- **Keyboard Shortcuts**: Desktop-optimized interactions
- **Native Integration**: Platform-specific behaviors

### 📅 Core Features
- **Calendar View**: Interactive calendar with event management
- **Task Management**: Create, edit, and track tasks
- **Pomodoro Timer**: Focus sessions with customizable intervals
- **Notes System**: Rich text note-taking
- **Notifications**: Local notification system
- **Advanced Settings**: Comprehensive customization options

## Troubleshooting

### Common Issues

#### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build macos --release
```

#### Permission Issues (macOS)
```bash
# Grant permissions in System Preferences > Security & Privacy
# Allow the app to run from unidentified developer
```

#### Missing Dependencies (Linux)
```bash
# Install required packages
sudo apt-get update
sudo apt-get install libgtk-3-dev libx11-dev
```

### Performance Issues
- Close other applications to free up memory
- Ensure adequate disk space
- Update graphics drivers

## Support

For technical support or questions, please contact:
**Francis Sarpaning**

## License

This project is licensed under the MIT License.

---

**Developed with ❤️ by Francis Sarpaning** 