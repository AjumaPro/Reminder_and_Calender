# Calendar & Reminders App

A comprehensive calendar and reminder application built with Flutter, featuring desktop support, Pomodoro timer, notes management, and advanced settings.

## Developer
**Francis Sarpaning**

## Features

### 📅 Calendar Management
- Interactive calendar view
- Task scheduling and management
- Event reminders and notifications
- Multiple view modes (month, week, day)

### ⏰ Pomodoro Timer
- Customizable work/break intervals
- Session tracking and statistics
- Alarm notifications with vibration
- Auto-start next session option

### 📝 Notes & Tasks
- Rich text note editor
- Task creation and management
- Priority levels and due dates
- Search and filter functionality

### 🔔 Advanced Notifications
- Local notification system
- Customizable alarm sounds
- Vibration patterns
- Notification scheduling

### 🖥️ Desktop Support
- Cross-platform desktop application
- Window management controls
- Native desktop integration
- Responsive design

### ⚙️ Advanced Settings
- Theme customization (6 themes)
- Multi-language support (5 languages)
- Data backup and restore
- Performance monitoring
- Privacy and security settings

## Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: Hive
- **Notifications**: flutter_local_notifications
- **Desktop Support**: window_size, desktop_window

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd calendar-reminder-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For mobile
   flutter run
   
   # For desktop
   flutter run -d macos
   flutter run -d windows
   flutter run -d linux
   ```

### Building for Desktop

Use the provided build script:
```bash
./build_desktop.sh
```

This will build the app for macOS, Windows, and Linux platforms.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── task.dart
│   └── note.dart
├── providers/                # State management
│   ├── task_provider.dart
│   └── note_provider.dart
├── screens/                  # UI screens
│   ├── main_screen.dart
│   ├── calendar_screen.dart
│   ├── pomodoro_screen.dart
│   ├── notes_screen.dart
│   ├── settings_screen.dart
│   └── ...
├── services/                 # Business logic
│   ├── alarm_service.dart
│   ├── notification_service.dart
│   ├── desktop_service.dart
│   └── local_storage_service.dart
└── widgets/                  # Reusable components
    ├── task_card.dart
    ├── desktop_window_controls.dart
    └── ...
```

## Features in Detail

### Desktop Integration
- **Window Controls**: Minimize, maximize, close buttons
- **Responsive Design**: Adapts to different screen sizes
- **Native Feel**: Platform-specific behaviors
- **Keyboard Shortcuts**: Desktop-optimized interactions

### Advanced Settings
- **Theme System**: 6 different color themes
- **Language Support**: English, Spanish, French, German, Chinese
- **Data Management**: Export, import, backup, restore
- **Performance**: Auto-save, debug mode, analytics
- **Privacy**: Security settings and data control

### Notification System
- **Local Notifications**: Platform-agnostic notifications
- **Custom Alarms**: Vibration and sound patterns
- **Scheduling**: Timezone-aware scheduling
- **Permissions**: Graceful permission handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact Francis Sarpaning.

---

**Developed with ❤️ by Francis Sarpaning** 