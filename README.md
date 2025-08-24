# 📅 Calendar & Reminder App

A beautiful, feature-rich calendar and reminder application built with Flutter. This app helps you manage tasks, notes, and events with a modern, vibrant interface.

## ✨ Features

### 📱 Core Features
- **Calendar View** - Interactive calendar with month/week/day views
- **Task Management** - Create, edit, and track tasks with priorities
- **Sticky Notes** - Colorful note-taking with pin/unpin functionality
- **Smart Analytics** - Productivity insights and progress tracking
- **Notifications** - Reminder system for tasks and events

### 🎨 Advanced Features
- **Vibrant Analytics Dashboard** - Beautiful data visualization with gradients
- **Pomodoro Timer** - Focus sessions for productivity
- **Theme Customization** - Multiple color schemes and themes
- **Advanced Search** - Smart search across tasks and notes
- **Responsive Design** - Works perfectly on all screen sizes
- **Sidebar Navigation** - Professional overlay navigation system

### 🔧 Technical Features
- **Local Storage** - Hive database for offline functionality
- **Cross-Platform** - Works on iOS, Android, Web, macOS, and Windows
- **Modern UI** - Material Design 3 with custom styling
- **State Management** - Provider pattern for clean architecture
- **Responsive Layout** - Adaptive design for all devices

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/calendar-reminder-app.git
   cd calendar-reminder-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   ./build_runner.sh
   ```

4. **Run the app**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

## 📱 Screenshots

### Dashboard
- Modern overview with progress tracking
- Quick actions for adding tasks and notes
- Recent activities and statistics

### Calendar
- Interactive calendar with event markers
- Task management with priorities
- Responsive event cards

### Analytics
- Vibrant productivity insights
- Beautiful gradient charts
- Achievement badges and progress tracking

### Sticky Notes
- Colorful note cards
- Pin/unpin functionality
- Tag-based organization

## 🏗️ Project Structure

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
│   ├── main_screen.dart      # Navigation and sidebar
│   ├── simple_dashboard.dart # Main dashboard
│   ├── calendar_view.dart    # Calendar interface
│   ├── analytics_screen.dart # Analytics and insights
│   ├── sticky_notes_screen.dart
│   ├── pomodoro_screen.dart
│   ├── theme_screen.dart
│   ├── search_screen.dart
│   └── notifications_board.dart
├── services/                 # Business logic
│   ├── local_storage_service.dart
│   └── notification_service.dart
└── widgets/                  # Reusable components
    ├── task_card.dart
    └── add_task_fab.dart
```

## 🎨 Design Features

### Color Palette
- **Primary**: `#667EEA` (Blue)
- **Secondary**: `#764BA2` (Purple)
- **Accent**: `#F093FB` (Pink)
- **Success**: `#00E676` (Green)
- **Warning**: `#FF6B35` (Orange)

### UI Components
- **Gradient Backgrounds** - Beautiful color transitions
- **Shadow Effects** - Depth and visual hierarchy
- **Responsive Grids** - Adaptive layouts
- **Smooth Animations** - Enhanced user experience

## 🔧 Configuration

### Dependencies
The app uses the following key dependencies:
- `flutter_local_notifications` - For notifications
- `table_calendar` - Calendar widget
- `hive` - Local database
- `provider` - State management
- `intl` - Internationalization

### Build Configuration
- **Android**: Configured for API 21+
- **iOS**: Supports iOS 11.0+
- **Web**: Optimized for modern browsers
- **Desktop**: macOS and Windows support

## 📊 Features in Detail

### Task Management
- Create tasks with titles, descriptions, and due dates
- Set priority levels (Low, Medium, High)
- Mark tasks as completed
- Add alarms and reminders
- Categorize tasks with tags

### Note Taking
- Create colorful sticky notes
- Pin important notes
- Add tags for organization
- Rich text formatting
- Search and filter notes

### Analytics Dashboard
- Productivity trends
- Completion rates
- Time analysis
- Achievement badges
- Performance metrics

### Calendar Integration
- Multiple view modes (Month, Week, Day)
- Event markers for tasks
- Drag and drop functionality
- Quick event creation

## 🚀 Deployment

### Web Deployment
```bash
flutter build web
# Deploy the build/web directory to your hosting service
```

### Android APK
```bash
flutter build apk --release
```

### iOS App Store
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hive team for the local database solution
- All contributors and testers

## 📞 Support

If you have any questions or need help, please open an issue on GitHub or contact the development team.

---

**Made with ❤️ using Flutter** 