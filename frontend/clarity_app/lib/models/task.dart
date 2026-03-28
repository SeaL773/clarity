/// Task data model matching backend Pydantic schema.

class Task {
  String id;
  String title;
  String? description;
  List<Task> subTasks;
  String? priority; // urgent_important, important_not_urgent, urgent_not_important, neither
  int? estimatedMinutes;
  bool completed;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.subTasks = const [],
    this.priority,
    this.estimatedMinutes,
    this.completed = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      subTasks: (json['sub_tasks'] as List<dynamic>?)
              ?.map((t) => Task.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      priority: json['priority'],
      estimatedMinutes: json['estimated_minutes'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sub_tasks': subTasks.map((t) => t.toJson()).toList(),
      'priority': priority,
      'estimated_minutes': estimatedMinutes,
      'completed': completed,
    };
  }

  Task copyWith({bool? completed}) {
    return Task(
      id: id,
      title: title,
      description: description,
      subTasks: subTasks,
      priority: priority,
      estimatedMinutes: estimatedMinutes,
      completed: completed ?? this.completed,
    );
  }
}

class DailySummary {
  final String summary;
  final int completedCount;
  final int totalCount;
  final double completionRate;
  final String encouragement;
  final List<String> tomorrowFocus;

  DailySummary({
    required this.summary,
    required this.completedCount,
    required this.totalCount,
    required this.completionRate,
    required this.encouragement,
    required this.tomorrowFocus,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      summary: json['summary'] ?? '',
      completedCount: json['completed_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0).toDouble(),
      encouragement: json['encouragement'] ?? '',
      tomorrowFocus: (json['tomorrow_focus'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
