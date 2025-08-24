import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/local_storage_service.dart';

class NoteProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  List<Note> _notes = [];

  List<Note> get notes => _notes;
  List<Note> get pinnedNotes => _notes.where((note) => note.isPinned).toList();
  List<Note> get unpinnedNotes =>
      _notes.where((note) => !note.isPinned).toList();

  Future<void> loadNotes() async {
    try {
      _notes = _storage.getAllNotes();
      notifyListeners();
    } catch (e) {
      print('Error loading notes: $e');
      _notes = [];
      notifyListeners();
    }
  }

  Future<void> addNote(Note note) async {
    await _storage.addNote(note);
    _notes.add(note);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    await _storage.updateNote(note);
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    }
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await _storage.deleteNote(noteId);
    _notes.removeWhere((n) => n.id == noteId);
    notifyListeners();
  }

  Future<void> togglePin(String noteId) async {
    final index = _notes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      final note = _notes[index];
      final updatedNote = note.copyWith(isPinned: !note.isPinned);
      await updateNote(updatedNote);
    }
  }

  List<Note> getNotesForTask(String taskId) {
    return _notes.where((note) => note.taskId == taskId).toList();
  }

  List<Note> getNotesByTag(String tag) {
    return _notes.where((note) => note.tags.contains(tag)).toList();
  }

  List<String> getAllTags() {
    final allTags = <String>{};
    for (final note in _notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList();
  }

  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;

    final lowercaseQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.content.toLowerCase().contains(lowercaseQuery) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<Note> getNotesByDateRange(DateTime startDate, DateTime endDate) {
    return _notes.where((note) {
      return note.createdAt
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
          note.createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Note? getNote(String noteId) {
    try {
      return _notes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }
}
