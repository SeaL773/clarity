import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/summary_card.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

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
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
            child: Row(
              children: [
                Text('Daily Recap',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                const Spacer(),
                if (provider.tasks.isNotEmpty && !provider.isLoading)
                  GestureDetector(
                    onTap: provider.getDailySummary,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded, size: 14, color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text('Regenerate',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: provider.summary != null
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: SummaryCard(summary: provider.summary!),
                  )
                : provider.isLoading
                    ? Center(
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
                            Text('Generating recap...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35))),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insights_rounded,
                                size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.12)),
                            const SizedBox(height: 14),
                            Text('No recap yet',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                            const SizedBox(height: 6),
                            Text('Complete some tasks first',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
                            const SizedBox(height: 20),
                            if (provider.tasks.isNotEmpty)
                              FilledButton.icon(
                                onPressed: provider.getDailySummary,
                                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                label: const Text('Generate Recap'),
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
