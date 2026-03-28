import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/task_provider.dart';
import '../widgets/brain_dump_input.dart';
import '../widgets/task_card.dart';
import 'calendar_day_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialCalendarView = false,
  });

  final bool initialCalendarView;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _inputExpanded = true;
  bool _showCalendar = false;
  bool _autoCollapsed = false;
  late DateTime _visibleMonth;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _showCalendar = widget.initialCalendarView;
    _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<TaskProvider>();
      provider.initializeToday();
      provider.prefetchMonth(_visibleMonth);
    });
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
    final isTodayLoading = provider.isDateLoading(provider.todayDate);

    if (!_showCalendar && hasTasks && _inputExpanded && !provider.isLoading && !_autoCollapsed) {
      _autoCollapsed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _inputExpanded = false);
        }
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
              theme.brightness == Brightness.dark
                  ? const Color(0xFF211F1B)
                  : const Color(0xFFEEF2FA),
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _showCalendar
                            ? Icons.calendar_month_rounded
                            : Icons.auto_awesome_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      _showCalendar ? 'Calendar' : 'Clarity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    if (!_showCalendar && hasTasks)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.shade200.withValues(alpha: 0.5),
                            ),
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
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.shade200,
                              ),
                              _PillIcon(
                                icon: Icons.delete_outline_rounded,
                                onPressed: () => _showClearDialog(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (provider.isTestMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Test mode active. Backend is disconnected and demo tasks are generated locally.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_showCalendar)
                if (hasTasks && _inputExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                    child: BrainDumpInput(
                      onCollapse: () => setState(() => _inputExpanded = false),
                    ),
                  )
                else if (hasTasks)
                  const SizedBox(height: 8),
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
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade500, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: _showCalendar
                    ? _buildCalendarView(context, theme, provider)
                    : hasTasks
                        ? _buildTaskList(context, theme, provider)
                        : (provider.isLoading || isTodayLoading)
                            ? _buildLoading(theme)
                            : _buildEmpty(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 40,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
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
          Text(
            'Organizing your thoughts...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

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
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: theme.colorScheme.primary.withValues(alpha: 0.45),
                        size: 15,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          provider.insights!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                            height: 1.4,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

  Widget _buildCalendarView(BuildContext context, ThemeData theme, TaskProvider provider) {
    final monthLabel = DateFormat('MMMM yyyy').format(_visibleMonth);
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingEmptyCells = firstDayOfMonth.weekday % 7;
    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final weekLabels = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF252320)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _IconChip(
                  icon: Icons.chevron_left_rounded,
                  onPressed: () => _changeMonth(-1),
                  tooltip: 'Previous month',
                ),
                Expanded(
                  child: Text(
                    monthLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _IconChip(
                  icon: Icons.chevron_right_rounded,
                  onPressed: () => _changeMonth(1),
                  tooltip: 'Next month',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: weekLabels
                .map(
                  (label) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: rowCount > 5 ? 84 : 92,
              ),
              itemCount: rowCount * 7,
              itemBuilder: (context, index) {
                if (index < leadingEmptyCells || index >= totalCells) {
                  return const SizedBox.shrink();
                }

                final dayNumber = index - leadingEmptyCells + 1;
                final date = DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);
                return _buildDateCell(context, theme, provider, date);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCell(
    BuildContext context,
    ThemeData theme,
    TaskProvider provider,
    DateTime date,
  ) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final total = provider.totalCountForDate(dateKey);
    final completed = provider.completedCountForDate(dateKey);
    final isToday = _isSameDay(date, DateTime.now());
    final isLoading = provider.isDateLoading(dateKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CalendarDayScreen(date: date),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF252320)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.45)
                  : Colors.transparent,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${date.day}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  isLoading ? '...' : '$completed/$total',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
    context.read<TaskProvider>().prefetchMonth(_visibleMonth);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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

class _PillIcon extends StatelessWidget {
  const _PillIcon({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

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
          child: Icon(
            icon,
            size: 19,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

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
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
