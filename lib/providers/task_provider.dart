import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/local_storage_service.dart';
// import '../services/notification_service.dart';  // Temporarily disabled for Android build

class TaskProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  // final NotificationService _notificationService = NotificationService();  // Temporarily disabled for Android build

  List<Task> _tasks = [];
  DateTime _selectedDate = DateTime.now();

  List<Task> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;

  List<Task> get tasksForSelectedDate => _tasks.where((task) {
        final taskDate =
            DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
        final selectedDate = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day);
        return taskDate.isAtSameMomentAs(selectedDate);
      }).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  Future<void> loadTasks() async {
    try {
      _tasks = _storage.getAllTasks();
      notifyListeners();
    } catch (e) {
      print('Error loading tasks: $e');
      _tasks = [];
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    await _storage.addTask(task);
    _tasks.add(task);

    // if (task.hasAlarm) {
    //   await _notificationService.scheduleTaskReminder(task);
    // }

    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _storage.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;

      // Update notification
      // await _notificationService.cancelTaskReminder(task);
      // if (task.hasAlarm) {
      //   await _notificationService.scheduleTaskReminder(task);
      // }
    }
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await _storage.deleteTask(taskId);
    // await _notificationService.cancelTaskReminder(task);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );

      await updateTask(updatedTask);
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  List<Task> getTasksForDateRange(DateTime startDate, DateTime endDate) {
    return _tasks.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return taskDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          taskDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<Task> getTasksByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  List<Task> getTasksByPriority(int priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<String> getCategories() {
    return _tasks.map((task) => task.category).toSet().toList();
  }

  Future<Map<String, dynamic>> exportData() async {
    return await _storage.exportData();
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await _storage.importData(data);
    await loadTasks();
  }

  Future<void> clearAllData() async {
    await _storage.clearAllData();
    // await _notificationService.cancelAllReminders();
    _tasks.clear();
    notifyListeners();
  }
}
