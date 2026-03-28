import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/task_card.dart';

class CalendarDayScreen extends StatefulWidget {
  const CalendarDayScreen({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  State<CalendarDayScreen> createState() => _CalendarDayScreenState();
}

class _CalendarDayScreenState extends State<CalendarDayScreen> {
  late final String _dateKey;

  @override
  void initState() {
    super.initState();
    _dateKey = DateFormat('yyyy-MM-dd').format(widget.date);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskProvider>().loadTasksForDate(_dateKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TaskProvider>();
    final tasks = provider.tasksForDate(_dateKey);
    final isLoading = provider.isDateLoading(_dateKey);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM d').format(widget.date),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              DateFormat('EEEE, yyyy').format(widget.date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: tasks.isNotEmpty
            ? ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onToggle: () => provider.toggleTaskForDate(_dateKey, task.id),
                    onToggleSubTask: (subId) =>
                        provider.toggleSubTaskForDate(_dateKey, task.id, subId),
                  );
                },
              )
            : Center(
                child: isLoading
                    ? CircularProgressIndicator(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      )
                    : Text(
                        'No tasks for this day',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
              ),
      ),
    );
  }
}
