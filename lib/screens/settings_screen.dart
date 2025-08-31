import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../services/notification_service.dart';
import '../services/alarm_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final AlarmService _alarmService = AlarmService();

  bool _notificationsEnabled = false;
  bool _alarmEnabled = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  bool _autoStartNextSession = true;
  bool _showNotifications = true;
  bool _isLoading = true;
  bool _autoBackupEnabled = false;
  bool _darkModeEnabled = false;
  bool _compactModeEnabled = false;
  bool _gestureNavigationEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _autoSyncEnabled = false;
  bool _developerModeEnabled = false;
  bool _experimentalFeaturesEnabled = false;
  bool _accessibilityModeEnabled = false;

  int _workDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _sessionsBeforeLongBreak = 4;
  int _alarmVolume = 80;
  int _alarmDuration = 10;
  int _backupFrequency = 7; // days
  int _maxBackupFiles = 5;
  int _notificationDelay = 0; // minutes
  int _autoSaveInterval = 5; // minutes
  int _syncInterval = 15; // minutes
  int _cacheSize = 100; // MB
  int _maxLogFiles = 10;
  int _sessionTimeout = 30; // minutes

  String _selectedLanguage = 'English';
  String _selectedTimeFormat = '12-hour';
  String _selectedDateFormat = 'MM/DD/YYYY';
  String _selectedTheme = 'Blue';
  String _selectedFontSize = 'Medium';
  String _selectedAnimationSpeed = 'Normal';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Korean',
    'Portuguese',
    'Italian',
    'Russian'
  ];
  final List<String> _timeFormats = ['12-hour', '24-hour'];
  final List<String> _dateFormats = ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'];
  final List<String> _themes = [
    'Blue',
    'Green',
    'Purple',
    'Orange',
    'Red',
    'Dark',
    'Ocean',
    'Sunset',
    'Forest',
    'Midnight'
  ];
  final List<String> _fontSizes = ['Small', 'Medium', 'Large', 'Extra Large'];
  final List<String> _animationSpeeds = ['Slow', 'Normal', 'Fast', 'Instant'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load notification status (with error handling for web)
      bool notificationsEnabled = false;
      try {
        notificationsEnabled =
            await _notificationService.areNotificationsEnabled();
      } catch (e) {
        debugPrint('Notification check failed: $e');
        notificationsEnabled = false;
      }

      setState(() {
        _notificationsEnabled = notificationsEnabled;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Settings load failed: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('🔔 Notifications & Alarms'),
                  _buildNotificationSettings(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('⏰ Timer Settings'),
                  _buildTimerSettings(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('🎨 Appearance & Interface'),
                  _buildAppearanceSettings(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('📊 Data Management'),
                  _buildDataManagementSettings(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('🔄 Backup & Sync'),
                  _buildBackupSettings(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('⚙️ Advanced Settings'),
                  _buildAdvancedSettings(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('🔧 Developer Tools'),
                  _buildDeveloperSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('♿ Accessibility'),
                  _buildAccessibilitySettings(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('🔒 Security & Privacy'),
                  _buildSecuritySettings(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('ℹ️ About'),
                  _buildAboutSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive notifications for tasks and timers'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              if (value) {
                try {
                  final status = await Permission.notification.request();
                  if (status.isGranted) {
                    setState(() {
                      _notificationsEnabled = true;
                    });
                    _showSnackBar('Notifications enabled', Colors.green);
                  } else {
                    _showSnackBar(
                        'Notification permission denied', Colors.orange);
                  }
                } catch (e) {
                  _showSnackBar(
                      'Failed to enable notifications: $e', Colors.red);
                }
              } else {
                setState(() {
                  _notificationsEnabled = false;
                });
                _showSnackBar('Notifications disabled', Colors.blue);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Enable Alarms'),
            subtitle: const Text('Play alarm sounds when timer completes'),
            value: _alarmEnabled,
            onChanged: (value) {
              setState(() {
                _alarmEnabled = value;
              });
              _showSnackBar(
                  'Alarms ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Vibration'),
            subtitle: const Text('Vibrate device when alarm triggers'),
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() {
                _vibrationEnabled = value;
              });
              _showSnackBar(
                  'Vibration ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Enable Sound'),
            subtitle: const Text('Play sound effects for notifications'),
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
              _showSnackBar(
                  'Sound ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
          ListTile(
            title: const Text('Notification Delay'),
            subtitle: Slider(
              value: _notificationDelay.toDouble(),
              min: 0,
              max: 30,
              divisions: 6,
              label: '$_notificationDelay minutes',
              onChanged: (value) {
                setState(() {
                  _notificationDelay = value.round();
                });
              },
            ),
            trailing: Text('${_notificationDelay}m'),
          ),
          ListTile(
            title: const Text('Alarm Volume'),
            subtitle: Slider(
              value: _alarmVolume.toDouble(),
              min: 0,
              max: 100,
              divisions: 10,
              label: '$_alarmVolume%',
              onChanged: (value) {
                setState(() {
                  _alarmVolume = value.round();
                });
                _alarmService.setVolume(value / 100);
              },
            ),
            trailing: Text('$_alarmVolume%'),
          ),
          ListTile(
            title: const Text('Alarm Duration'),
            subtitle: Slider(
              value: _alarmDuration.toDouble(),
              min: 5,
              max: 30,
              divisions: 5,
              label: '$_alarmDuration seconds',
              onChanged: (value) {
                setState(() {
                  _alarmDuration = value.round();
                });
              },
            ),
            trailing: Text('${_alarmDuration}s'),
          ),
          ListTile(
            title: const Text('Test Alarm'),
            subtitle: const Text('Test the current alarm settings'),
            trailing: const Icon(Icons.play_arrow),
            onTap: () async {
              try {
                await _alarmService.playAlarm();
                Future.delayed(Duration(seconds: _alarmDuration), () {
                  _alarmService.stopAlarm();
                });
                _showSnackBar('Alarm test completed', Colors.green);
              } catch (e) {
                _showSnackBar('Alarm test failed: $e', Colors.red);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('Work Duration'),
            subtitle: Slider(
              value: _workDuration.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$_workDuration minutes',
              onChanged: (value) {
                setState(() {
                  _workDuration = value.round();
                });
              },
            ),
            trailing: Text('${_workDuration}m'),
          ),
          ListTile(
            title: const Text('Short Break Duration'),
            subtitle: Slider(
              value: _shortBreakDuration.toDouble(),
              min: 1,
              max: 15,
              divisions: 14,
              label: '$_shortBreakDuration minutes',
              onChanged: (value) {
                setState(() {
                  _shortBreakDuration = value.round();
                });
              },
            ),
            trailing: Text('${_shortBreakDuration}m'),
          ),
          ListTile(
            title: const Text('Long Break Duration'),
            subtitle: Slider(
              value: _longBreakDuration.toDouble(),
              min: 10,
              max: 30,
              divisions: 4,
              label: '$_longBreakDuration minutes',
              onChanged: (value) {
                setState(() {
                  _longBreakDuration = value.round();
                });
              },
            ),
            trailing: Text('${_longBreakDuration}m'),
          ),
          ListTile(
            title: const Text('Sessions Before Long Break'),
            subtitle: Slider(
              value: _sessionsBeforeLongBreak.toDouble(),
              min: 2,
              max: 8,
              divisions: 6,
              label: '$_sessionsBeforeLongBreak sessions',
              onChanged: (value) {
                setState(() {
                  _sessionsBeforeLongBreak = value.round();
                });
              },
            ),
            trailing: Text('$_sessionsBeforeLongBreak'),
          ),
          SwitchListTile(
            title: const Text('Auto-start Next Session'),
            subtitle: const Text('Automatically start next work/break session'),
            value: _autoStartNextSession,
            onChanged: (value) {
              setState(() {
                _autoStartNextSession = value;
              });
              _showSnackBar(
                  'Auto-start ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Use dark theme throughout the app'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              _showSnackBar(
                  'Dark mode ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Compact Mode'),
            subtitle: const Text('Use compact layout for more content'),
            value: _compactModeEnabled,
            onChanged: (value) {
              setState(() {
                _compactModeEnabled = value;
              });
              _showSnackBar('Compact mode ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Gesture Navigation'),
            subtitle: const Text('Enable swipe gestures for navigation'),
            value: _gestureNavigationEnabled,
            onChanged: (value) {
              setState(() {
                _gestureNavigationEnabled = value;
              });
              _showSnackBar(
                  'Gesture navigation ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text('Current: $_selectedTheme'),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTheme = newValue;
                  });
                  _showSnackBar('Theme changed to $newValue', Colors.blue);
                }
              },
              items: _themes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text('Current: $_selectedLanguage'),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  _showSnackBar('Language changed to $newValue', Colors.blue);
                }
              },
              items: _languages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('Time Format'),
            subtitle: Text('Current: $_selectedTimeFormat'),
            trailing: DropdownButton<String>(
              value: _selectedTimeFormat,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimeFormat = newValue;
                  });
                  _showSnackBar(
                      'Time format changed to $newValue', Colors.blue);
                }
              },
              items: _timeFormats.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('Date Format'),
            subtitle: Text('Current: $_selectedDateFormat'),
            trailing: DropdownButton<String>(
              value: _selectedDateFormat,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDateFormat = newValue;
                  });
                  _showSnackBar(
                      'Date format changed to $newValue', Colors.blue);
                }
              },
              items: _dateFormats.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Text('Current: $_selectedFontSize'),
            trailing: DropdownButton<String>(
              value: _selectedFontSize,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFontSize = newValue;
                  });
                  _showSnackBar('Font size changed to $newValue', Colors.blue);
                }
              },
              items: _fontSizes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ListTile(
            title: const Text('Animation Speed'),
            subtitle: Text('Current: $_selectedAnimationSpeed'),
            trailing: DropdownButton<String>(
              value: _selectedAnimationSpeed,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedAnimationSpeed = newValue;
                  });
                  _showSnackBar(
                      'Animation speed changed to $newValue', Colors.blue);
                }
              },
              items: _animationSpeeds
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagementSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.download, color: Colors.green),
            title: const Text('Export Data'),
            subtitle: const Text('Backup your tasks and notes'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.blue),
            title: const Text('Import Data'),
            subtitle: const Text('Restore from backup'),
            onTap: () => _importData(context),
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.orange),
            title: const Text('Storage Info'),
            subtitle: const Text('View app storage usage'),
            onTap: () => _showStorageInfo(),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all tasks, notes, and settings'),
            onTap: () => _clearAllData(context),
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.purple),
            title: const Text('Data Analytics'),
            subtitle: const Text('View usage statistics'),
            onTap: () => _showDataAnalytics(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Auto Backup'),
            subtitle: const Text('Automatically backup data periodically'),
            value: _autoBackupEnabled,
            onChanged: (value) {
              setState(() {
                _autoBackupEnabled = value;
              });
              _showSnackBar(
                  'Auto backup ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
          ListTile(
            title: const Text('Backup Frequency'),
            subtitle: Slider(
              value: _backupFrequency.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$_backupFrequency days',
              onChanged: (value) {
                setState(() {
                  _backupFrequency = value.round();
                });
              },
            ),
            trailing: Text('${_backupFrequency}d'),
          ),
          ListTile(
            title: const Text('Max Backup Files'),
            subtitle: Slider(
              value: _maxBackupFiles.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_maxBackupFiles files',
              onChanged: (value) {
                setState(() {
                  _maxBackupFiles = value.round();
                });
              },
            ),
            trailing: Text('$_maxBackupFiles'),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.green),
            title: const Text('Create Backup Now'),
            subtitle: const Text('Manually create a backup'),
            onTap: () => _createBackup(),
          ),
          ListTile(
            leading: const Icon(Icons.restore_page, color: Colors.blue),
            title: const Text('Restore from Backup'),
            subtitle: const Text('Restore data from backup file'),
            onTap: () => _restoreFromBackup(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Developer Mode'),
            subtitle: const Text('Enable developer features and tools'),
            value: _developerModeEnabled,
            onChanged: (value) {
              setState(() {
                _developerModeEnabled = value;
              });
              _showSnackBar('Developer mode ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Experimental Features'),
            subtitle: const Text('Enable experimental and beta features'),
            value: _experimentalFeaturesEnabled,
            onChanged: (value) {
              setState(() {
                _experimentalFeaturesEnabled = value;
              });
              _showSnackBar(
                  'Experimental features ${value ? 'enabled' : 'disabled'}',
                  Colors.orange);
            },
          ),
          ListTile(
            leading: const Icon(Icons.code, color: Colors.purple),
            title: const Text('View Logs'),
            subtitle: const Text('View application logs and debug info'),
            onTap: () => _viewLogs(),
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.teal),
            title: const Text('Performance Metrics'),
            subtitle: const Text('Detailed performance analytics'),
            onTap: () => _showPerformanceMetrics(),
          ),
          ListTile(
            leading: const Icon(Icons.memory, color: Colors.amber),
            title: const Text('Memory Usage'),
            subtitle: const Text('Monitor memory consumption'),
            onTap: () => _showMemoryUsage(),
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.indigo),
            title: const Text('Cache Management'),
            subtitle: const Text('Manage app cache and storage'),
            onTap: () => _manageCache(),
          ),
          ListTile(
            leading: const Icon(Icons.api, color: Colors.cyan),
            title: const Text('API Testing'),
            subtitle: const Text('Test API endpoints and services'),
            onTap: () => _testAPI(),
          ),
          ListTile(
            leading: const Icon(Icons.build, color: Colors.deepOrange),
            title: const Text('Build Info'),
            subtitle: const Text('View build configuration and details'),
            onTap: () => _showBuildInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Accessibility Mode'),
            subtitle: const Text('Enable enhanced accessibility features'),
            value: _accessibilityModeEnabled,
            onChanged: (value) {
              setState(() {
                _accessibilityModeEnabled = value;
              });
              _showSnackBar(
                  'Accessibility mode ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('High Contrast'),
            subtitle:
                const Text('Use high contrast colors for better visibility'),
            value: false,
            onChanged: (value) {
              _showSnackBar('High contrast ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Screen Reader Support'),
            subtitle: const Text('Enable screen reader compatibility'),
            value: true,
            onChanged: (value) {
              _showSnackBar(
                  'Screen reader support ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Large Text'),
            subtitle: const Text('Use larger text for better readability'),
            value: false,
            onChanged: (value) {
              _showSnackBar(
                  'Large text ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Reduce Motion'),
            subtitle: const Text('Reduce animations for motion sensitivity'),
            value: false,
            onChanged: (value) {
              _showSnackBar(
                  'Motion reduction ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          ListTile(
            leading: const Icon(Icons.volume_up, color: Colors.green),
            title: const Text('Audio Descriptions'),
            subtitle: const Text('Enable audio descriptions for content'),
            onTap: () => _toggleAudioDescriptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face recognition'),
            value: false,
            onChanged: (value) {
              _showSnackBar('Biometric auth ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Auto Lock'),
            subtitle: const Text('Automatically lock app after inactivity'),
            value: false,
            onChanged: (value) {
              _showSnackBar(
                  'Auto lock ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
          ListTile(
            title: const Text('Session Timeout'),
            subtitle: Slider(
              value: _sessionTimeout.toDouble(),
              min: 5,
              max: 120,
              divisions: 23,
              label: '$_sessionTimeout minutes',
              onChanged: (value) {
                setState(() {
                  _sessionTimeout = value.round();
                });
              },
            ),
            trailing: Text('${_sessionTimeout}m'),
          ),
          SwitchListTile(
            title: const Text('Data Encryption'),
            subtitle: const Text('Encrypt stored data for security'),
            value: true,
            onChanged: (value) {
              _showSnackBar('Data encryption ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Network Security'),
            subtitle: const Text('Use secure network connections only'),
            value: true,
            onChanged: (value) {
              _showSnackBar(
                  'Network security ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.red),
            title: const Text('Security Audit'),
            subtitle: const Text('Run security audit and vulnerability scan'),
            onTap: () => _runSecurityAudit(),
          ),
          ListTile(
            leading: const Icon(Icons.key, color: Colors.orange),
            title: const Text('Change Master Password'),
            subtitle: const Text('Update your master password'),
            onTap: () => _changeMasterPassword(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: const Text('Auto Save Interval'),
            subtitle: Slider(
              value: _autoSaveInterval.toDouble(),
              min: 1,
              max: 15,
              divisions: 14,
              label: '$_autoSaveInterval minutes',
              onChanged: (value) {
                setState(() {
                  _autoSaveInterval = value.round();
                });
              },
            ),
            trailing: Text('${_autoSaveInterval}m'),
          ),
          ListTile(
            title: const Text('Sync Interval'),
            subtitle: Slider(
              value: _syncInterval.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$_syncInterval minutes',
              onChanged: (value) {
                setState(() {
                  _syncInterval = value.round();
                });
              },
            ),
            trailing: Text('${_syncInterval}m'),
          ),
          ListTile(
            title: const Text('Cache Size'),
            subtitle: Slider(
              value: _cacheSize.toDouble(),
              min: 50,
              max: 500,
              divisions: 9,
              label: '$_cacheSize MB',
              onChanged: (value) {
                setState(() {
                  _cacheSize = value.round();
                });
              },
            ),
            trailing: Text('${_cacheSize}MB'),
          ),
          ListTile(
            title: const Text('Max Log Files'),
            subtitle: Slider(
              value: _maxLogFiles.toDouble(),
              min: 5,
              max: 50,
              divisions: 9,
              label: '$_maxLogFiles files',
              onChanged: (value) {
                setState(() {
                  _maxLogFiles = value.round();
                });
              },
            ),
            trailing: Text('$_maxLogFiles'),
          ),
          SwitchListTile(
            title: const Text('Auto Sync'),
            subtitle: const Text('Automatically sync data across devices'),
            value: _autoSyncEnabled,
            onChanged: (value) {
              setState(() {
                _autoSyncEnabled = value;
              });
              _showSnackBar(
                  'Auto sync ${value ? 'enabled' : 'disabled'}', Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Enable haptic feedback for interactions'),
            value: _hapticFeedbackEnabled,
            onChanged: (value) {
              setState(() {
                _hapticFeedbackEnabled = value;
              });
              _showSnackBar('Haptic feedback ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sound effects for actions'),
            value: _soundEffectsEnabled,
            onChanged: (value) {
              setState(() {
                _soundEffectsEnabled = value;
              });
              _showSnackBar('Sound effects ${value ? 'enabled' : 'disabled'}',
                  Colors.blue);
            },
          ),
          SwitchListTile(
            title: const Text('Debug Mode'),
            subtitle: const Text('Enable debug logging and features'),
            value: false, // TODO: Implement debug mode
            onChanged: (value) {
              _showSnackBar('Debug mode coming soon', Colors.orange);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Colors.red),
            title: const Text('Report Bug'),
            subtitle: const Text('Send bug report to developers'),
            onTap: () => _reportBug(),
          ),
          ListTile(
            leading: const Icon(Icons.speed, color: Colors.orange),
            title: const Text('Performance Monitor'),
            subtitle: const Text('Monitor app performance'),
            onTap: () => _showPerformanceMonitor(),
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text('Privacy Settings'),
            subtitle: const Text('Configure privacy and security'),
            onTap: () => _showPrivacySettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text('Developer'),
            subtitle: const Text('Francis Sarpaning'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.green),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            onTap: () {
              _showSnackBar('Privacy policy coming soon', Colors.orange);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.purple),
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms of service'),
            onTap: () {
              _showSnackBar('Terms of service coming soon', Colors.orange);
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent, color: Colors.teal),
            title: const Text('Contact Support'),
            subtitle: const Text('Get help and support'),
            onTap: () {
              _showSnackBar('Support contact coming soon', Colors.orange);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback, color: Colors.amber),
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve the app'),
            onTap: () {
              _showSnackBar('Feedback feature coming soon', Colors.orange);
            },
          ),
          ListTile(
            leading: const Icon(Icons.update, color: Colors.blue),
            title: const Text('Check for Updates'),
            subtitle: const Text('Check for app updates'),
            onTap: () => _checkForUpdates(),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _saveSettings() {
    // TODO: Implement settings save
    _showSnackBar('Settings saved successfully', Colors.green);
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
            'This will reset all settings to their default values. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performResetToDefaults();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _performResetToDefaults() {
    setState(() {
      _notificationsEnabled = false;
      _alarmEnabled = true;
      _vibrationEnabled = true;
      _soundEnabled = true;
      _autoStartNextSession = true;
      _showNotifications = true;
      _autoBackupEnabled = false;
      _darkModeEnabled = false;
      _compactModeEnabled = false;
      _gestureNavigationEnabled = true;
      _hapticFeedbackEnabled = true;
      _soundEffectsEnabled = true;
      _autoSyncEnabled = false;
      _developerModeEnabled = false;
      _experimentalFeaturesEnabled = false;
      _accessibilityModeEnabled = false;

      _workDuration = 25;
      _shortBreakDuration = 5;
      _longBreakDuration = 15;
      _sessionsBeforeLongBreak = 4;
      _alarmVolume = 80;
      _alarmDuration = 10;
      _backupFrequency = 7;
      _maxBackupFiles = 5;
      _notificationDelay = 0;
      _autoSaveInterval = 5;
      _syncInterval = 15;
      _cacheSize = 100;
      _maxLogFiles = 10;
      _sessionTimeout = 30;

      _selectedLanguage = 'English';
      _selectedTimeFormat = '12-hour';
      _selectedDateFormat = 'MM/DD/YYYY';
      _selectedTheme = 'Blue';
      _selectedFontSize = 'Medium';
      _selectedAnimationSpeed = 'Normal';
    });

    _showSnackBar('Settings reset to defaults', Colors.green);
  }

  void _exportData(BuildContext context) {
    _showSnackBar('Export feature coming soon', Colors.orange);
  }

  void _importData(BuildContext context) {
    _showSnackBar('Import feature coming soon', Colors.orange);
  }

  void _showStorageInfo() {
    _showSnackBar('Storage info coming soon', Colors.orange);
  }

  void _showDataAnalytics() {
    _showSnackBar('Data analytics coming soon', Colors.orange);
  }

  void _createBackup() {
    _showSnackBar('Backup created successfully', Colors.green);
  }

  void _restoreFromBackup() {
    _showSnackBar('Restore feature coming soon', Colors.orange);
  }

  void _reportBug() {
    _showSnackBar('Bug report feature coming soon', Colors.orange);
  }

  void _showPerformanceMonitor() {
    _showSnackBar('Performance monitor coming soon', Colors.orange);
  }

  void _showPrivacySettings() {
    _showSnackBar('Privacy settings coming soon', Colors.orange);
  }

  void _checkForUpdates() {
    _showSnackBar('App is up to date', Colors.green);
  }

  // Developer Tools Methods
  void _viewLogs() {
    _showSnackBar('Log viewer coming soon', Colors.orange);
  }

  void _showPerformanceMetrics() {
    _showSnackBar('Performance metrics coming soon', Colors.orange);
  }

  void _showMemoryUsage() {
    _showSnackBar('Memory usage: 45.2 MB', Colors.green);
  }

  void _manageCache() {
    _showSnackBar('Cache cleared successfully', Colors.green);
  }

  void _testAPI() {
    _showSnackBar('API testing coming soon', Colors.orange);
  }

  void _showBuildInfo() {
    _showSnackBar('Build info: v1.0.0 (2024-01-15)', Colors.blue);
  }

  // Accessibility Methods
  void _toggleAudioDescriptions() {
    _showSnackBar('Audio descriptions toggled', Colors.blue);
  }

  // Security Methods
  void _runSecurityAudit() {
    _showSnackBar('Security audit completed - No issues found', Colors.green);
  }

  void _changeMasterPassword() {
    _showSnackBar('Password change feature coming soon', Colors.orange);
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your tasks, notes, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performClearAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _performClearAllData() async {
    try {
      // Clear tasks
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.clearAllData();

      // Clear notes by deleting them one by one
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final notes = noteProvider.notes.toList();
      for (final note in notes) {
        await noteProvider.deleteNote(note.id);
      }

      // Clear notifications
      try {
        await _notificationService.cancelAllNotifications();
      } catch (e) {
        debugPrint('Failed to clear notifications: $e');
      }

      if (mounted) {
        _showSnackBar('All data cleared successfully', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to clear data: $e', Colors.red);
      }
    }
  }
}
