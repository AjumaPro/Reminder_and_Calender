import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/note.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late Box<Task> _taskBox;
  late Box<Note> _noteBox;

  Future<void> initialize() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(NoteAdapter());

    _taskBox = await Hive.openBox<Task>('tasks');
    _noteBox = await Hive.openBox<Note>('notes');
  }

  // Task operations
  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String taskId) async {
    await _taskBox.delete(taskId);
  }

  Task? getTask(String taskId) {
    return _taskBox.get(taskId);
  }

  List<Task> getAllTasks() {
    return _taskBox.values.toList();
  }

  List<Task> getTasksForDate(DateTime date) {
    return _taskBox.values.where((task) {
      final taskDate =
          DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      return taskDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  List<Task> getCompletedTasks() {
    return _taskBox.values.where((task) => task.isCompleted).toList();
  }

  List<Task> getPendingTasks() {
    return _taskBox.values.where((task) => !task.isCompleted).toList();
  }

  // Note operations
  Future<void> addNote(Note note) async {
    await _noteBox.put(note.id, note);
  }

  Future<void> updateNote(Note note) async {
    await _noteBox.put(note.id, note);
  }

  Future<void> deleteNote(String noteId) async {
    await _noteBox.delete(noteId);
  }

  Note? getNote(String noteId) {
    return _noteBox.get(noteId);
  }

  List<Note> getAllNotes() {
    return _noteBox.values.toList();
  }

  List<Note> getNotesForTask(String taskId) {
    return _noteBox.values.where((note) => note.taskId == taskId).toList();
  }

  List<Note> getPinnedNotes() {
    return _noteBox.values.where((note) => note.isPinned).toList();
  }

  // Backup and restore
  Future<Map<String, dynamic>> exportData() async {
    final tasks = getAllTasks().map((task) => task.toJson()).toList();
    final notes = getAllNotes().map((note) => note.toJson()).toList();

    return {
      'tasks': tasks,
      'notes': notes,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await _taskBox.clear();
    await _noteBox.clear();

    // Import tasks
    if (data['tasks'] != null) {
      for (final taskData in data['tasks']) {
        final task = Task.fromJson(taskData);
        await addTask(task);
      }
    }

    // Import notes
    if (data['notes'] != null) {
      for (final noteData in data['notes']) {
        final note = Note.fromJson(noteData);
        await addNote(note);
      }
    }
  }

  Future<void> clearAllData() async {
    await _taskBox.clear();
    await _noteBox.clear();
  }

  Future<void> dispose() async {
    await _taskBox.close();
    await _noteBox.close();
  }
}
