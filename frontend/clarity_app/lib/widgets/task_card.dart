import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final Function(String subTaskId) onToggleSubTask;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onToggleSubTask,
  });

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'urgent_important':
        return Colors.red.shade200;
      case 'important_not_urgent':
        return Colors.blue.shade200;
      case 'urgent_not_important':
        return Colors.orange.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  IconData _priorityIcon(String? priority) {
    switch (priority) {
      case 'urgent_important':
        return Icons.priority_high_rounded;
      case 'important_not_urgent':
        return Icons.schedule_rounded;
      case 'urgent_not_important':
        return Icons.flash_on_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: task.completed
            ? theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.5)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.completed
              ? theme.colorScheme.outline.withValues(alpha: 0.1)
              : _priorityColor(task.priority),
          width: 2,
        ),
        boxShadow: task.completed
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Checkbox(
              value: task.completed,
              onChanged: (_) => onToggle(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: task.completed ? TextDecoration.lineThrough : null,
                color: task.completed
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: task.description != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      task.description!,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  )
                : null,
            trailing: task.priority != null
                ? Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_priorityIcon(task.priority), size: 16),
                  )
                : null,
          ),
          if (task.subTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48, right: 16, bottom: 12),
              child: Column(
                children: task.subTasks.map((sub) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: sub.completed,
                            onChanged: (_) => onToggleSubTask(sub.id),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.title,
                            style: TextStyle(
                              fontSize: 14,
                              decoration: sub.completed ? TextDecoration.lineThrough : null,
                              color: sub.completed
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
