import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/api_service.dart';
import '../widgets/task_card.dart';
import 'calendar_day_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _api = ApiService();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Task> _selectedTasks = [];
  bool _loadingTasks = false;

  // Cache: date string → tasks
  final Map<String, List<Task>> _taskCache = {};

  @override
  void initState() {
    super.initState();
    _loadTasksForDay(_selectedDay);
    _preloadMonth(_focusedDay);
  }

  String _dateKey(DateTime day) => DateFormat('yyyy-MM-dd').format(day);

  Future<void> _loadTasksForDay(DateTime day) async {
    final key = _dateKey(day);
    if (_taskCache.containsKey(key)) {
      setState(() => _selectedTasks = _taskCache[key]!);
      return;
    }
    setState(() => _loadingTasks = true);
    try {
      final tasks = await _api.loadTasks(key);
      _taskCache[key] = tasks;
      if (_dateKey(_selectedDay) == key) {
        setState(() {
          _selectedTasks = tasks;
          _loadingTasks = false;
        });
      }
    } catch (_) {
      setState(() {
        _selectedTasks = [];
        _loadingTasks = false;
      });
    }
  }

  Future<void> _preloadMonth(DateTime month) async {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
      final key = _dateKey(d);
      if (!_taskCache.containsKey(key)) {
        try {
          final tasks = await _api.loadTasks(key);
          if (tasks.isNotEmpty) {
            _taskCache[key] = tasks;
            if (mounted) setState(() {});
          }
        } catch (_) {}
      }
    }
  }

  // Priority weights: urgent_important=3, urgent_not_important=2, important_not_urgent=1, neither=0
  static const _priorityWeight = {
    'urgent_important': 3,
    'urgent_not_important': 2,
    'important_not_urgent': 1,
    'neither': 0,
  };

  // Calculate urgency score (0.0 to 1.0) for color
  double _urgencyScore(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    double totalWeight = 0;
    double maxWeight = 0;
    for (final t in tasks) {
      final w = (_priorityWeight[t.priority] ?? 0).toDouble();
      totalWeight += w;
      maxWeight += 3; // max possible per task
    }
    return maxWeight > 0 ? totalWeight / maxWeight : 0;
  }

  // Completion rate (0.0 to 1.0)
  double _completionRate(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    return tasks.where((t) => t.completed).length / tasks.length;
  }

  // Urgency → color gradient: red(1.0) → orange(0.66) → blue(0.33) → grey(0.0)
  Color _urgencyColor(double score) {
    if (score > 0.66) return Color.lerp(const Color(0xFFFFB74D), const Color(0xFFE57373), (score - 0.66) / 0.34)!;
    if (score > 0.33) return Color.lerp(const Color(0xFF7BAAF7), const Color(0xFFFFB74D), (score - 0.33) / 0.33)!;
    if (score > 0) return Color.lerp(const Color(0xFFBDBDBD), const Color(0xFF7BAAF7), score / 0.33)!;
    return const Color(0xFFBDBDBD);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<TaskProvider>();

    // Sync today's tasks from provider into cache
    final todayKey = _dateKey(DateTime.now());
    if (provider.tasks.isNotEmpty) {
      _taskCache[todayKey] = provider.tasks;
      if (_dateKey(_selectedDay) == todayKey) {
        _selectedTasks = provider.tasks;
      }
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 4),
            child: Text('Calendar',
                style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          ),

          // Calendar
          TableCalendar(
            firstDay: DateTime(2025, 1, 1),
            lastDay: DateTime(2027, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              _loadTasksForDay(selected);
            },
            onPageChanged: (focused) {
              _focusedDay = focused;
              _preloadMonth(focused);
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: theme.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600),
              leftChevronIcon: Icon(Icons.chevron_left_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              rightChevronIcon: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
              weekendStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13),
              weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
              cellMargin: const EdgeInsets.all(4),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, _) {
                final key = _dateKey(day);
                final tasks = _taskCache[key];
                if (tasks == null || tasks.isEmpty) return null;

                final urgency = _urgencyScore(tasks);
                final completion = _completionRate(tasks);
                final color = _urgencyColor(urgency);

                return Positioned(
                  bottom: 4,
                  child: SizedBox(
                    width: 22,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1.5),
                      child: LinearProgressIndicator(
                        value: completion,
                        backgroundColor: color.withValues(alpha: 0.2),
                        color: color,
                        minHeight: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // Selected day header
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
            child: Row(
              children: [
                Text(
                  isSameDay(_selectedDay, DateTime.now())
                      ? 'Today'
                      : DateFormat('EEEE, MMM d').format(_selectedDay),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (_selectedTasks.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CalendarDayScreen(date: _selectedDay, tasks: _selectedTasks),
                      ));
                    },
                    child: Text('View all →',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6))),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedTasks.where((t) => t.completed).length} / ${_selectedTasks.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Task list for selected day
          Expanded(
            child: _loadingTasks
                ? Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  )
                : _selectedTasks.isEmpty
                    ? Center(
                        child: Text('No tasks',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.25))),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                        itemCount: _selectedTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 5),
                        itemBuilder: (context, index) {
                          final task = _selectedTasks[index];
                          return TaskCard(
                            task: task,
                            onToggle: () {
                              // Only allow toggling today's tasks
                              if (isSameDay(_selectedDay, DateTime.now())) {
                                provider.toggleTask(task.id);
                              }
                            },
                            onToggleSubTask: (subId) {
                              if (isSameDay(_selectedDay, DateTime.now())) {
                                provider.toggleSubTask(task.id, subId);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
