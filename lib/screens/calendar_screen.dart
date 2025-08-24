import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_fab.dart';
import 'task_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar & Reminders'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<CalendarFormat>(
            icon: const Icon(Icons.view_agenda),
            onSelected: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarFormat.month,
                child: Text('Month'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Week'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.twoWeeks,
                child: Text('2 Weeks'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          _updateEvents(taskProvider.tasks);

          return Column(
            children: [
              TableCalendar<Task>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  taskProvider.setSelectedDate(selectedDay);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: (day) {
                  return _events[DateTime(day.year, day.month, day.day)] ?? [];
                },
                calendarStyle: const CalendarStyle(
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildTaskList(taskProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: const AddTaskFAB(),
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider) {
    final tasksForSelectedDay = taskProvider.getTasksForDate(_selectedDay!);

    if (tasksForSelectedDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for ${DateFormat('MMM dd, yyyy').format(_selectedDay!)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a task',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasksForSelectedDay.length,
      itemBuilder: (context, index) {
        final task = tasksForSelectedDay[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TaskCard(
            task: task,
            onTap: () => _openTaskEditor(task),
            onToggle: () => taskProvider.toggleTaskCompletion(task.id),
            onDelete: () => _deleteTask(taskProvider, task),
          ),
        );
      },
    );
  }

  void _updateEvents(List<Task> tasks) {
    _events.clear();
    for (final task in tasks) {
      final date =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      if (_events[date] == null) _events[date] = [];
      _events[date]!.add(task);
    }
  }

  void _openTaskEditor(Task? task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditorScreen(task: task),
      ),
    );
  }

  Future<void> _deleteTask(TaskProvider taskProvider, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await taskProvider.deleteTask(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task "${task.title}" deleted')),
        );
      }
    }
  }
}
