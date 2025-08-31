import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/alarm_service.dart';

class AlarmTestWidget extends StatefulWidget {
  const AlarmTestWidget({super.key});

  @override
  State<AlarmTestWidget> createState() => _AlarmTestWidgetState();
}

class _AlarmTestWidgetState extends State<AlarmTestWidget> {
  final AlarmService _alarmService = AlarmService();
  bool _isAlarmPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAlarm();
  }

  Future<void> _initializeAlarm() async {
    await _alarmService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _testAlarm() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarm service not initialized yet')),
      );
      return;
    }

    setState(() {
      _isAlarmPlaying = true;
    });

    try {
      await _alarmService.playAlarm();

      // Auto-stop after 5 seconds for testing
      Future.delayed(const Duration(seconds: 5), () {
        _stopAlarm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vibration alarm playing! Will stop in 5 seconds.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isAlarmPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to play alarm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopAlarm() async {
    try {
      await _alarmService.stopAlarm();
      setState(() {
        _isAlarmPlaying = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm stopped'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to stop alarm: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testVibration() async {
    try {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Single vibration test completed'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vibration not supported: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      _isAlarmPlaying ? Icons.vibration : Icons.alarm,
                      size: 48,
                      color: _isAlarmPlaying ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vibration Alarm Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isInitialized
                          ? 'Alarm service is ready'
                          : 'Initializing alarm service...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_isAlarmPlaying) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Vibration pattern active',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isAlarmPlaying ? null : _testAlarm,
              icon: Icon(_isAlarmPlaying ? Icons.vibration : Icons.vibration),
              label: Text(_isAlarmPlaying
                  ? 'Alarm Playing...'
                  : 'Test Vibration Alarm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAlarmPlaying ? Colors.grey : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isAlarmPlaying ? _stopAlarm : null,
              icon: const Icon(Icons.stop),
              label: const Text('Stop Alarm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAlarmPlaying ? Colors.red : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testVibration,
              icon: const Icon(Icons.touch_app),
              label: const Text('Test Single Vibration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                        '1. Click "Test Vibration Alarm" to start vibration pattern'),
                    const Text('2. Click "Stop Alarm" to stop the vibration'),
                    const Text(
                        '3. Click "Test Single Vibration" for one-time haptic feedback'),
                    const Text(
                        '4. Vibration alarm will auto-stop after 5 seconds'),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Vibration works best on mobile devices and some desktop platforms.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _alarmService.dispose();
    super.dispose();
  }
}
