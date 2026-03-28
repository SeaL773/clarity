import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/brain_dump_input.dart';
import '../widgets/task_card.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 28),
            const SizedBox(width: 8),
            Text('Clarity',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (provider.tasks.isNotEmpty)
            TextButton.icon(
              onPressed: provider.isLoading ? null : provider.getDailySummary,
              icon: const Icon(Icons.summarize_rounded, size: 20),
              label: const Text('Recap'),
            ),
          if (provider.tasks.isNotEmpty)
            IconButton(
              onPressed: () => _showClearDialog(context),
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: BrainDumpInput(),
              ),
            ),
            if (provider.insights != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: theme.colorScheme.tertiary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(provider.insights!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (provider.tasks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Text('${provider.completedCount}/${provider.totalCount} done',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: provider.completionRate,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      if (provider.totalEstimatedHours > 0)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text('~${provider.totalEstimatedHours.toStringAsFixed(1)}h',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        ),
                    ],
                  ),
                ),
              ),
            if (provider.summary != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SummaryCard(summary: provider.summary!),
                ),
              ),
            if (provider.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(provider.error!, style: TextStyle(color: Colors.red.shade700)),
                  ),
                ),
              ),
            if (provider.tasks.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: provider.tasks.length,
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
            if (provider.tasks.isEmpty && !provider.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology_outlined, size: 64,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      Text('Brain dump your thoughts above',
                          style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                      const SizedBox(height: 4),
                      Text('AI will organize them into tasks',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                    ],
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
