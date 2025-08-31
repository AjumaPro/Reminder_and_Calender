import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/note_provider.dart';
import 'services/local_storage_service.dart';
import 'services/desktop_service.dart';
import 'services/notification_service.dart';
import 'screens/main_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/notifications_board.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/theme_screen.dart';
import 'screens/test_navigation.dart';
import 'widgets/alarm_test_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services with error handling
  try {
    await LocalStorageService().initialize();
    await DesktopService().initialize();
    await NotificationService().initialize();
  } catch (e) {
    print('Service initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp(
        title: 'Calendar & Reminders by Francis Sarpaning',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const MainScreen(),
        routes: {
          '/pomodoro': (context) => const PomodoroScreen(),
          '/analytics': (context) => const AnalyticsScreen(),
          '/notes': (context) => const NotesScreen(),
          '/notifications': (context) => const NotificationsBoard(),
          '/search': (context) => const SearchScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/theme': (context) => const ThemeScreen(),
          '/alarm-test': (context) => const AlarmTestWidget(),
          '/test': (context) => const TestNavigation(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
