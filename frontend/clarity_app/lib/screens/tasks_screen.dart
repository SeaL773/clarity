import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 4),
            child: Row(
              children: [
                Text('Tasks',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                const Spacer(),
                if (provider.tasks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${provider.completedCount} / ${provider.totalCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                if (provider.tasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () => _showClearDialog(context),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    ),
                  ),
              ],
            ),
          ),

          // Progress
          if (provider.tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: provider.completionRate,
                  minHeight: 4,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.06),
                  color: theme.colorScheme.primary.withValues(alpha: 0.45),
                ),
              ),
            ),

          // Task list
          Expanded(
            child: provider.tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.12)),
                        const SizedBox(height: 12),
                        Text('No tasks yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                        const SizedBox(height: 4),
                        Text('Use Clarity tab to add tasks',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                    itemCount: provider.tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];
                      return TaskCard(
                        task: task,
                        onToggle: () => provider.toggleTask(task.id),
                        onToggleSubTask: (subId) => provider.toggleSubTask(task.id, subId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear all tasks?'),
        content: const Text('This will remove all tasks for today.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().clearTasks();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
