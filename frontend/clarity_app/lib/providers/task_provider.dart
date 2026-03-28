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
      const priorityOrder = {
        'urgent_important': 0,
        'urgent_not_important': 1,
        'important_not_urgent': 2,
        'neither': 3,
      };
      _tasks.sort((a, b) {
        final aPri = priorityOrder[a.priority] ?? 3;
        final bPri = priorityOrder[b.priority] ?? 3;
        if (aPri != bPri) return aPri.compareTo(bPri);
        // Same priority: keep AI's suggested order (stable sort)
        return 0;
      });
      _insights = result.insights;
      _totalEstimatedHours += result.totalEstimatedHours;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(completed: !_tasks[idx].completed);
      notifyListeners();
      _api.saveTasks(todayDate, _tasks).catchError((_) {});
    }
  }

  void toggleSubTask(String parentId, String subTaskId) {
    final parentIdx = _tasks.indexWhere((t) => t.id == parentId);
    if (parentIdx != -1) {
      final subIdx =
          _tasks[parentIdx].subTasks.indexWhere((t) => t.id == subTaskId);
      if (subIdx != -1) {
        final sub = _tasks[parentIdx].subTasks[subIdx];
        _tasks[parentIdx].subTasks[subIdx] =
            sub.copyWith(completed: !sub.completed);

        // Auto-complete parent when all sub-tasks are done
        final allSubsDone = _tasks[parentIdx].subTasks.every((s) => s.completed);
        if (allSubsDone && !_tasks[parentIdx].completed) {
          _tasks[parentIdx] = _tasks[parentIdx].copyWith(completed: true);
        }
        // Un-complete parent if a sub-task is unchecked
        if (!allSubsDone && _tasks[parentIdx].completed) {
          _tasks[parentIdx] = _tasks[parentIdx].copyWith(completed: false);
        }

        notifyListeners();
        _api.saveTasks(todayDate, _tasks).catchError((_) {});
      }
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
    notifyListeners();
  }
}
