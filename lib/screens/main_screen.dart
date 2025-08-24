import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import 'simple_dashboard.dart';
import 'calendar_view.dart';
import 'notifications_board.dart';
import 'sticky_notes_screen.dart';
import 'analytics_screen.dart';
import 'pomodoro_screen.dart';
import 'theme_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isSidebarOpen = false;

  // Main menu items (frequently used)
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard,
      'color': const Color(0xFF667EEA),
    },
    {
      'title': 'Calendar',
      'icon': Icons.calendar_today,
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Tasks',
      'icon': Icons.task_alt,
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Notes',
      'icon': Icons.note,
      'color': const Color(0xFF9C27B0),
    },
    {
      'title': 'Analytics',
      'icon': Icons.analytics,
      'color': const Color(0xFF2196F3),
    },
  ];

  // Sidebar items (less frequently used)
  final List<Map<String, dynamic>> _sidebarItems = [
    {
      'title': 'Notifications',
      'icon': Icons.notifications,
      'color': const Color(0xFFFF5722),
    },
    {
      'title': 'Pomodoro',
      'icon': Icons.timer,
      'color': const Color(0xFFE91E63),
    },
    {
      'title': 'Search',
      'icon': Icons.search,
      'color': const Color(0xFF607D8B),
    },
    {
      'title': 'Themes',
      'icon': Icons.palette,
      'color': const Color(0xFF795548),
    },
    {
      'title': 'Settings',
      'icon': Icons.settings,
      'color': const Color(0xFF757575),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth < 600 ? screenWidth * 0.8 : 280.0;

    return Scaffold(
      body: Stack(
        children: [
          // Main content (always takes full width)
          Column(
            children: [
              // Top App Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isSidebarOpen ? Icons.menu_open : Icons.menu,
                        color: const Color(0xFF667EEA),
                      ),
                      onPressed: () {
                        setState(() {
                          _isSidebarOpen = !_isSidebarOpen;
                        });
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _currentIndex < _menuItems.length
                            ? _menuItems[_currentIndex]['title']
                            : _sidebarItems[_currentIndex - _menuItems.length]
                                ['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // User profile or additional actions
                    CircleAvatar(
                      backgroundColor: const Color(0xFF667EEA).withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Area
              Expanded(
                child: _buildCurrentScreen(),
              ),
            ],
          ),

          // Backdrop overlay (to close sidebar when tapping outside)
          if (_isSidebarOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isSidebarOpen = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),

          // Sidebar overlay
          if (_isSidebarOpen)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping inside sidebar
                child: Container(
                  width: sidebarWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Sidebar Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu_open,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Menu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                setState(() {
                                  _isSidebarOpen = false;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      // Sidebar Items
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            const Text(
                              'Tools & Settings',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._sidebarItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return _buildSidebarItem(
                                  item, index + _menuItems.length);
                            }).toList(),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),
                            _buildSidebarFooter(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      // Bottom Navigation (only main items)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildBottomNavItem(item, index);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _currentIndex = index;
              _isSidebarOpen = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? item['color'].withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: _currentIndex == index
                  ? Border.all(color: item['color'].withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _currentIndex == index
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: _currentIndex == index
                          ? item['color']
                          : const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Column(
      children: [
        const Text(
          'App Version',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '1.0.0',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF667EEA),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavItem(Map<String, dynamic> item, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? item['color'].withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item['icon'],
              color: isSelected ? item['color'] : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item['title'],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? item['color'] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    // Handle navigation based on current index
    if (_currentIndex < _menuItems.length) {
      // Bottom navigation items
      switch (_currentIndex) {
        case 0:
          return const SimpleDashboard();
        case 1:
          return const CalendarView();
        case 2:
          return _buildTasksScreen();
        case 3:
          return const StickyNotesScreen();
        case 4:
          return const AnalyticsScreen();
        default:
          return const SimpleDashboard();
      }
    } else {
      // Sidebar items (index >= _menuItems.length)
      final sidebarIndex = _currentIndex - _menuItems.length;
      switch (sidebarIndex) {
        case 0:
          return const NotificationsBoard();
        case 1:
          return const PomodoroScreen();
        case 2:
          return const SearchScreen();
        case 3:
          return const ThemeScreen();
        case 4:
          return _buildSettingsScreen();
        default:
          return const SimpleDashboard();
      }
    }
  }

  Widget _buildTasksScreen() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks;

        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text('No Tasks Yet',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Create tasks from the Dashboard!',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    taskProvider.toggleTaskCompletion(task.id);
                  },
                  activeColor: const Color(0xFF4CAF50),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(task.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => taskProvider.deleteTask(task.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Settings panel coming soon!',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
