import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class CalendarDayScreen extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;

  const CalendarDayScreen({super.key, required this.date, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final completed = tasks.where((t) => t.completed).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isToday ? 'Today' : DateFormat('EEEE, MMMM d').format(date),
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completed / ${tasks.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 48, color: theme.colorScheme.onSurface.withValues(alpha: 0.12)),
                  const SizedBox(height: 12),
                  Text('No tasks for this day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
                ],
              ),
            )
          : Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: tasks.isEmpty ? 0 : completed / tasks.length,
                      minHeight: 4,
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.06),
                      color: theme.colorScheme.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                // Task list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 5),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onToggle: () {}, // Read-only for past days
                        onToggleSubTask: (_) {},
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
