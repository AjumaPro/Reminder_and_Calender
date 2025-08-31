import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../models/task.dart';
import '../models/note.dart';

class NotificationsBoard extends StatefulWidget {
  const NotificationsBoard({super.key});

  @override
  State<NotificationsBoard> createState() => _NotificationsBoardState();
}

class _NotificationsBoardState extends State<NotificationsBoard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _filterType = 'all'; // all, tasks, notes, reminders, overdue

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
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
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
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
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _clearAllNotifications(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer2<TaskProvider, NoteProvider>(
          builder: (context, taskProvider, noteProvider, child) {
            final notifications = _getNotifications(taskProvider, noteProvider);

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildSummaryCard(taskProvider, noteProvider),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(notifications[index]);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      TaskProvider taskProvider, NoteProvider noteProvider) {
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;
    final overdueTasks = taskProvider.tasks
        .where((task) =>
            task.dueDate.isBefore(DateTime.now()) && !task.isCompleted)
        .length;
    final todayTasks = taskProvider.tasks
        .where((task) => _isSameDay(task.dueDate, DateTime.now()))
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('MMM dd').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total',
                  totalTasks.toString(),
                  Icons.task_alt,
                  Colors.white,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Completed',
                  completedTasks.toString(),
                  Icons.check_circle,
                  const Color(0xFF4CAF50),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Today',
                  todayTasks.toString(),
                  Icons.today,
                  const Color(0xFFFF9800),
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Overdue',
                  overdueTasks.toString(),
                  Icons.warning,
                  const Color(0xFFF44336),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re all caught up!\nCreate some tasks to see notifications here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToDashboard(),
            icon: const Icon(Icons.add),
            label: const Text('Create Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<NotificationItem> _getNotifications(
      TaskProvider taskProvider, NoteProvider noteProvider) {
    final notifications = <NotificationItem>[];

    // Add task notifications
    for (final task in taskProvider.tasks) {
      if (_shouldIncludeTask(task)) {
        notifications.add(NotificationItem(
          id: task.id,
          title: task.title,
          message:
              task.description.isNotEmpty ? task.description : 'Task due soon',
          type: _getTaskNotificationType(task),
          timestamp: task.dueDate,
          priority: task.priority,
          isCompleted: task.isCompleted,
          hasAlarm: task.hasAlarm,
          task: task,
        ));
      }
    }

    // Add note notifications (for pinned notes)
    for (final note in noteProvider.notes.where((n) => n.isPinned)) {
      if (_filterType == 'all' || _filterType == 'notes') {
        notifications.add(NotificationItem(
          id: note.id,
          title: 'Pinned Note: ${note.title}',
          message: note.content,
          type: NotificationType.note,
          timestamp: note.createdAt,
          priority: 1,
          isCompleted: false,
          hasAlarm: false,
          note: note,
        ));
      }
    }

    // Sort by timestamp (most recent first)
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return notifications;
  }

  bool _shouldIncludeTask(Task task) {
    switch (_filterType) {
      case 'all':
        return true;
      case 'tasks':
        return !task.hasAlarm;
      case 'reminders':
        return task.hasAlarm;
      case 'overdue':
        return task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
      default:
        return true;
    }
  }

  NotificationType _getTaskNotificationType(Task task) {
    if (task.dueDate.isBefore(DateTime.now()) && !task.isCompleted) {
      return NotificationType.overdue;
    } else if (task.hasAlarm) {
      return NotificationType.reminder;
    } else {
      return NotificationType.task;
    }
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: _getNotificationColor(notification.type).withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: notification.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: notification.isCompleted ? Colors.grey : null,
                ),
              ),
            ),
            if (notification.hasAlarm)
              const Icon(
                Icons.alarm,
                size: 16,
                color: Color(0xFFFF9800),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.message.isNotEmpty)
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(notification.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(notification.priority)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getPriorityText(notification.priority),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getPriorityColor(notification.priority),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getNotificationTypeText(notification.type),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getNotificationColor(notification.type),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (notification.task != null && !notification.isCompleted)
              Checkbox(
                value: notification.isCompleted,
                onChanged: (value) {
                  context
                      .read<TaskProvider>()
                      .toggleTaskCompletion(notification.id);
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                if (notification.task != null) ...[
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Color(0xFFF44336)),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: Color(0xFFF44336))),
                      ],
                    ),
                  ),
                ],
              ],
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _viewDetails(notification);
                    break;
                  case 'edit':
                    _editNotification(notification);
                    break;
                  case 'delete':
                    _deleteNotification(notification);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return const Color(0xFF667EEA);
      case NotificationType.reminder:
        return const Color(0xFFFF9800);
      case NotificationType.overdue:
        return const Color(0xFFF44336);
      case NotificationType.note:
        return const Color(0xFF9C27B0);
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return Icons.task_alt;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.overdue:
        return Icons.warning;
      case NotificationType.note:
        return Icons.note;
    }
  }

  String _getNotificationTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.task:
        return 'TASK';
      case NotificationType.reminder:
        return 'REMINDER';
      case NotificationType.overdue:
        return 'OVERDUE';
      case NotificationType.note:
        return 'NOTE';
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return const Color(0xFF4CAF50);
      case 1:
        return const Color(0xFFFF9800);
      case 2:
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Normal';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All Notifications'),
              value: 'all',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Tasks Only'),
              value: 'tasks',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Reminders Only'),
              value: 'reminders',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Overdue Only'),
              value: 'overdue',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Notes Only'),
              value: 'notes',
              groupValue: _filterType,
              onChanged: (value) {
                setState(() => _filterType = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
            'This will mark all notifications as read. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear all notifications by marking tasks as completed
              final taskProvider = context.read<TaskProvider>();
              for (final task in taskProvider.tasks) {
                if (!task.isCompleted) {
                  taskProvider.toggleTaskCompletion(task.id);
                }
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    // Navigate to dashboard
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  void _viewDetails(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Text(
              'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(notification.timestamp)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${_getNotificationTypeText(notification.type)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              'Priority: ${_getPriorityText(notification.priority)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editNotification(NotificationItem notification) {
    if (notification.task != null) {
      // Navigate to task edit screen
      Navigator.pushNamed(context, '/edit-task', arguments: notification.task);
    } else if (notification.note != null) {
      // Navigate to note edit screen
      Navigator.pushNamed(context, '/edit-note', arguments: notification.note);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit this notification type'),
          backgroundColor: Color(0xFFFF9800),
        ),
      );
    }
  }

  void _deleteNotification(NotificationItem notification) {
    if (notification.task != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Task'),
          content:
              Text('Are you sure you want to delete "${notification.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<TaskProvider>().deleteTask(notification.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task deleted!'),
                    backgroundColor: Color(0xFFF44336),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}

enum NotificationType {
  task,
  reminder,
  overdue,
  note,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final int priority;
  final bool isCompleted;
  final bool hasAlarm;
  final Task? task;
  final Note? note;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.priority,
    required this.isCompleted,
    required this.hasAlarm,
    this.task,
    this.note,
  });
}
