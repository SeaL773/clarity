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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF1A1E25) : const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 20,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text('Daily Recap',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            ],
          ),
          const SizedBox(height: 18),
          // Progress ring
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: summary.completionRate,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                    color: pct >= 70
                        ? const Color(0xFF66BB6A)
                        : pct >= 40
                            ? const Color(0xFFFFB74D)
                            : theme.colorScheme.primary,
                  ),
                ),
                Text('$pct%',
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700, letterSpacing: -0.5)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('${summary.completedCount} of ${summary.totalCount} tasks completed',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ),
          const SizedBox(height: 18),
          Text(summary.summary,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          const SizedBox(height: 14),
          // Encouragement
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 2),
                Expanded(
                  child: Text(summary.encouragement,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic, height: 1.4)),
                ),
              ],
            ),
          ),
          if (summary.tomorrowFocus.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text("Tomorrow's Focus",
                style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600, letterSpacing: -0.2)),
            const SizedBox(height: 8),
            ...summary.tomorrowFocus.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4))),
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
