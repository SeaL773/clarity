import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/brain_dump_input.dart';
import '../widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _inputExpanded = true;
  bool _autoCollapsed = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
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

    // Auto-collapse input once after first tasks load
    if (hasTasks && _inputExpanded && !provider.isLoading && !_autoCollapsed) {
      _autoCollapsed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _inputExpanded = false);
      });
    }

    return FadeTransition(
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
            stops: const [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                child: Row(
                  children: [
                    // App icon + name (always visible)
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
                    // Chat button (when input collapsed)
                    if (!_inputExpanded && hasTasks)
                      _IconChip(
                        icon: Icons.chat_bubble_outline_rounded,
                        onPressed: () => setState(() => _inputExpanded = true),
                        tooltip: 'Add tasks',
                      ),
                    // Clear button
                    if (hasTasks)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: _IconChip(
                          icon: Icons.delete_outline_rounded,
                          onPressed: () => _showClearDialog(context),
                          tooltip: 'Clear all',
                        ),
                      ),
                  ],
                ),
              ),

              // ── Input area (expandable) ──
              AnimatedCrossFade(
                firstChild: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                  child: BrainDumpInput(
                    onCollapse: () => setState(() => _inputExpanded = false),
                  ),
                ),
                secondChild: const SizedBox(height: 8),
                crossFadeState: _inputExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300),
              ),

              // ── Main content ──
              Expanded(
                child: hasTasks
                    ? _buildTaskList(context, theme, provider)
                    : provider.isLoading
                        ? _buildLoading(theme)
                        : _buildEmpty(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty state ──
  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded,
                size: 40, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 18),
            Text(
              _getGreeting(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Type or speak what\'s on your mind.\nAI will organize it for you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading state ──
  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 14),
          Text('Organizing your thoughts...',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  // ── Task list ──
  Widget _buildTaskList(BuildContext context, ThemeData theme, TaskProvider provider) {
    return CustomScrollView(
      slivers: [
        // Insight
        if (provider.insights != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        color: theme.colorScheme.primary.withValues(alpha: 0.45), size: 15),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(provider.insights!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                              height: 1.4,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Progress
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.completedCount} / ${provider.totalCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: provider.completionRate,
                      minHeight: 3.5,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 15, color: Colors.red.shade300),
                    const SizedBox(width: 8),
                    Expanded(child: Text(provider.error!,
                        style: TextStyle(color: Colors.red.shade500, fontSize: 12))),
                  ],
                ),
              ),
            ),
          ),

        // Tasks
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 20),
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
              setState(() => _inputExpanded = true);
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ── Icon chip button ──

class _IconChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const _IconChip({required this.icon, this.onPressed, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          ),
        ),
      ),
    );
  }
}
