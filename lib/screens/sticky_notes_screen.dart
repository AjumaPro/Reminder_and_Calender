import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';

class StickyNotesScreen extends StatefulWidget {
  const StickyNotesScreen({super.key});

  @override
  State<StickyNotesScreen> createState() => _StickyNotesScreenState();
}

class _StickyNotesScreenState extends State<StickyNotesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  String _filterTag = 'all';

  final List<Color> _noteColors = [
    const Color(0xFFFFF2CC), // Light Yellow
    const Color(0xFFE1F5FE), // Light Blue
    const Color(0xFFF3E5F5), // Light Purple
    const Color(0xFFE8F5E8), // Light Green
    const Color(0xFFFFEBEE), // Light Red
    const Color(0xFFFCE4EC), // Light Pink
    const Color(0xFFF1F8E9), // Light Lime
    const Color(0xFFE0F2F1), // Light Teal
  ];

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
          'Sticky Notes',
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
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStickyNoteDialog(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<NoteProvider>(
          builder: (context, noteProvider, child) {
            final filteredNotes = _getFilteredNotes(noteProvider.notes);

            if (filteredNotes.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildStickyNotesGrid(filteredNotes, noteProvider),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStickyNoteDialog(),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (_searchQuery.isEmpty && _filterTag == 'all')
      return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          if (_searchQuery.isNotEmpty) ...[
            Icon(Icons.search, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Searching: "$_searchQuery"',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () => setState(() => _searchQuery = ''),
            ),
          ],
          if (_filterTag != 'all') ...[
            if (_searchQuery.isNotEmpty) const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tag: $_filterTag',
                    style: const TextStyle(
                      color: Color(0xFF667EEA),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _filterTag = 'all'),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStickyNotesGrid(List<Note> notes, NoteProvider noteProvider) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildStickyNote(note, noteProvider, index);
      },
    );
  }

  Widget _buildStickyNote(Note note, NoteProvider noteProvider, int index) {
    final colorIndex = index % _noteColors.length;
    final noteColor = _noteColors[colorIndex];

    return GestureDetector(
      onTap: () => _editStickyNote(note),
      onLongPress: () => _showNoteOptions(note, noteProvider),
      child: Container(
        decoration: BoxDecoration(
          color: noteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Note content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Content
                  Expanded(
                    child: Text(
                      note.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tags
                  if (note.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: note.tags
                          .take(2)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  // Date
                  Text(
                    DateFormat('MMM dd').format(note.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            // Pin indicator
            if (note.isPinned)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Sticky Notes Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first colorful sticky note!\nTap the + button to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddStickyNoteDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Note'),
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

  List<Note> _getFilteredNotes(List<Note> notes) {
    var filtered = notes;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((note) =>
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.tags.any((tag) =>
                  tag.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    // Filter by tag
    if (_filterTag != 'all') {
      filtered =
          filtered.where((note) => note.tags.contains(_filterTag)).toList();
    }

    // Sort by pinned first, then by creation date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Notes'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Search term',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Search will be handled by onSubmitted
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final noteProvider = context.read<NoteProvider>();
    final allTags = <String>{};

    for (final note in noteProvider.notes) {
      allTags.addAll(note.tags);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('All Notes'),
              value: 'all',
              groupValue: _filterTag,
              onChanged: (value) {
                setState(() => _filterTag = value!);
                Navigator.pop(context);
              },
            ),
            ...allTags.map((tag) => RadioListTile<String>(
                  title: Text('Tag: $tag'),
                  value: tag,
                  groupValue: _filterTag,
                  onChanged: (value) {
                    setState(() => _filterTag = value!);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showAddStickyNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddStickyNoteDialog(),
    );
  }

  void _editStickyNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => EditStickyNoteDialog(note: note),
    );
  }

  void _showNoteOptions(Note note, NoteProvider noteProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Note'),
              onTap: () {
                Navigator.pop(context);
                _editStickyNote(note);
              },
            ),
            ListTile(
              leading: Icon(
                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: note.isPinned ? Colors.red : null,
              ),
              title: Text(note.isPinned ? 'Unpin Note' : 'Pin Note'),
              onTap: () {
                noteProvider.togglePin(note.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFF44336)),
              title: const Text('Delete Note',
                  style: TextStyle(color: Color(0xFFF44336))),
              onTap: () {
                Navigator.pop(context);
                _deleteNote(note, noteProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteNote(Note note, NoteProvider noteProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              noteProvider.deleteNote(note.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note deleted!'),
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

class AddStickyNoteDialog extends StatefulWidget {
  const AddStickyNoteDialog({super.key});

  @override
  State<AddStickyNoteDialog> createState() => _AddStickyNoteDialogState();
}

class _AddStickyNoteDialogState extends State<AddStickyNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPinned = false;

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
              Icons.note_add,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add Sticky Note'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Note Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
                hintText: 'work, ideas, important',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Pin Note'),
              subtitle: const Text('Keep at top of list'),
              value: _isPinned,
              onChanged: (value) => setState(() => _isPinned = value),
              secondary: const Icon(Icons.push_pin),
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
          onPressed: () => _createNote(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          child: const Text('Create Note'),
        ),
      ],
    );
  }

  void _createNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note title'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    final noteProvider = context.read<NoteProvider>();
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tags: _tagsController.text.trim().isNotEmpty
          ? _tagsController.text.trim().split(',').map((e) => e.trim()).toList()
          : [],
      isPinned: _isPinned,
      createdAt: DateTime.now(),
    );

    noteProvider.addNote(note);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sticky note "${note.title}" created!'),
        backgroundColor: const Color(0xFF4CAF50),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            noteProvider.deleteNote(note.id);
          },
        ),
      ),
    );
  }
}

class EditStickyNoteDialog extends StatefulWidget {
  final Note note;

  const EditStickyNoteDialog({super.key, required this.note});

  @override
  State<EditStickyNoteDialog> createState() => _EditStickyNoteDialogState();
}

class _EditStickyNoteDialogState extends State<EditStickyNoteDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _tagsController = TextEditingController(text: widget.note.tags.join(', '));
    _isPinned = widget.note.isPinned;
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
              Icons.edit,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Edit Sticky Note'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Note Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
                hintText: 'work, ideas, important',
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Pin Note'),
              subtitle: const Text('Keep at top of list'),
              value: _isPinned,
              onChanged: (value) => setState(() => _isPinned = value),
              secondary: const Icon(Icons.push_pin),
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
          onPressed: () => _updateNote(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
          ),
          child: const Text('Update Note'),
        ),
      ],
    );
  }

  void _updateNote() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note title'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    final noteProvider = context.read<NoteProvider>();
    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      tags: _tagsController.text.trim().isNotEmpty
          ? _tagsController.text.trim().split(',').map((e) => e.trim()).toList()
          : [],
      isPinned: _isPinned,
      updatedAt: DateTime.now(),
    );

    noteProvider.updateNote(updatedNote);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sticky note "${updatedNote.title}" updated!'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
