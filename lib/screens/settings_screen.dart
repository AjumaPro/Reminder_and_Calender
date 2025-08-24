import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildDataSection(context),
          const Divider(),
          _buildNotificationSection(context),
          const Divider(),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Data Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Export Data'),
          subtitle: const Text('Backup your tasks and notes'),
          onTap: () => _exportData(context),
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Import Data'),
          subtitle: const Text('Restore from backup'),
          onTap: () => _importData(context),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever),
          title: const Text('Clear All Data'),
          subtitle: const Text('Delete all tasks and notes'),
          onTap: () => _clearAllData(context),
        ),
      ],
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Settings'),
          subtitle: const Text('Configure alarm sounds and vibration'),
          onTap: () => _showNotificationSettings(context),
        ),
        ListTile(
          leading: const Icon(Icons.alarm),
          title: const Text('Test Alarm'),
          subtitle: const Text('Test the alarm sound'),
          onTap: () => _testAlarm(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('App Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Privacy Policy'),
          onTap: () => _showPrivacyPolicy(context),
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          onTap: () => _showHelp(context),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final taskProvider = context.read<TaskProvider>();
      final data = await taskProvider.exportData();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/calendar_reminder_backup.json');
      await file.writeAsString(jsonEncode(data));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to: ${file.path}'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content:
            const Text('This will replace all existing data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/calendar_reminder_backup.json');

        if (await file.exists()) {
          final jsonString = await file.readAsString();
          final data = jsonDecode(jsonString) as Map<String, dynamic>;

          final taskProvider = context.read<TaskProvider>();
          await taskProvider.importData(data);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data imported successfully!')),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No backup file found'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'This will permanently delete all tasks and notes. This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final taskProvider = context.read<TaskProvider>();
        await taskProvider.clearAllData();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear data: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Notification settings will be available in a future update.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _testAlarm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Alarm'),
        content:
            const Text('This feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This app stores all your data locally on your device. No data is sent to external servers or shared with third parties. Your privacy is our priority.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use the app:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Tap the + button to add tasks'),
              Text('• Set alarms to get notified'),
              Text('• Create notes and attach them to tasks'),
              Text('• Use the calendar to view your schedule'),
              Text('• Export your data for backup'),
            ],
          ),
        ),
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
