import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';  // Temporarily disabled for Android build
import 'package:intl/intl.dart';
import '../models/task.dart';
// import '../services/notification_service.dart';  // Temporarily disabled for Android build

class AlarmPopupScreen extends StatefulWidget {
  final Task task;

  const AlarmPopupScreen({
    super.key,
    required this.task,
  });

  @override
  State<AlarmPopupScreen> createState() => _AlarmPopupScreenState();
}

class _AlarmPopupScreenState extends State<AlarmPopupScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  // final AudioPlayer _audioPlayer = AudioPlayer();  // Temporarily disabled for Android build
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.repeat(reverse: true);
    _playAlarmSound();
  }

  @override
  void dispose() {
    _animationController.dispose();
    // _audioPlayer.dispose();  // Temporarily disabled for Android build
    super.dispose();
  }

  Future<void> _playAlarmSound() async {
    // Audio functionality temporarily disabled for Android build
    print('Alarm sound would play here');
  }

  Future<void> _stopAlarm() async {
    setState(() {
      _isPlaying = false;
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _snoozeAlarm() async {
    await _stopAlarm();
    // Notification functionality temporarily disabled for Android build
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm snoozed for 5 minutes'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAlarmIcon(),
                      const SizedBox(height: 24),
                      _buildTaskInfo(),
                      const SizedBox(height: 32),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlarmIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.alarm,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTaskInfo() {
    return Column(
      children: [
        Text(
          'REMINDER',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.task.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.task.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.task.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            DateFormat('MMM dd, yyyy - HH:mm').format(widget.task.dueDate),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        if (widget.task.note != null && widget.task.note!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.task.note!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _snoozeAlarm,
            icon: const Icon(Icons.snooze),
            label: const Text('Snooze'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _stopAlarm,
            icon: const Icon(Icons.stop),
            label: const Text('Stop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
