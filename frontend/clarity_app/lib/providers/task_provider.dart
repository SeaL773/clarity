import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  bool get isDarkMode => _isDarkMode;
  bool get isTestMode => _isTestMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleTestMode() {
    _isTestMode = !_isTestMode;
    if (_isTestMode) {
      _loadTestData();
    } else {
      clearTasks();
      _loadTodayTasks();
    }
  }

  void _loadTestData() {
    _tasks = _generateMockTasks();
    _insights = "You've got a solid mix of priorities today — start with the quick wins!";
    _sortTasks();
    notifyListeners();
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

  void toggleTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final newState = !_tasks[idx].completed;
      // Create new sub-tasks list with updated completion
      final newSubs = _tasks[idx].subTasks
          .map((s) => s.copyWith(completed: newState))
          .toList();
      _tasks[idx] = _tasks[idx].copyWith(completed: newState, subTasks: newSubs);
      _sortTasks();
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
