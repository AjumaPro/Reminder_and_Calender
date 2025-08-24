import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Calendar',
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
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEventDialog(),
          ),
          PopupMenuButton<CalendarFormat>(
            icon: const Icon(Icons.view_week),
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
                value: CalendarFormat.twoWeeks,
                child: Text('2 Weeks'),
              ),
              const PopupMenuItem(
                value: CalendarFormat.week,
                child: Text('Week'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              _buildCalendar(taskProvider),
              const Divider(height: 1),
              Expanded(
                child: _buildEventsList(taskProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendar(TaskProvider taskProvider) {
    return Container(
      margin: const EdgeInsets.all(12),
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
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Color(0xFF667EEA)),
          holidayTextStyle: TextStyle(color: Color(0xFFF44336)),
          selectedDecoration: BoxDecoration(
            color: Color(0xFF667EEA),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Color(0xFFFF9800),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          leftChevronPadding: EdgeInsets.zero,
          rightChevronPadding: EdgeInsets.zero,
        ),
        eventLoader: (day) {
          return taskProvider.tasks
              .where((task) => isSameDay(task.dueDate, day))
              .toList();
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF9800),
                  ),
                  width: 8,
                  height: 8,
                ),
              );
            }
            return null;
          },
          dowBuilder: (context, day) {
            if (day.weekday == DateTime.saturday ||
                day.weekday == DateTime.sunday) {
              return Center(
                child: Text(
                  DateFormat.E().format(day)[0],
                  style: const TextStyle(color: Color(0xFF667EEA)),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildEventsList(TaskProvider taskProvider) {
    final dayTasks = taskProvider.tasks
        .where((task) => isSameDay(task.dueDate, _selectedDay))
        .toList();

    if (dayTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No events for ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add an event',
              style: TextStyle(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayTasks.length,
      itemBuilder: (context, index) {
        final task = dayTasks[index];
        return _buildEventCard(task, taskProvider);
      },
    );
  }

  Widget _buildEventCard(Task task, TaskProvider taskProvider) {
    final isOverdue =
        task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;
    final isToday = isSameDay(task.dueDate, DateTime.now());

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
          color: isOverdue
              ? const Color(0xFFF44336).withOpacity(0.3)
              : isToday
                  ? const Color(0xFF4CAF50).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getPriorityColor(task.priority).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            task.isCompleted ? Icons.check_circle : Icons.event,
            color: task.isCompleted
                ? const Color(0xFF4CAF50)
                : _getPriorityColor(task.priority),
            size: 24,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(task.dueDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getPriorityText(task.priority),
                    style: TextStyle(
                      fontSize: 9,
                      color: _getPriorityColor(task.priority),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF44336).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFFF44336),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (isToday && !isOverdue)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.hasAlarm)
                const Icon(
                  Icons.alarm,
                  size: 14,
                  color: Color(0xFFFF9800),
                ),
              const SizedBox(width: 4),
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  taskProvider.toggleTaskCompletion(task.id);
                },
                activeColor: const Color(0xFF4CAF50),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 18),
                itemBuilder: (context) => [
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
                onSelected: (value) {
                  if (value == 'edit') {
                    _editTask(task);
                  } else if (value == 'delete') {
                    _deleteTask(task, taskProvider);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
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

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(selectedDate: _selectedDay),
    );
  }

  void _editTask(Task task) {
    // TODO: Navigate to task editor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task editing coming soon!'),
        backgroundColor: Color(0xFF667EEA),
      ),
    );
  }

  void _deleteTask(Task task, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskProvider.deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event deleted!'),
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

class AddEventDialog extends StatefulWidget {
  final DateTime selectedDate;

  const AddEventDialog({super.key, required this.selectedDate});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _priority = 1;
  bool _hasAlarm = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add Event'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Date'),
                    subtitle:
                        Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Time'),
                    subtitle: Text(_selectedTime.format(context)),
                    leading: const Icon(Icons.schedule),
                    onTap: () => _selectTime(),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Priority'),
                    subtitle: Text(_getPriorityText(_priority)),
                    leading: Icon(
                      Icons.priority_high,
                      color: _getPriorityColor(_priority),
                    ),
                    onTap: () => _selectPriority(),
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Alarm'),
                    value: _hasAlarm,
                    onChanged: (value) => setState(() => _hasAlarm = value),
                    secondary: const Icon(Icons.alarm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _createEvent(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          child: const Text('Create Event'),
        ),
      ],
    );
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

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _selectPriority() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.arrow_downward, color: Color(0xFF4CAF50)),
              title: const Text('Low Priority'),
              onTap: () {
                setState(() => _priority = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.remove, color: Color(0xFFF9800)),
              title: const Text('Medium Priority'),
              onTap: () {
                setState(() => _priority = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: Color(0xFFF44336)),
              title: const Text('High Priority'),
              onTap: () {
                setState(() => _priority = 2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _createEvent() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an event title'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    final eventDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: eventDateTime,
      priority: _priority,
      hasAlarm: _hasAlarm,
      createdAt: DateTime.now(),
    );

    taskProvider.addTask(task);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event "${task.title}" created successfully!'),
        backgroundColor: const Color(0xFF4CAF50),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            taskProvider.deleteTask(task.id);
          },
        ),
      ),
    );
  }
}
