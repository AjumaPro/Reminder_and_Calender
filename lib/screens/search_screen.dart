import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../models/task.dart';
import '../models/note.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Task> _filteredTasks = [];
  List<Note> _filteredNotes = [];
  String _currentQuery = '';
  String _selectedFilter = 'All';
  bool _isSearching = false;

  final List<String> _filters = [
    'All',
    'Tasks',
    'Notes',
    'High Priority',
    'Completed',
    'Pending',
    'Pinned',
    'Today',
    'This Week',
  ];

  final List<Map<String, dynamic>> _savedSearches = [
    {
      'name': 'Today\'s Tasks',
      'query': 'today',
      'filter': 'Tasks',
      'icon': Icons.today,
    },
    {
      'name': 'High Priority',
      'query': 'priority:high',
      'filter': 'High Priority',
      'icon': Icons.priority_high,
    },
    {
      'name': 'Pinned Notes',
      'query': 'pinned',
      'filter': 'Pinned',
      'icon': Icons.push_pin,
    },
    {
      'name': 'This Week',
      'query': 'week',
      'filter': 'This Week',
      'icon': Icons.view_week,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _currentQuery = _searchController.text;
      _performSearch();
    });
  }

  void _performSearch() {
    if (_currentQuery.isEmpty) {
      setState(() {
        _filteredTasks = [];
        _filteredNotes = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final taskProvider = context.read<TaskProvider>();
        final noteProvider = context.read<NoteProvider>();

        final allTasks = taskProvider.tasks;
        final allNotes = noteProvider.notes;

        List<Task> tasks = [];
        List<Note> notes = [];

        // Apply search query
        if (_currentQuery.isNotEmpty) {
          tasks = allTasks.where((task) {
            return task.title
                    .toLowerCase()
                    .contains(_currentQuery.toLowerCase()) ||
                task.description
                    .toLowerCase()
                    .contains(_currentQuery.toLowerCase());
          }).toList();

          notes = allNotes.where((note) {
            return note.title
                    .toLowerCase()
                    .contains(_currentQuery.toLowerCase()) ||
                note.content
                    .toLowerCase()
                    .contains(_currentQuery.toLowerCase()) ||
                note.tags.any((tag) =>
                    tag.toLowerCase().contains(_currentQuery.toLowerCase()));
          }).toList();
        } else {
          tasks = allTasks;
          notes = allNotes;
        }

        // Apply filters
        tasks = _applyTaskFilters(tasks);
        notes = _applyNoteFilters(notes);

        setState(() {
          _filteredTasks = tasks;
          _filteredNotes = notes;
          _isSearching = false;
        });
      }
    });
  }

  List<Task> _applyTaskFilters(List<Task> tasks) {
    switch (_selectedFilter) {
      case 'Tasks':
        return tasks;
      case 'High Priority':
        return tasks.where((task) => task.priority == 2).toList();
      case 'Completed':
        return tasks.where((task) => task.isCompleted).toList();
      case 'Pending':
        return tasks.where((task) => !task.isCompleted).toList();
      case 'Today':
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        return tasks.where((task) {
          final taskDate =
              DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
          return taskDate == todayDate;
        }).toList();
      case 'This Week':
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return tasks.where((task) {
          final taskDate =
              DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
          return taskDate.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
      default:
        return tasks;
    }
  }

  List<Note> _applyNoteFilters(List<Note> notes) {
    switch (_selectedFilter) {
      case 'Notes':
        return notes;
      case 'Pinned':
        return notes.where((note) => note.isPinned).toList();
      default:
        return notes;
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _performSearch();
    });
  }

  void _loadSavedSearch(Map<String, dynamic> search) {
    setState(() {
      _searchController.text = search['query'];
      _selectedFilter = search['filter'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Smart Search',
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
            icon: const Icon(Icons.tune),
            onPressed: () => _showAdvancedFilters(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          _buildSavedSearches(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF667EEA),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks, notes, tags...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF667EEA)),
                suffixIcon: _currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          if (_currentQuery.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_filteredTasks.length + _filteredNotes.length} results found',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => _applyFilter(filter),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF667EEA).withOpacity(0.2),
              checkmarkColor: const Color(0xFF667EEA),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF667EEA) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSavedSearches() {
    if (_currentQuery.isNotEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saved Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: _savedSearches.length,
            itemBuilder: (context, index) {
              final search = _savedSearches[index];
              return _buildSavedSearchCard(search);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSavedSearchCard(Map<String, dynamic> search) {
    return InkWell(
      onTap: () => _loadSavedSearch(search),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                search['icon'],
                color: const Color(0xFF667EEA),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    search['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    search['filter'],
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
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
      );
    }

    if (_currentQuery.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Start typing to search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredTasks.isEmpty && _filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_currentQuery"',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_filteredTasks.isNotEmpty) ...[
          _buildSectionHeader('Tasks', _filteredTasks.length),
          const SizedBox(height: 12),
          ..._filteredTasks.map((task) => _buildTaskResult(task)),
          const SizedBox(height: 20),
        ],
        if (_filteredNotes.isNotEmpty) ...[
          _buildSectionHeader('Notes', _filteredNotes.length),
          const SizedBox(height: 12),
          ..._filteredNotes.map((note) => _buildNoteResult(note)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667EEA),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskResult(Task task) {
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
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getPriorityColor(task.priority).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.task_alt,
            color: _getPriorityColor(task.priority),
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
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
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(task.dueDate),
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
                    color: _getPriorityColor(task.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getPriorityText(task.priority),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getPriorityColor(task.priority),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () => _viewTask(task),
        ),
      ),
    );
  }

  Widget _buildNoteResult(Note note) {
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
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF9C27B0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.note,
            color: Color(0xFF9C27B0),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (note.isPinned)
              const Icon(
                Icons.push_pin,
                color: Colors.red,
                size: 16,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: note.tags
                    .take(3)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () => _viewNote(note),
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

  void _viewTask(Task task) {
    // TODO: Navigate to task detail view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing task: ${task.title}'),
        backgroundColor: const Color(0xFF667EEA),
      ),
    );
  }

  void _viewNote(Note note) {
    // TODO: Navigate to note detail view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing note: ${note.title}'),
        backgroundColor: const Color(0xFF9C27B0),
      ),
    );
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: const Text('Advanced filter options coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
