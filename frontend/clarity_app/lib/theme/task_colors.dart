import 'package:flutter/material.dart';

class TaskColors {
  static const Color urgentImportant = Color(0xFFE57373);
  static const Color urgentNotImportant = Color(0xFFFFB74D);
  static const Color importantNotUrgent = Color(0xFF7BAAF7);
  static const Color neither = Color.fromARGB(255, 124, 124, 124);

  static const Color completedLight = Color(0xFFD0D0D0);
  static const Color completedDark = Color(0xFF3A3530);

  static const Color subTaskCompletedLight = Color(0xFFBDBDBD);
  static const Color subTaskCompletedDark = Color(0xFF5A5550);

  static Color priorityAccent(String? priority) {
    switch (priority) {
      case 'urgent_important':
        return urgentImportant;
      case 'urgent_not_important':
        return urgentNotImportant;
      case 'important_not_urgent':
        return importantNotUrgent;
      default:
        return neither;
    }
  }

  static Color completedAccent(bool isDark) =>
      isDark ? completedDark : completedLight;

  static Color subTaskCompletedAccent(bool isDark) =>
      isDark ? subTaskCompletedDark : subTaskCompletedLight;
}
