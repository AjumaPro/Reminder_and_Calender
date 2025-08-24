import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../screens/task_editor_screen.dart';

class AddTaskFAB extends StatelessWidget {
  const AddTaskFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        final taskProvider = context.read<TaskProvider>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskEditorScreen(
              initialDate: taskProvider.selectedDate,
            ),
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Task'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
    );
  }
}
