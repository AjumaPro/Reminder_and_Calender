import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../models/task.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Analytics & Insights',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAnalytics(),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportData(),
          ),
        ],
      ),
      body: Consumer2<TaskProvider, NoteProvider>(
        builder: (context, taskProvider, noteProvider, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(taskProvider, noteProvider),
                    const SizedBox(height: 20),
                    _buildProductivityChart(taskProvider),
                    const SizedBox(height: 20),
                    _buildGoalTracking(taskProvider),
                    const SizedBox(height: 20),
                    _buildAchievementBadges(taskProvider, noteProvider),
                    const SizedBox(height: 20),
                    _buildTimeAnalysis(taskProvider),
                    const SizedBox(height: 20),
                    _buildTrendsAnalysis(taskProvider),
                    const SizedBox(height: 20),
                    _buildPerformanceMetrics(taskProvider, noteProvider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(
      TaskProvider taskProvider, NoteProvider noteProvider) {
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;
    final totalNotes = noteProvider.notes.length;
    final pinnedNotes = noteProvider.pinnedNotes.length;
    final completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
            Color(0xFFF093FB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFFF093FB).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Productivity Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  'Completion Rate',
                  '$completionRate%',
                  Icons.check_circle,
                  const Color(0xFF00E676),
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  'Total Tasks',
                  totalTasks.toString(),
                  Icons.task_alt,
                  const Color(0xFFFF6B35),
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  'Notes Created',
                  totalNotes.toString(),
                  Icons.note,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: [
              Shadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProductivityChart(TaskProvider taskProvider) {
    final weeklyData = _getWeeklyProductivityData(taskProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8F9FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Productivity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final maxValue = weeklyData
                    .map((d) => d['completed'])
                    .reduce((a, b) => a > b ? a : b);
                final height =
                    maxValue > 0 ? (data['completed'] / maxValue) : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 30,
                      height: (120 * height).toDouble(),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667EEA),
                            const Color(0xFF764BA2),
                            const Color(0xFFF093FB),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['day'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${data['completed']}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getWeeklyProductivityData(
      TaskProvider taskProvider) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final data = <Map<String, dynamic>>[];

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: now.weekday - 1 + i));
      final dayTasks = taskProvider.tasks.where((task) {
        final taskDate =
            DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
        final compareDate = DateTime(date.year, date.month, date.day);
        return taskDate == compareDate && task.isCompleted;
      }).length;

      data.add({
        'day': weekDays[i],
        'completed': dayTasks,
      });
    }

    return data;
  }

  Widget _buildGoalTracking(TaskProvider taskProvider) {
    final todayTasks = taskProvider.tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      return taskDate == todayDate;
    }).length;

    final todayCompleted = taskProvider.tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      return taskDate == todayDate && task.isCompleted;
    }).length;

    final dailyGoal = 5; // Default daily goal
    final progress = todayTasks > 0 ? todayCompleted / todayTasks : 0.0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Goal Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Goal: $dailyGoal',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            minHeight: 10,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$todayCompleted of $todayTasks completed',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadges(
      TaskProvider taskProvider, NoteProvider noteProvider) {
    final badges = _getAchievementBadges(taskProvider, noteProvider);

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
            'Achievement Badges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return _buildBadgeCard(badge);
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievementBadges(
      TaskProvider taskProvider, NoteProvider noteProvider) {
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;
    final totalNotes = noteProvider.notes.length;
    final pinnedNotes = noteProvider.pinnedNotes.length;

    return [
      {
        'title': 'Task Master',
        'icon': Icons.task_alt,
        'color': const Color(0xFF4CAF50),
        'unlocked': completedTasks >= 10,
        'progress': completedTasks,
        'target': 10,
      },
      {
        'title': 'Note Taker',
        'icon': Icons.note,
        'color': const Color(0xFF9C27B0),
        'unlocked': totalNotes >= 5,
        'progress': totalNotes,
        'target': 5,
      },
      {
        'title': 'Organizer',
        'icon': Icons.push_pin,
        'color': const Color(0xFFF44336),
        'unlocked': pinnedNotes >= 3,
        'progress': pinnedNotes,
        'target': 3,
      },
      {
        'title': 'Consistent',
        'icon': Icons.trending_up,
        'color': const Color(0xFF2196F3),
        'unlocked': completedTasks >= 20,
        'progress': completedTasks,
        'target': 20,
      },
      {
        'title': 'Productive',
        'icon': Icons.rocket_launch,
        'color': const Color(0xFFFF9800),
        'unlocked': totalTasks >= 15,
        'progress': totalTasks,
        'target': 15,
      },
      {
        'title': 'Planner',
        'icon': Icons.calendar_today,
        'color': const Color(0xFF607D8B),
        'unlocked': totalTasks >= 25,
        'progress': totalTasks,
        'target': 25,
      },
    ];
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final unlocked = badge['unlocked'] as bool;
    final progress = badge['progress'] as int;
    final target = badge['target'] as int;
    final progressPercent = (progress / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: unlocked
              ? [
                  badge['color'].withOpacity(0.2),
                  badge['color'].withOpacity(0.05),
                ]
              : [
                  Colors.grey[100]!,
                  Colors.grey[50]!,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? badge['color'].withOpacity(0.4) : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: unlocked
                ? badge['color'].withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: unlocked
                    ? [
                        badge['color'],
                        badge['color'].withOpacity(0.8),
                      ]
                    : [
                        Colors.grey[400]!,
                        Colors.grey[500]!,
                      ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: unlocked
                      ? badge['color'].withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              badge['icon'],
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              badge['title'],
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: unlocked ? badge['color'] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$progress/$target',
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(1.5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      badge['color'],
                      badge['color'].withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysis(TaskProvider taskProvider) {
    final timeData = _getTimeAnalysisData(taskProvider);

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
            'Time Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...timeData.map((data) => _buildTimeStat(data)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTimeAnalysisData(TaskProvider taskProvider) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final todayTasks = taskProvider.tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate == today;
    }).length;

    final weekTasks = taskProvider.tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).length;

    final monthTasks = taskProvider.tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAfter(monthStart.subtract(const Duration(days: 1)));
    }).length;

    return [
      {
        'title': 'Today',
        'value': todayTasks,
        'icon': Icons.today,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'This Week',
        'value': weekTasks,
        'icon': Icons.view_week,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'This Month',
        'value': monthTasks,
        'icon': Icons.calendar_month,
        'color': const Color(0xFF9C27B0),
      },
    ];
  }

  Widget _buildTimeStat(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: data['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data['color'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              data['icon'],
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${data['value']} tasks',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${data['value']}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: data['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsAnalysis(TaskProvider taskProvider) {
    final trends = _getTrendsData(taskProvider);

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
            'Productivity Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...trends.map((trend) => _buildTrendItem(trend)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTrendsData(TaskProvider taskProvider) {
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;
    final pendingTasks = taskProvider.pendingTasks.length;

    return [
      {
        'title': 'Task Completion',
        'value': completedTasks,
        'total': totalTasks,
        'percentage':
            totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
        'trend': completedTasks > 0 ? 'up' : 'stable',
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Pending Tasks',
        'value': pendingTasks,
        'total': totalTasks,
        'percentage':
            totalTasks > 0 ? (pendingTasks / totalTasks * 100).round() : 0,
        'trend': pendingTasks < totalTasks * 0.5 ? 'down' : 'up',
        'color': const Color(0xFFFF9800),
      },
    ];
  }

  Widget _buildTrendItem(Map<String, dynamic> trend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trend['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trend['value']} of ${trend['total']} (${trend['percentage']}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                trend['trend'] == 'up'
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: trend['trend'] == 'up' ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trend['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${trend['percentage']}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trend['color'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(
      TaskProvider taskProvider, NoteProvider noteProvider) {
    final metrics = _getPerformanceMetrics(taskProvider, noteProvider);

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
            'Performance Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return _buildMetricCard(metric);
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPerformanceMetrics(
      TaskProvider taskProvider, NoteProvider noteProvider) {
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;
    final totalNotes = noteProvider.notes.length;
    final pinnedNotes = noteProvider.pinnedNotes.length;

    return [
      {
        'title': 'Efficiency Score',
        'value':
            totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
        'unit': '%',
        'icon': Icons.speed,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': 'Organization Level',
        'value': totalNotes > 0 ? (pinnedNotes / totalNotes * 100).round() : 0,
        'unit': '%',
        'icon': Icons.folder,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': 'Task Velocity',
        'value': completedTasks,
        'unit': 'tasks',
        'icon': Icons.rocket_launch,
        'color': const Color(0xFFFF9800),
      },
      {
        'title': 'Knowledge Base',
        'value': totalNotes,
        'unit': 'notes',
        'icon': Icons.lightbulb,
        'color': const Color(0xFF9C27B0),
      },
    ];
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            metric['color'].withOpacity(0.15),
            metric['color'].withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: metric['color'].withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: metric['color'].withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  metric['color'].withOpacity(0.2),
                  metric['color'].withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              metric['icon'],
              color: metric['color'],
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              '${metric['value']}${metric['unit']}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: metric['color'],
                shadows: [
                  Shadow(
                    color: metric['color'].withOpacity(0.3),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          Flexible(
            child: Text(
              metric['title'],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: metric['color'].withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _shareAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing analytics coming soon!'),
        backgroundColor: Color(0xFF667EEA),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting data coming soon!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}
