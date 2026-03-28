import 'package:flutter/material.dart';
import '../models/task.dart';

class SummaryCard extends StatelessWidget {
  final DailySummary summary;

  const SummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (summary.completionRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 24),
              const SizedBox(width: 8),
              Text('Daily Recap',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: summary.completionRate,
                    strokeWidth: 8,
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    color: pct >= 70 ? Colors.green : pct >= 40 ? Colors.orange : theme.colorScheme.primary,
                  ),
                ),
                Text('$pct%',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('${summary.completedCount} of ${summary.totalCount} tasks completed',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
          const SizedBox(height: 16),
          Text(summary.summary, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💙', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(summary.encouragement,
                      style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
          if (summary.tomorrowFocus.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("Tomorrow's Focus:",
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...summary.tomorrowFocus.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward_rounded, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
