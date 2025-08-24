import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  bool _isPinned = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _loadNoteData();
    }
  }

  void _loadNoteData() {
    final note = widget.note!;
    _titleController.text = note.title;
    _contentController.text = note.content;
    _tagsController.text = note.tags.join(', ');
    _isPinned = note.isPinned;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
          IconButton(
            icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildContentField(),
            const SizedBox(height: 16),
            _buildTagsField(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Note Title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a note title';
        }
        return null;
      },
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      decoration: const InputDecoration(
        labelText: 'Note Content',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
        alignLabelWithHint: true,
      ),
      maxLines: 10,
      textAlignVertical: TextAlignVertical.top,
    );
  }

  Widget _buildTagsField() {
    return TextFormField(
      controller: _tagsController,
      decoration: const InputDecoration(
        labelText: 'Tags (comma separated)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.tag),
        hintText: 'work, important, todo',
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(widget.note == null ? 'Create Note' : 'Update Note'),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final noteProvider = context.read<NoteProvider>();

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        taskId: widget.note?.taskId,
        tags: tags,
        isPinned: _isPinned,
      );

      if (widget.note == null) {
        await noteProvider.addNote(note);
      } else {
        await noteProvider.updateNote(note);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.note == null
                  ? 'Note created successfully!'
                  : 'Note updated successfully!',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content:
            Text('Are you sure you want to delete "${widget.note!.title}"?'),
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
      try {
        final noteProvider = context.read<NoteProvider>();
        await noteProvider.deleteNote(widget.note!.id);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
