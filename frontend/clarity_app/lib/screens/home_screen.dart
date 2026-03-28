import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/brain_dump_input.dart';
import '../widgets/task_card.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();
    final hasTasks = provider.tasks.isNotEmpty;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFEEF2FA),
                theme.scaffoldBackgroundColor,
              ],
              stops: const [0.0, 0.4],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.auto_awesome_rounded,
                            size: 18, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 9),
                      Text('Clarity',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                      const Spacer(),
                      if (hasTasks)
                        _ActionChip(
                          icon: Icons.summarize_outlined,
                          label: 'Recap',
                          onPressed: provider.isLoading ? null : () => _showRecap(context),
                        ),
                      if (hasTasks)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: _ActionChip(
                            icon: Icons.delete_outline_rounded,
                            onPressed: () => _showClearDialog(context),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Main content ──
                Expanded(
                  child: hasTasks || provider.isLoading
                      ? _buildTaskView(context, theme, provider)
                      : _buildEmptyState(context, theme),
                ),

                // ── Bottom input bar ──
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: BrainDumpInput(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty state (Claude-style centered) ──
  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 44, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 20),
            Text(
              _getGreeting(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                letterSpacing: -0.5,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'What do you need to get done?',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Task list view ──
  Widget _buildTaskView(BuildContext context, ThemeData theme, TaskProvider provider) {
    return CustomScrollView(
      slivers: [
        // AI Insight
        if (provider.insights != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5), size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(provider.insights!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Progress pill
        if (provider.tasks.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${provider.completedCount} of ${provider.totalCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: provider.completionRate,
                        minHeight: 4,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.06),
                        color: theme.colorScheme.primary.withValues(alpha: 0.45),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade300),
                    const SizedBox(width: 8),
                    Expanded(child: Text(provider.error!,
                        style: TextStyle(color: Colors.red.shade500, fontSize: 12))),
                  ],
                ),
              ),
            ),
          ),

        // Shimmer loading
        if (provider.isLoading && provider.tasks.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverList.builder(
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _ShimmerCard(delay: index * 150),
              ),
            ),
          ),

        // Task list
        if (provider.tasks.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            sliver: SliverList.separated(
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
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showRecap(BuildContext context) async {
    final provider = context.read<TaskProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RecapSheet(provider: provider),
    );

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

// ── Recap Bottom Sheet ──

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
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: provider.isLoading && provider.summary == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text('Generating your recap...',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.35))),
                              ],
                            ),
                          )
                        : provider.summary != null
                            ? SingleChildScrollView(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                                child: SummaryCard(summary: provider.summary!),
                              )
                            : Center(
                                child: Text('Could not generate recap',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.35))),
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

// ── Shimmer Loading Card ──

class _ShimmerCard extends StatefulWidget {
  final int delay;
  const _ShimmerCard({this.delay = 0});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: Colors.grey.shade200.withValues(alpha: _animation.value),
                width: 3,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100.withValues(alpha: _animation.value),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withValues(alpha: _animation.value),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 9,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withValues(alpha: _animation.value * 0.6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Action Chip ──

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;

  const _ActionChip({required this.icon, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return Material(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 12 : 8,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              if (label != null) ...[
                const SizedBox(width: 5),
                Text(label!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
