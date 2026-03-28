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

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF0F4FF),
                theme.scaffoldBackgroundColor,
              ],
              stops: const [0.0, 0.35],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                // App header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.15),
                                theme.colorScheme.primary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(11),
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
                          _ActionChip(
                            icon: Icons.summarize_outlined,
                            label: 'Recap',
                            onPressed: provider.isLoading ? null : () => _showRecap(context),
                          ),
                        if (provider.tasks.isNotEmpty)
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
                ),

                // Greeting text
                if (provider.tasks.isEmpty && !provider.isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Text(
                        _getGreeting(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          letterSpacing: -0.3,
                        ),
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

                // AI Insight chip
                if (provider.insights != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(Icons.lightbulb_outline_rounded,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.7), size: 14),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(provider.insights!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                      height: 1.4)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Progress section
                if (provider.tasks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
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
                              style: theme.textTheme.labelMedium?.copyWith(
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
                                minHeight: 5,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.06),
                                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Section divider
                if (provider.tasks.isNotEmpty)
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Error
                if (provider.error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 18, color: Colors.red.shade300),
                            const SizedBox(width: 10),
                            Expanded(child: Text(provider.error!,
                                style: TextStyle(color: Colors.red.shade600, fontSize: 13))),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Loading shimmer
                if (provider.isLoading && provider.tasks.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ShimmerCard(delay: index * 150),
                        );
                      },
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                      child: Column(
                        children: [
                          // Feature hints
                          _FeatureHint(
                            icon: Icons.edit_note_rounded,
                            title: 'Brain dump your thoughts',
                            subtitle: 'Type anything — messy is fine',
                            color: const Color(0xFF5B7FBF),
                          ),
                          const SizedBox(height: 12),
                          _FeatureHint(
                            icon: Icons.auto_awesome_rounded,
                            title: 'AI organizes everything',
                            subtitle: 'Tasks, priorities, sub-steps — done',
                            color: const Color(0xFF7C5BBF),
                          ),
                          const SizedBox(height: 12),
                          _FeatureHint(
                            icon: Icons.mic_rounded,
                            title: 'Or just speak',
                            subtitle: 'Voice input works too',
                            color: const Color(0xFF5BBFA7),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening 🌙';
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
                      width: 40,
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
                                  width: 48,
                                  height: 48,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                    strokeWidth: 3,
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline_rounded, size: 40,
                                        color: Colors.red.shade200),
                                    const SizedBox(height: 12),
                                    Text('Could not generate recap',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                                  ],
                                ),
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
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(
                color: Colors.grey.shade200.withValues(alpha: _animation.value),
                width: 3.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
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
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withValues(alpha: _animation.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100.withValues(alpha: _animation.value * 0.7),
                          borderRadius: BorderRadius.circular(4),
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

// ── Feature Hint Card ──

class _FeatureHint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureHint({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          ),
        ],
      ),
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

    if (label != null) {
      return Material(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Text(label!, style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.35)),
        ),
      ),
    );
  }
}
