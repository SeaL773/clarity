import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../services/api_service.dart';

enum AppMode { user, test }

class TaskProvider extends ChangeNotifier {
  TaskProvider();

  final ApiService _api = ApiService();
  final Map<String, List<Task>> _taskCache = {};
  final Set<String> _loadingDates = {};

  bool _isLoading = false;
  String? _error;
  String? _insights;
  double _totalEstimatedHours = 0;
  DailySummary? _summary;
  AppMode _mode = AppMode.user;

  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  static const _priorityOrder = {
    'urgent_important': 0,
    'urgent_not_important': 1,
    'important_not_urgent': 2,
    'neither': 3,
  };

  static const _priorities = [
    'urgent_important',
    'urgent_not_important',
    'important_not_urgent',
    'neither',
  ];

  static const _taskTemplates = [
    _MockTaskTemplate(
      title: 'Reply to important emails',
      description: 'Clear the urgent messages first.',
      priority: 'urgent_important',
      estimatedMinutes: 35,
      subTasks: ['Inbox triage', 'Draft replies'],
    ),
    _MockTaskTemplate(
      title: 'Prepare tomorrow plan',
      description: 'Outline the next high-impact steps.',
      priority: 'important_not_urgent',
      estimatedMinutes: 25,
      subTasks: ['Pick top 3 tasks', 'Block calendar time'],
    ),
    _MockTaskTemplate(
      title: 'Review project notes',
      description: 'Turn loose notes into clear action items.',
      priority: 'important_not_urgent',
      estimatedMinutes: 40,
      subTasks: ['Read notes', 'Extract action items'],
    ),
    _MockTaskTemplate(
      title: 'Book follow-up appointment',
      description: 'Handle the admin task before it slips.',
      priority: 'urgent_not_important',
      estimatedMinutes: 15,
      subTasks: ['Find available slots'],
    ),
    _MockTaskTemplate(
      title: 'Refactor dashboard UI',
      description: 'Tighten the layout and remove duplication.',
      priority: 'urgent_important',
      estimatedMinutes: 60,
      subTasks: ['Simplify widgets', 'Check responsive states'],
    ),
    _MockTaskTemplate(
      title: 'Do a quick desk reset',
      description: 'Small cleanup to reduce friction later.',
      priority: 'neither',
      estimatedMinutes: 10,
      subTasks: [],
    ),
    _MockTaskTemplate(
      title: 'Update expense log',
      description: 'Capture the latest receipts while they are fresh.',
      priority: 'urgent_not_important',
      estimatedMinutes: 20,
      subTasks: ['Upload receipts', 'Tag categories'],
    ),
    _MockTaskTemplate(
      title: 'Finish reading research article',
      description: 'Focus on the sections relevant to the prototype.',
      priority: 'important_not_urgent',
      estimatedMinutes: 45,
      subTasks: ['Read methods', 'Write two takeaways'],
    ),
  ];

  List<Task> get tasks => _tasksForDate(_selectedDate);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get insights => _insights;
  double get totalEstimatedHours => _totalEstimatedHours;
  DailySummary? get summary => _summary;
  String get selectedDate => _selectedDate;
  AppMode get mode => _mode;
  bool get isTestMode => _mode == AppMode.test;

  int get completedCount => tasks.where((t) => t.completed).length;
  int get totalCount => tasks.length;
  double get completionRate => tasks.isEmpty ? 0 : completedCount / totalCount;

  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> initializeToday() async {
    _selectedDate = todayDate;
    if (isTestMode) {
      _taskCache[todayDate] = [];
      notifyListeners();
      return;
    }
    await loadTasksForDate(todayDate);
  }

  Future<void> setMode(AppMode mode) async {
    if (_mode == mode) return;

    _mode = mode;
    _summary = null;
    _error = null;
    _selectedDate = todayDate;
    _taskCache.clear();
    _loadingDates.clear();

    if (isTestMode) {
      _seedMockMonth(DateTime.now());
      _taskCache[todayDate] = [];
      _insights = 'Test mode is active. Tasks and recap use local demo data only.';
      _totalEstimatedHours = 0;
      notifyListeners();
      return;
    }

    _insights = null;
    _totalEstimatedHours = 0;
    notifyListeners();
    await initializeToday();
  }

  List<Task> tasksForDate(String date) => List.unmodifiable(_tasksForDate(date));

  bool isDateLoading(String date) => _loadingDates.contains(date);

  int completedCountForDate(String date) =>
      _tasksForDate(date).where((task) => task.completed).length;

  int totalCountForDate(String date) => _tasksForDate(date).length;

  Future<void> loadTasksForDate(String date, {bool force = false}) async {
    if (isTestMode) {
      _ensureMockDate(date, force: force);
      notifyListeners();
      return;
    }

    if (!force && (_taskCache.containsKey(date) || _loadingDates.contains(date))) {
      return;
    }

    _loadingDates.add(date);
    notifyListeners();

    try {
      final loadedTasks = await _api.loadTasks(date);
      _taskCache[date] = loadedTasks;
      _sortTasksForDate(date);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingDates.remove(date);
      notifyListeners();
    }
  }

  Future<void> prefetchMonth(DateTime month) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    if (isTestMode) {
      for (var day = firstDay.day; day <= lastDay.day; day++) {
        final date = _formatDate(DateTime(month.year, month.month, day));
        _ensureMockDate(date);
      }
      notifyListeners();
      return;
    }

    for (var day = firstDay.day; day <= lastDay.day; day++) {
      final date = _formatDate(DateTime(month.year, month.month, day));
      await loadTasksForDate(date);
    }
  }

  Future<void> processBrainDump(String text) async {
    if (isTestMode) {
      _addMockTasksFromInput(text);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.process(text);
      final newTasks = result.tasks;

      if (result.suggestedOrder.isNotEmpty) {
        final orderMap = <String, int>{};
        for (var i = 0; i < result.suggestedOrder.length; i++) {
          orderMap[result.suggestedOrder[i]] = i;
        }
        newTasks.sort((a, b) {
          final aIndex = orderMap[a.id] ?? 999;
          final bIndex = orderMap[b.id] ?? 999;
          return aIndex.compareTo(bIndex);
        });
      }

      final currentTasks = List<Task>.from(_tasksForDate(todayDate));
      currentTasks.addAll(newTasks);
      _taskCache[todayDate] = currentTasks;
      _selectedDate = todayDate;
      _sortTasksForDate(todayDate);
      _api.saveTasks(todayDate, currentTasks).catchError((_) {});
      _insights = result.insights;
      _totalEstimatedHours += result.totalEstimatedHours;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTask(String taskId) {
    toggleTaskForDate(_selectedDate, taskId);
  }

  void toggleTaskForDate(String date, String taskId) {
    final tasks = _tasksForDate(date);
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) return;

    final newState = !tasks[index].completed;
    tasks[index] = tasks[index].copyWith(completed: newState);

    for (var i = 0; i < tasks[index].subTasks.length; i++) {
      tasks[index].subTasks[i] = tasks[index].subTasks[i].copyWith(
        completed: newState,
      );
    }

    _sortTasksForDate(date);
    notifyListeners();
    if (!isTestMode) {
      _api.saveTasks(date, tasks).catchError((_) {});
    }
  }

  void toggleSubTask(String parentId, String subTaskId) {
    toggleSubTaskForDate(_selectedDate, parentId, subTaskId);
  }

  void toggleSubTaskForDate(String date, String parentId, String subTaskId) {
    final tasks = _tasksForDate(date);
    final parentIndex = tasks.indexWhere((task) => task.id == parentId);
    if (parentIndex == -1) return;

    final subIndex = tasks[parentIndex].subTasks.indexWhere(
      (task) => task.id == subTaskId,
    );
    if (subIndex == -1) return;

    final subTask = tasks[parentIndex].subTasks[subIndex];
    tasks[parentIndex].subTasks[subIndex] = subTask.copyWith(
      completed: !subTask.completed,
    );

    final allDone = tasks[parentIndex].subTasks.every((task) => task.completed);
    if (allDone && !tasks[parentIndex].completed) {
      tasks[parentIndex] = tasks[parentIndex].copyWith(completed: true);
    }
    if (!allDone && tasks[parentIndex].completed) {
      tasks[parentIndex] = tasks[parentIndex].copyWith(completed: false);
    }

    _sortTasksForDate(date);
    notifyListeners();
    if (!isTestMode) {
      _api.saveTasks(date, tasks).catchError((_) {});
    }
  }

  Future<void> getDailySummary() async {
    if (isTestMode) {
      _summary = _buildMockSummary(tasks);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _api.summarize(tasks, todayDate);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearTasks() {
    clearTasksForDate(_selectedDate);
  }

  void clearTasksForDate(String date) {
    _taskCache[date] = [];
    _summary = null;
    _insights = isTestMode
        ? 'Test mode is active. Tasks and recap use local demo data only.'
        : null;
    _error = null;
    notifyListeners();
    if (!isTestMode) {
      _api.saveTasks(date, const []).catchError((_) {});
    }
  }

  List<Task> _tasksForDate(String date) => _taskCache[date] ?? [];

  void _sortTasksForDate(String date) {
    _tasksForDate(date).sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }

      final aPriority = _priorityOrder[a.priority] ?? 3;
      final bPriority = _priorityOrder[b.priority] ?? 3;
      return aPriority.compareTo(bPriority);
    });
  }

  void _seedMockMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    for (var day = firstDay.day; day <= lastDay.day; day++) {
      final date = DateTime(month.year, month.month, day);
      final dateKey = _formatDate(date);
      if (dateKey == todayDate) {
        _taskCache[dateKey] = [];
        continue;
      }
      _ensureMockDate(dateKey, force: true);
    }
  }

  void _ensureMockDate(String date, {bool force = false}) {
    if (!force && _taskCache.containsKey(date)) {
      return;
    }

    final parsed = DateTime.parse(date);
    _taskCache[date] = _buildMockTasksForDate(parsed);
    _sortTasksForDate(date);
  }

  List<Task> _buildMockTasksForDate(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    final taskCount = date.day % 5 == 0 ? 0 : 2 + random.nextInt(3);

    if (taskCount == 0) {
      return [];
    }

    final tasks = <Task>[];
    for (var i = 0; i < taskCount; i++) {
      final template = _taskTemplates[(date.day + i) % _taskTemplates.length];
      final subTasks = <Task>[];

      for (var j = 0; j < template.subTasks.length; j++) {
        final subCompleted = random.nextBool() && date.isBefore(DateTime.now());
        subTasks.add(
          Task(
            id: 'mock-$seed-$i-sub-$j',
            title: template.subTasks[j],
            completed: subCompleted,
          ),
        );
      }

      final completed = subTasks.isNotEmpty
          ? subTasks.every((task) => task.completed)
          : random.nextInt(10) < (date.isBefore(DateTime.now()) ? 5 : 2);

      tasks.add(
        Task(
          id: 'mock-$seed-$i',
          title: template.title,
          description: template.description,
          priority: template.priority,
          estimatedMinutes: template.estimatedMinutes,
          subTasks: subTasks,
          completed: completed,
        ),
      );
    }

    return tasks;
  }

  void _addMockTasksFromInput(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) return;

    final currentTasks = List<Task>.from(_tasksForDate(todayDate));
    final parts = normalized
        .split(RegExp(r'[\n,;]+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    final inputChunks = parts.isEmpty ? [normalized] : parts;
    for (var i = 0; i < inputChunks.length; i++) {
      final title = inputChunks[i];
      final priority = _priorities[i % _priorities.length];
      currentTasks.add(
        Task(
          id: 'manual-${DateTime.now().microsecondsSinceEpoch}-$i',
          title: title[0].toUpperCase() + title.substring(1),
          description: 'Generated locally in test mode.',
          priority: priority,
          estimatedMinutes: 15 + (i * 10),
          completed: false,
          subTasks: [
            Task(
              id: 'manual-sub-${DateTime.now().microsecondsSinceEpoch}-$i-0',
              title: 'Break this into the first concrete step',
              completed: false,
            ),
          ],
        ),
      );
    }

    _taskCache[todayDate] = currentTasks;
    _selectedDate = todayDate;
    _sortTasksForDate(todayDate);
    _insights = 'Test mode generated local sample tasks from your input.';
    _totalEstimatedHours = currentTasks.fold<double>(
      0,
      (sum, task) => sum + ((task.estimatedMinutes ?? 0) / 60),
    );
  }

  DailySummary _buildMockSummary(List<Task> taskList) {
    final total = taskList.length;
    final completed = taskList.where((task) => task.completed).length;
    final rate = total == 0 ? 0.0 : completed / total;

    return DailySummary(
      summary: total == 0
          ? 'Test mode is on. Add a few demo tasks from the home screen to see how recap cards render.'
          : 'This local recap is generated on-device so you can validate the recap UI without the backend.',
      completedCount: completed,
      totalCount: total,
      completionRate: rate,
      encouragement: total == 0
          ? 'Start with one small task card. The goal here is UI validation, not realism.'
          : rate >= 0.6
              ? 'You have enough completed state here to validate the success path.'
              : 'You still have several incomplete cards, which is useful for checking mixed-state layouts.',
      tomorrowFocus: total == 0
          ? ['Create sample tasks', 'Open calendar view', 'Check recap styling']
          : taskList
              .where((task) => !task.completed)
              .take(3)
              .map((task) => task.title)
              .toList(),
    );
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}

class _MockTaskTemplate {
  const _MockTaskTemplate({
    required this.title,
    required this.description,
    required this.priority,
    required this.estimatedMinutes,
    required this.subTasks,
  });

  final String title;
  final String description;
  final String priority;
  final int estimatedMinutes;
  final List<String> subTasks;
}
