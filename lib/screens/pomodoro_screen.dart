import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/alarm_service.dart';
import '../services/notification_service.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;

  Timer? _timer;
  int _timeLeft = 25 * 60; // 25 minutes in seconds
  int _totalTime = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedSessions = 0;
  int _completedBreaks = 0;
  bool _isAlarmPlaying = false;

  // Pomodoro settings
  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _sessionsBeforeLongBreak = 4;

  // Services
  final AlarmService _alarmService = AlarmService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupAnimations();
  }

  Future<void> _initializeServices() async {
    await _alarmService.initialize();
    await _notificationService.initialize();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    _alarmService.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _handleSessionComplete();
        }
      });
    });

    _pulseController.repeat(reverse: true);
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    _pulseController.stop();
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _timeLeft = _totalTime;
    });
    _pulseController.stop();
  }

  void _handleSessionComplete() async {
    if (_isBreak) {
      _completedBreaks++;
      _startWorkSession();
    } else {
      _completedSessions++;
      _startBreakSession();
    }

    // Play alarm and show notification
    await _playAlarm();
    await _showNotification();

    // Vibrate and show dialog
    HapticFeedback.mediumImpact();
    _showSessionCompleteDialog();
  }

  Future<void> _playAlarm() async {
    try {
      setState(() {
        _isAlarmPlaying = true;
      });

      await _alarmService.playAlarm();

      // Stop alarm after 10 seconds if not manually stopped
      Timer(const Duration(seconds: 10), () {
        _stopAlarm();
      });
    } catch (e) {
      debugPrint('Failed to play alarm: $e');
      setState(() {
        _isAlarmPlaying = false;
      });
    }
  }

  Future<void> _stopAlarm() async {
    try {
      await _alarmService.stopAlarm();
      setState(() {
        _isAlarmPlaying = false;
      });
    } catch (e) {
      debugPrint('Failed to stop alarm: $e');
    }
  }

  Future<void> _showNotification() async {
    try {
      final title = _isBreak ? 'Break Complete!' : 'Work Session Complete!';
      final body = _isBreak
          ? 'Great job! Time to get back to work.'
          : 'Excellent work! Time for a well-deserved break.';

      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        body: body,
        payload: _isBreak ? 'break_complete' : 'work_complete',
      );
    } catch (e) {
      debugPrint('Failed to show notification: $e');
    }
  }

  void _startWorkSession() {
    setState(() {
      _isBreak = false;
      _timeLeft = _workDuration * 60;
      _totalTime = _workDuration * 60;
    });
  }

  void _startBreakSession() {
    setState(() {
      _isBreak = true;
      final isLongBreak = _completedSessions % _sessionsBeforeLongBreak == 0;
      _timeLeft =
          isLongBreak ? _longBreakDuration * 60 : _shortBreakDuration * 60;
      _totalTime = _timeLeft;
    });
  }

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing while alarm is playing
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _isBreak ? Icons.coffee : Icons.work,
              color: _isBreak ? Colors.orange : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(_isBreak ? 'Break Complete!' : 'Work Session Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isBreak
                  ? 'Great job! Time to get back to work.'
                  : 'Excellent work! Time for a well-deserved break.',
            ),
            if (_isAlarmPlaying) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_up, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Alarm is playing...'),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (_isAlarmPlaying)
            TextButton(
              onPressed: _stopAlarm,
              child: const Text('Stop Alarm'),
            ),
          TextButton(
            onPressed: () {
              _stopAlarm();
              Navigator.pop(context);
              if (_isBreak) {
                _startWorkSession();
              } else {
                _startBreakSession();
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    return (_totalTime - _timeLeft) / _totalTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isBreak ? const Color(0xFFE8F5E8) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Pomodoro Timer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor:
            _isBreak ? const Color(0xFF4CAF50) : const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTimerCard(),
            const SizedBox(height: 30),
            _buildControls(),
            const SizedBox(height: 30),
            _buildStats(),
            const SizedBox(height: 30),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (_isBreak ? const Color(0xFF4CAF50) : const Color(0xFF667EEA))
                    .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRunning ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isBreak
                          ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                          : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: _getProgress(),
                            strokeWidth: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_timeLeft),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isBreak ? 'Break Time' : 'Focus Time',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  (_isBreak ? const Color(0xFF4CAF50) : const Color(0xFF667EEA))
                      .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isBreak
                  ? 'Take a break and relax'
                  : 'Stay focused and productive',
              style: TextStyle(
                fontSize: 14,
                color: _isBreak
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF667EEA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.refresh,
          label: 'Reset',
          onPressed: _resetTimer,
          color: Colors.grey,
        ),
        _buildControlButton(
          icon: _isRunning ? Icons.pause : Icons.play_arrow,
          label: _isRunning ? 'Pause' : 'Start',
          onPressed: _isRunning ? _pauseTimer : _startTimer,
          color: _isBreak ? const Color(0xFF4CAF50) : const Color(0xFF667EEA),
          isPrimary: true,
        ),
        _buildControlButton(
          icon: Icons.skip_next,
          label: 'Skip',
          onPressed: _handleSessionComplete,
          color: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isPrimary ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            color: isPrimary ? Colors.white : color,
            iconSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Sessions',
                  _completedSessions.toString(),
                  Icons.work,
                  const Color(0xFF667EEA),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Breaks',
                  _completedBreaks.toString(),
                  Icons.coffee,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Focus Time',
                  '${(_completedSessions * _workDuration)}m',
                  Icons.timer,
                  const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  '25min Work',
                  Icons.work,
                  const Color(0xFF667EEA),
                  () => _setCustomDuration(25, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  '5min Break',
                  Icons.coffee,
                  const Color(0xFF4CAF50),
                  () => _setCustomDuration(5, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  '15min Break',
                  Icons.local_cafe,
                  const Color(0xFFFF9800),
                  () => _setCustomDuration(15, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _setCustomDuration(int minutes, bool isBreak) {
    setState(() {
      _isBreak = isBreak;
      _timeLeft = minutes * 60;
      _totalTime = minutes * 60;
      _isRunning = false;
    });
    _timer?.cancel();
    _pulseController.stop();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pomodoro Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingItem(
              'Work Duration',
              _workDuration,
              (value) => setState(() => _workDuration = value),
            ),
            _buildSettingItem(
              'Short Break',
              _shortBreakDuration,
              (value) => setState(() => _shortBreakDuration = value),
            ),
            _buildSettingItem(
              'Long Break',
              _longBreakDuration,
              (value) => setState(() => _longBreakDuration = value),
            ),
            _buildSettingItem(
              'Sessions before Long Break',
              _sessionsBeforeLongBreak,
              (value) => setState(() => _sessionsBeforeLongBreak = value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (value > 1) onChanged(value - 1);
                },
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
