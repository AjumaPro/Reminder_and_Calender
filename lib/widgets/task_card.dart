import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildPriorityIndicator(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? Colors.grey[600]
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (task.hasAlarm)
                            Icon(
                              Icons.alarm,
                              size: 16,
                              color: Colors.orange[600],
                            ),
                        ],
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy - HH:mm')
                                .format(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(task.category),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.category,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggle(),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    Color priorityColor;
    switch (task.priority) {
      case 0: // Low
        priorityColor = Colors.green;
        break;
      case 1: // Medium
        priorityColor = Colors.orange;
        break;
      case 2: // High
        priorityColor = Colors.red;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: priorityColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.green;
      case 'health':
        return Colors.red;
      case 'shopping':
        return Colors.purple;
      case 'meeting':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
