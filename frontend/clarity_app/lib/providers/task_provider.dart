import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/speech_input_mode.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String? _insights;
  double _totalEstimatedHours = 0;
  DailySummary? _summary;
  bool _isDarkMode = false;
  bool _isTestMode = false;

  // Pending input from external source (e.g. Whisper test)
  String? _pendingInput;
  String? get pendingInput => _pendingInput;
  void setPendingInput(String text) {
    _pendingInput = text;
    notifyListeners();
  }
  void clearPendingInput() {
    _pendingInput = null;
  }

  bool get isDarkMode => _isDarkMode;
  bool get isTestMode => _isTestMode;
  SpeechInputMode get speechInputMode => defaultSpeechInputMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Test mode: mock data for entire month
  final Map<String, List<Task>> testMonthData = {};

  void toggleTestMode() {
    _isTestMode = !_isTestMode;
    if (_isTestMode) {
      _generateTestMonth();
      _loadTestData();
    } else {
      testMonthData.clear();
      _tasks = [];
      _summary = null;
      _insights = null;
      _error = null;
      _totalEstimatedHours = 0;
      notifyListeners();
      _loadTodayTasks();
    }
  }

  void _loadTestData() {
    final today = todayDate;
    _tasks = testMonthData[today] ?? _generateMockTasks();
    _insights = "You've got a solid mix of priorities today — start with the quick wins!";
    _sortTasks();
    notifyListeners();
  }

  void _generateTestMonth() {
    testMonthData.clear();
    final now = DateTime.now();
    // Generate current month + next month
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 2, 0);

    final taskTemplates = [
      {'title': 'Review lecture notes', 'priority': 'important_not_urgent', 'dueTime': '09:00'},
      {'title': 'Submit homework', 'priority': 'urgent_important', 'dueTime': '23:59'},
      {'title': 'Go to the gym', 'priority': 'neither', 'dueTime': '07:00'},
      {'title': 'Email professor', 'priority': 'urgent_not_important', 'dueTime': '10:30'},
      {'title': 'Buy groceries', 'priority': 'important_not_urgent', 'dueTime': '17:00'},
      {'title': 'Call mom', 'priority': 'important_not_urgent', 'dueTime': '19:00'},
      {'title': 'Clean room', 'priority': 'neither', 'dueTime': '23:59'},
      {'title': 'Group project meeting', 'priority': 'urgent_important', 'dueTime': '14:00'},
      {'title': 'Do laundry', 'priority': 'neither', 'dueTime': '23:59'},
      {'title': 'Study for midterm', 'priority': 'urgent_important', 'dueTime': '20:00'},
      {'title': 'Renew parking permit', 'priority': 'urgent_not_important', 'dueTime': '16:00'},
      {'title': 'Review resume', 'priority': 'important_not_urgent', 'dueTime': '23:59'},
      {'title': 'Apply for internship', 'priority': 'important_not_urgent', 'dueTime': '23:59'},
      {'title': 'Dentist appointment', 'priority': 'urgent_not_important', 'dueTime': '09:30'},
      {'title': 'Pick up package', 'priority': 'urgent_not_important', 'dueTime': '12:00'},
      {'title': 'Read chapter 5', 'priority': 'important_not_urgent', 'dueTime': '21:00'},
      {'title': 'Fix bike tire', 'priority': 'neither', 'dueTime': '23:59'},
      {'title': 'Prepare presentation', 'priority': 'urgent_important', 'dueTime': '11:00'},
      {'title': 'Pay rent', 'priority': 'urgent_important', 'dueTime': '17:00'},
      {'title': 'Schedule advising', 'priority': 'important_not_urgent', 'dueTime': '15:00'},
      {'title': 'Return library books', 'priority': 'urgent_not_important', 'dueTime': '18:00'},
      {'title': 'Meal prep Sunday', 'priority': 'neither', 'dueTime': '10:00'},
      {'title': 'Update LinkedIn', 'priority': 'neither', 'dueTime': '23:59'},
      {'title': 'Office hours', 'priority': 'important_not_urgent', 'dueTime': '13:00'},
    ];

    for (var d = firstDay; !d.isAfter(lastDay); d = d.add(const Duration(days: 1))) {
      final key = DateFormat('yyyy-MM-dd').format(d);
      final dayOfMonth = d.day;
      final seed = dayOfMonth * 7;

      // 3-6 tasks per day
      final numTasks = 3 + (seed % 4);
      final dayTasks = <Task>[];

      for (var i = 0; i < numTasks; i++) {
        final tpl = taskTemplates[(seed + i * 3) % taskTemplates.length];
        // Past days: random completion. Future days: not completed
        final isPast = d.isBefore(DateTime(now.year, now.month, now.day));
        final isComplete = isPast && ((seed + i) % 3 != 0); // ~66% completion for past days

        final hasSubTasks = i == 0 && numTasks > 3;
        dayTasks.add(Task(
          id: 'test-$key-$i',
          title: tpl['title'] as String,
          priority: tpl['priority'] as String?,
          dueTime: tpl['dueTime'] as String?,
          completed: isComplete,
          subTasks: hasSubTasks ? [
            Task(id: 'test-$key-$i-a', title: 'Step 1: Gather materials', completed: isComplete),
            Task(id: 'test-$key-$i-b', title: 'Step 2: Do the work', completed: isPast && (seed % 2 == 0)),
            Task(id: 'test-$key-$i-c', title: 'Step 3: Review and submit', completed: false),
          ] : [],
        ));
      }

      testMonthData[key] = dayTasks;
    }
  }

  static List<Task> _generateMockTasks() {
    return [
      Task(id: 'mock-1', title: 'Email professor about extension', description: 'Ask about late submission policy', priority: 'urgent_important', completed: false),
      Task(id: 'mock-2', title: 'Study for midterm', description: 'Chapters 4-7, focus on linked lists', priority: 'urgent_important', subTasks: [
        Task(id: 'mock-2a', title: 'Review chapter 4 notes', completed: true),
        Task(id: 'mock-2b', title: 'Practice problems ch 5-6', completed: false),
        Task(id: 'mock-2c', title: 'Make flashcards for ch 7', completed: false),
      ], completed: false),
      Task(id: 'mock-3', title: 'Renew parking permit', description: 'Expires Friday', priority: 'urgent_not_important', completed: true),
      Task(id: 'mock-4', title: 'Prepare slides for group meeting', description: 'Meeting tomorrow at 2pm', priority: 'urgent_not_important', completed: false),
      Task(id: 'mock-5', title: 'Buy groceries', priority: 'important_not_urgent', subTasks: [
        Task(id: 'mock-5a', title: 'Make a grocery list', completed: true),
        Task(id: 'mock-5b', title: 'Go to store', completed: false),
      ], completed: false),
      Task(id: 'mock-6', title: 'Call mom back', priority: 'important_not_urgent', completed: true),
      Task(id: 'mock-7', title: 'Go to the gym', description: 'Haven\'t gone in 2 weeks', priority: 'neither', completed: false),
      Task(id: 'mock-8', title: 'Review Sarah\'s resume', priority: 'neither', completed: false),
    ];
  }

  TaskProvider() {
    _loadTodayTasks();
  }

  Future<void> _loadTodayTasks() async {
    try {
      final tasks = await _api.loadTasks(todayDate);
      if (tasks.isNotEmpty) {
        _tasks = tasks;
        _sortTasks();
        notifyListeners();
      }
    } catch (_) {
      // Backend might not be running yet, ignore
    }
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get insights => _insights;
  double get totalEstimatedHours => _totalEstimatedHours;
  DailySummary? get summary => _summary;

  int get completedCount => _tasks.where((t) => t.completed).length;
  int get totalCount => _tasks.length;
  double get completionRate =>
      _tasks.isEmpty ? 0 : completedCount / totalCount;

  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> processBrainDump(String text) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (_isTestMode) {
      await Future.delayed(const Duration(seconds: 1)); // simulate loading
      _tasks.addAll(_generateMockTasks());
      _insights = "Test mode: generated sample tasks from your input.";
      _sortTasks();
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final result = await _api.process(text);
      final newTasks = result.tasks;

      if (result.suggestedOrder.isNotEmpty) {
        final orderMap = <String, int>{};
        for (var i = 0; i < result.suggestedOrder.length; i++) {
          orderMap[result.suggestedOrder[i]] = i;
        }
        newTasks.sort((a, b) {
          final aIdx = orderMap[a.id] ?? 999;
          final bIdx = orderMap[b.id] ?? 999;
          return aIdx.compareTo(bIdx);
        });
      }

      // Append new tasks to existing ones instead of replacing
      _tasks.addAll(newTasks);

      // Sort all tasks by priority (high→low), then by suggested order
      _sortTasks();
      _insights = result.insights;
      _totalEstimatedHours += result.totalEstimatedHours;
    } catch (e) {
      _error = 'Could not process. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  static const _priorityOrder = {
    'urgent_important': 0,
    'urgent_not_important': 1,
    'important_not_urgent': 2,
    'neither': 3,
  };

  void _sortTasks() {
    _tasks.sort((a, b) {
      // Completed tasks go to the bottom
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      // Then sort by priority
      final aPri = _priorityOrder[a.priority] ?? 3;
      final bPri = _priorityOrder[b.priority] ?? 3;
      return aPri.compareTo(bPri);
    });
  }

  // Celebration tracking
  String? _celebration; // null = no celebration
  String? get celebration => _celebration;
  void clearCelebration() {
    _celebration = null;
    notifyListeners();
  }

  void toggleTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final wasAllDone = _tasks.every((t) => t.completed);
      final completedBefore = completedCount;

      final newState = !_tasks[idx].completed;
      final newSubs = _tasks[idx].subTasks
          .map((s) => s.copyWith(completed: newState))
          .toList();
      _tasks[idx] = _tasks[idx].copyWith(completed: newState, subTasks: newSubs);
      _sortTasks();

      // Celebration checks
      if (newState) {
        final allDone = _tasks.every((t) => t.completed);
        if (allDone && !wasAllDone && _tasks.length > 1) {
          _celebration = 'all_done';
        } else if (completedBefore == 0) {
          _celebration = 'first_done';
        } else if (completedCount == (_tasks.length / 2).ceil() && _tasks.length > 2) {
          _celebration = 'halfway';
        }
      }

      notifyListeners();
      _api.saveTasks(todayDate, _tasks).catchError((e) {
        _error = 'Failed to save. Changes may be lost.';
        notifyListeners();
      });
    }
  }

  void toggleSubTask(String parentId, String subTaskId) {
    final parentIdx = _tasks.indexWhere((t) => t.id == parentId);
    if (parentIdx != -1) {
      final parent = _tasks[parentIdx];
      final newSubs = parent.subTasks.map((s) {
        if (s.id == subTaskId) return s.copyWith(completed: !s.completed);
        return s;
      }).toList();

      // Auto-complete parent when all sub-tasks are done
      final allSubsDone = newSubs.every((s) => s.completed);
      _tasks[parentIdx] = parent.copyWith(subTasks: newSubs, completed: allSubsDone);
      _sortTasks();
      notifyListeners();
      _api.saveTasks(todayDate, _tasks).catchError((e) {
        _error = 'Failed to save. Changes may be lost.';
        notifyListeners();
      });
    }
  }

  Future<void> getDailySummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await _api.summarize(_tasks, todayDate);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearTasks() {
    _tasks = [];
    _summary = null;
    _insights = null;
    _error = null;
    _totalEstimatedHours = 0;
    notifyListeners();
    // Also clear from backend DB
    _api.saveTasks(todayDate, []).catchError((_) {});
  }
}
