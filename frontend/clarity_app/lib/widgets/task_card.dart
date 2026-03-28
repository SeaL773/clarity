import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/task_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = task.completed
        ? TaskColors.completedAccent(isDark)
        : TaskColors.priorityAccent(task.priority);
    final cardBg = task.completed
        ? (isDark ? const Color(0xFF1E1C18) : const Color(0xFFFAFAFA))
        : (isDark ? const Color(0xFF252320) : Colors.white);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: accent, width: 3.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main task row
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Transform.scale(
                    scale: 1.1,
                    child: Checkbox(
                      value: task.completed,
                      onChanged: (_) => onToggle(),
                      shape: const CircleBorder(),
                      activeColor: accent,
                      side: BorderSide(color: accent, width: 1.8),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                            color: task.completed
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (task.description != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            task.description!,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: task.completed
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sub-tasks
          if (task.subTasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 14, bottom: 10),
              child: Column(
                children: task.subTasks.map((sub) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: sub.completed,
                            onChanged: (_) => onToggleSubTask(sub.id),
                            shape: const CircleBorder(),
                            activeColor: TaskColors.subTaskCompletedAccent(isDark),
                            side: BorderSide(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                              width: 1.3,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.4,
                              decoration: sub.completed ? TextDecoration.lineThrough : null,
                              color: sub.completed
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.25)
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
