import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/brain_dump_input.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();

    return Container(
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
            // Top input area
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
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
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Input
                  const BrainDumpInput(),
                ],
              ),
            ),

            // Loading / insights / recent tasks preview
            Expanded(
              child: provider.isLoading && provider.tasks.isEmpty
                  ? _buildLoading(theme)
                  : provider.tasks.isEmpty
                      ? _buildEmpty(theme)
                      : _buildRecentPreview(context, theme, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getGreeting(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Type or speak what\'s on your mind.\nAI will organize it for you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text('Organizing your thoughts...',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35))),
        ],
      ),
    );
  }

  Widget _buildRecentPreview(BuildContext context, ThemeData theme, TaskProvider provider) {
    final incompleteTasks = provider.tasks.where((t) => !t.completed).take(3).toList();
    final completedCount = provider.completedCount;
    final totalCount = provider.totalCount;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Insight
          if (provider.insights != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
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

          // Summary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Today',
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$completedCount / $totalCount',
                          style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: provider.completionRate,
                    minHeight: 4,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.06),
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                  ),
                ),
                if (incompleteTasks.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('Up next',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...incompleteTasks.map((task) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _priorityColor(task.priority),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(task.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text('Switch to Tasks tab to see all →',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.25))),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'urgent_important':
        return const Color(0xFFE57373);
      case 'urgent_not_important':
        return const Color(0xFFFFB74D);
      case 'important_not_urgent':
        return const Color(0xFF7BAAF7);
      default:
        return const Color(0xFFBDBDBD);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
