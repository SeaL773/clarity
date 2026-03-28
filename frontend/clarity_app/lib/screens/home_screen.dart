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
              theme.brightness == Brightness.dark ? const Color(0xFF211F1B) : const Color(0xFFEEF2FA),
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
                    // Grouped action pill
                    if (hasTasks)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.grey.shade200.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PillIcon(
                              icon: _inputExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.chat_bubble_outline_rounded,
                              onPressed: () => setState(() => _inputExpanded = !_inputExpanded),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                            ),
                            _PillIcon(
                              icon: Icons.delete_outline_rounded,
                              onPressed: () => _showClearDialog(context),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── Input area (collapsible when has tasks, hidden on empty — shown inside empty state) ──
              if (hasTasks && _inputExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                  child: BrainDumpInput(
                    onCollapse: () => setState(() => _inputExpanded = false),
                  ),
                )
              else if (hasTasks)
                const SizedBox(height: 8),

              // Error toast
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
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
              const SizedBox(height: 24),
              BrainDumpInput(
                onCollapse: () {},
              ),
            ],
          ),
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
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.scrollDelta != null &&
            notification.scrollDelta! > 2 &&
            _inputExpanded) {
          setState(() => _inputExpanded = false);
        }
        return false;
      },
      child: CustomScrollView(
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
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 90),
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
      ),
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

// ── Pill icon button ──

class _PillIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PillIcon({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 19,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45)),
        ),
      ),
    );
  }
}
