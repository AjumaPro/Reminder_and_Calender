import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Temporarily disabled
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin(); // Temporarily disabled
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Request permissions
      await _requestPermissions();

      // Initialize notification settings
      await _initializeNotifications();

      _isInitialized = true;
      debugPrint('Notification service initialized successfully (stub mode)');
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        debugPrint('Notification permission denied');
      }
    }
  }

  Future<void> _initializeNotifications() async {
    // Temporarily disabled - stub implementation
    debugPrint('Notification initialization skipped (stub mode)');
  }

  void _onNotificationTapped(dynamic response) {
    debugPrint('Notification tapped (stub mode): $response');
    // Handle notification tap - navigate to appropriate screen
  }

  // Schedule a timer alarm notification
  Future<void> scheduleTimerAlarm({
    required int id,
    required String title,
    required String body,
    required Duration delay,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
      debugPrint('Timer alarm scheduled (stub mode): $title at $scheduledTime');
      // Temporarily disabled - stub implementation
    } catch (e) {
      debugPrint('Failed to schedule timer alarm: $e');
    }
  }

  // Schedule a task reminder notification
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      debugPrint(
          'Task reminder scheduled (stub mode): $title at $scheduledTime');
      // Temporarily disabled - stub implementation
    } catch (e) {
      debugPrint('Failed to schedule task reminder: $e');
    }
  }

  // Schedule a note reminder notification
  Future<void> scheduleNoteReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      debugPrint(
          'Note reminder scheduled (stub mode): $title at $scheduledTime');
      // Temporarily disabled - stub implementation
    } catch (e) {
      debugPrint('Failed to schedule note reminder: $e');
    }
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    try {
      debugPrint('Notification cancelled (stub mode): $id');
      // Temporarily disabled - stub implementation
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    try {
      debugPrint('All notifications cancelled (stub mode)');
      // Temporarily disabled - stub implementation
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }

  // Get pending notifications
  Future<List<dynamic>> getPendingNotifications() async {
    try {
      debugPrint('Getting pending notifications (stub mode)');
      // Temporarily disabled - stub implementation
      return [];
    } catch (e) {
      debugPrint('Failed to get pending notifications: $e');
      return [];
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    Uint8List? imageBytes,
  }) async {
    try {
      debugPrint('Showing notification (stub mode): $title');
      // Temporarily disabled - stub implementation
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  // Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
      return true; // Assume granted for other platforms
    } catch (e) {
      debugPrint('Failed to check notification permission: $e');
      return false;
    }
  }

  // Request notification permission
  Future<bool> requestNotificationPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true; // Assume granted for other platforms
    } catch (e) {
      debugPrint('Failed to request notification permission: $e');
      return false;
    }
  }

  // Check if notifications are enabled (stub implementation)
  Future<bool> areNotificationsEnabled() async {
    try {
      return await hasNotificationPermission();
    } catch (e) {
      debugPrint('Failed to check notification status: $e');
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    debugPrint('Notification service disposed (stub mode)');
  }
}
