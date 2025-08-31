import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  bool _isInitialized = false;
  Timer? _vibrationTimer;
  bool _isAlarmActive = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _isInitialized = true;
      debugPrint('Alarm service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize alarm service: $e');
    }
  }

  Future<void> playAlarm() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Use vibration and haptic feedback as primary alarm method
      await _playVibrationAlarm();
      debugPrint('Playing vibration alarm');
    } catch (e) {
      debugPrint('Vibration alarm failed: $e');
      // Fallback to just haptic feedback
      await _playHapticAlarm();
    }
  }

  Future<void> _playVibrationAlarm() async {
    if (_isAlarmActive) return;

    _isAlarmActive = true;

    // Initial strong vibration
    HapticFeedback.heavyImpact();

    // Create a vibration pattern (vibrate every 500ms)
    _vibrationTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isAlarmActive) {
        HapticFeedback.mediumImpact();
      } else {
        timer.cancel();
      }
    });

    debugPrint('Vibration alarm started');
  }

  Future<void> _playHapticAlarm() async {
    try {
      // Single strong haptic feedback
      HapticFeedback.heavyImpact();
      debugPrint('Haptic alarm played');
    } catch (e) {
      debugPrint('Haptic alarm failed: $e');
    }
  }

  Future<void> stopAlarm() async {
    _isAlarmActive = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    debugPrint('Alarm stopped');
  }

  Future<void> pauseAlarm() async {
    _isAlarmActive = false;
    _vibrationTimer?.cancel();
    debugPrint('Alarm paused');
  }

  Future<void> resumeAlarm() async {
    if (!_isAlarmActive) {
      await playAlarm();
    }
    debugPrint('Alarm resumed');
  }

  Future<void> setVolume(double volume) async {
    // Volume control not applicable for vibration-based alarm
    debugPrint('Volume control not available for vibration alarm');
  }

  Future<bool> isPlaying() async {
    return _isAlarmActive;
  }

  void dispose() {
    _isAlarmActive = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    _isInitialized = false;
    debugPrint('Alarm service disposed');
  }
}
