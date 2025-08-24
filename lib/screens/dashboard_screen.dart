import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../models/task.dart';
import '../models/note.dart';
import 'calendar_screen.dart';
import 'notes_screen.dart';
import 'task_editor_screen.dart';
import 'note_editor_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Consumer2<TaskProvider, NoteProvider>(
        builder: (context, taskProvider, noteProvider, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                await taskProvider.loadTasks();
                await noteProvider.loadNotes();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 24),
                    _buildQuickStats(taskProvider, noteProvider),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildTodayTasks(taskProvider),
                    const SizedBox(height: 24),
                    _buildUpcomingTasks(taskProvider),
                    const SizedBox(height: 24),
                    _buildRecentNotes(noteProvider),
                    const SizedBox(height: 24),
                    _buildProductivityChart(taskProvider),
                    const SizedBox(height: 24),
                    _buildCategoryBreakdown(taskProvider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM dd, yyyy').format(now),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(now),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(
      TaskProvider taskProvider, NoteProvider noteProvider) {
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;
    final pendingTasks = taskProvider.pendingTasks.length;
    final totalNotes = noteProvider.notes.length;
    final pinnedNotes = noteProvider.pinnedNotes.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Tasks',
            totalTasks.toString(),
            Icons.task,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            completedTasks.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            pendingTasks.toString(),
            Icons.pending,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  child: _buildActionButton(
                    'Add Task',
                    Icons.add_task,
                    Colors.blue,
                    () => _navigateToTaskEditor(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Add Note',
                    Icons.note_add,
                    Colors.green,
                    () => _navigateToNoteEditor(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Calendar',
                    Icons.calendar_today,
                    Colors.orange,
                    () => _navigateToCalendar(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTasks(TaskProvider taskProvider) {
    final today = DateTime.now();
    final todayTasks = taskProvider.getTasksForDate(today);
    final pendingTodayTasks =
        todayTasks.where((task) => !task.isCompleted).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${pendingTodayTasks.length} pending',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (pendingTodayTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No pending tasks for today!',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...pendingTodayTasks.take(3).map((task) => _buildTaskItem(task)),
            if (pendingTodayTasks.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () => _navigateToCalendar(),
                    child: Text(
                      'View all ${pendingTodayTasks.length} tasks',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getPriorityColor(task.priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('HH:mm').format(task.dueDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (task.hasAlarm)
            Icon(
              Icons.alarm,
              size: 16,
              color: Colors.orange[600],
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTasks(TaskProvider taskProvider) {
    final now = DateTime.now();
    final upcomingTasks = taskProvider.tasks
        .where((task) =>
            !task.isCompleted &&
            task.dueDate.isAfter(now) &&
            task.dueDate.isBefore(now.add(const Duration(days: 7))))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Tasks (Next 7 Days)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (upcomingTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No upcoming tasks',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...upcomingTasks
                  .take(5)
                  .map((task) => _buildUpcomingTaskItem(task)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTaskItem(Task task) {
    final daysUntil = task.dueDate.difference(DateTime.now()).inDays;
    String timeText;
    if (daysUntil == 0) {
      timeText = 'Today';
    } else if (daysUntil == 1) {
      timeText = 'Tomorrow';
    } else {
      timeText = 'In $daysUntil days';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getPriorityColor(task.priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$timeText at ${DateFormat('HH:mm').format(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getCategoryColor(task.category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.category,
              style: TextStyle(
                fontSize: 10,
                color: _getCategoryColor(task.category),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNotes(NoteProvider noteProvider) {
    final recentNotes = noteProvider.notes
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${noteProvider.notes.length} total',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentNotes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No notes yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...recentNotes.take(3).map((note) => _buildNoteItem(note)),
            if (recentNotes.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: () => _navigateToNotes(),
                    child: Text(
                      'View all notes',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.note,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned)
                      Icon(
                        Icons.push_pin,
                        size: 16,
                        color: Colors.orange[600],
                      ),
                  ],
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(note.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityChart(TaskProvider taskProvider) {
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productivity Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: completionRate,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCompletionColor(completionRate),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(completionRate * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getCompletionColor(completionRate),
                        ),
                      ),
                      const Text(
                        'Completion Rate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductivityStat(
                          'Total Tasks', totalTasks, Icons.task),
                      const SizedBox(height: 8),
                      _buildProductivityStat(
                          'Completed', completedTasks, Icons.check_circle),
                      const SizedBox(height: 8),
                      _buildProductivityStat('Pending',
                          totalTasks - completedTasks, Icons.pending),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityStat(String label, int value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(TaskProvider taskProvider) {
    final categories = taskProvider.getCategories();
    final categoryStats = <String, int>{};

    for (final category in categories) {
      categoryStats[category] =
          taskProvider.getTasksByCategory(category).length;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tasks by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (categoryStats.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No tasks yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...categoryStats.entries
                  .map((entry) => _buildCategoryItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getCategoryColor(category),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      case 'health':
        return Colors.red;
      case 'shopping':
        return Colors.purple;
      case 'meeting':
        return Colors.orange;
      case 'study':
        return Colors.indigo;
      case 'exercise':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.orange;
    if (rate >= 0.4) return Colors.yellow[700]!;
    return Colors.red;
  }

  void _navigateToTaskEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskEditorScreen(),
      ),
    );
  }

  void _navigateToNoteEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteEditorScreen(),
      ),
    );
  }

  void _navigateToCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarScreen(),
      ),
    );
  }

  void _navigateToNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotesScreen(),
      ),
    );
  }
}
