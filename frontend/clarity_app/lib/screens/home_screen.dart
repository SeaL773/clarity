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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar — minimal, clean
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          size: 20, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 10),
                    Text('Clarity',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                    const Spacer(),
                    if (provider.tasks.isNotEmpty)
                      _ActionButton(
                        icon: Icons.summarize_outlined,
                        label: 'Recap',
                        onPressed: provider.isLoading ? null : () => _showRecap(context),
                      ),
                    if (provider.tasks.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: IconButton(
                          onPressed: () => _showClearDialog(context),
                          icon: Icon(Icons.delete_outline_rounded,
                              size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                          tooltip: 'Clear all',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Brain dump input
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: BrainDumpInput(),
              ),
            ),

            // AI Insight
            if (provider.insights != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(provider.insights!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Progress bar
            if (provider.tasks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                  child: Row(
                    children: [
                      Text('${provider.completedCount} of ${provider.totalCount} done',
                          style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary.withValues(alpha: 0.8))),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: provider.completionRate,
                            minHeight: 5,
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error
            if (provider.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, size: 18, color: Colors.red.shade400),
                        const SizedBox(width: 10),
                        Expanded(child: Text(provider.error!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                      ],
                    ),
                  ),
                ),
              ),

            // Task list
            if (provider.tasks.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: provider.tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
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

            // Empty state
            if (provider.tasks.isEmpty && !provider.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology_outlined, size: 56,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.12)),
                      const SizedBox(height: 16),
                      Text("What's on your mind?",
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('Type or speak — AI handles the rest',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _showRecap(BuildContext context) async {
    final provider = context.read<TaskProvider>();

    // Show loading sheet first
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RecapSheet(provider: provider),
    );

    // Fetch summary
    await provider.getDailySummary();
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

class _RecapSheet extends StatelessWidget {
  final TaskProvider provider;

  const _RecapSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: provider.isLoading && provider.summary == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: theme.colorScheme.primary,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 16),
                                Text('Generating your recap...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                              ],
                            ),
                          )
                        : provider.summary != null
                            ? SingleChildScrollView(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                                child: SummaryCard(summary: provider.summary!),
                              )
                            : Center(
                                child: Text('Could not generate recap',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
    );
  }
}
