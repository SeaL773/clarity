import 'package:dio/dio.dart';
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator → host localhost
  // static const String baseUrl = 'http://localhost:8000'; // Web / Windows / iOS simulator

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<ProcessResult> process(String text, {String? context}) async {
    final response = await _dio.post('/api/process', data: {
      'text': text,
      if (context != null) 'context': context,
    });
    final data = response.data;
    return ProcessResult(
      tasks: (data['tasks'] as List)
          .map((t) => Task.fromJson(t as Map<String, dynamic>))
          .toList(),
      suggestedOrder: (data['suggested_order'] as List?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      totalEstimatedHours: (data['total_estimated_hours'] ?? 0).toDouble(),
      insights: data['insights'],
    );
  }

  Future<List<Task>> parse(String text, {String? context}) async {
    final response = await _dio.post('/api/parse', data: {
      'text': text,
      if (context != null) 'context': context,
    });
    return (response.data['tasks'] as List)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<DailySummary> summarize(List<Task> tasks, String date) async {
    final response = await _dio.post('/api/summarize', data: {
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'date': date,
    });
    return DailySummary.fromJson(response.data);
  }

  Future<void> saveTasks(String date, List<Task> tasks) async {
    await _dio.post('/api/tasks/$date',
        data: tasks.map((t) => t.toJson()).toList());
  }

  Future<List<Task>> loadTasks(String date) async {
    final response = await _dio.get('/api/tasks/$date');
    return (response.data['tasks'] as List)
        .map((t) => Task.fromJson(t as Map<String, dynamic>))
        .toList();
  }
}

class ProcessResult {
  final List<Task> tasks;
  final List<String> suggestedOrder;
  final double totalEstimatedHours;
  final String? insights;

  ProcessResult({
    required this.tasks,
    required this.suggestedOrder,
    required this.totalEstimatedHours,
    this.insights,
  });
}
