import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum CalendarViewMode {
  month,
  week,
  day,
}

enum EventType {
  appointment,
  medication,
  checkup,
  labTest,
  therapy,
  other,
}

extension EventTypeUi on EventType {
  String get label {
    switch (this) {
      case EventType.appointment:
        return 'Appointments';
      case EventType.medication:
        return 'Medication';
      case EventType.checkup:
        return 'Checkups';
      case EventType.labTest:
        return 'Lab Tests';
      case EventType.therapy:
        return 'Therapy';
      case EventType.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case EventType.appointment:
        return AppColors.primary;
      case EventType.medication:
        return AppColors.tertiary;
      case EventType.checkup:
        return AppColors.secondary;
      case EventType.labTest:
        return AppColors.primaryDark;
      case EventType.therapy:
        return AppColors.black;
      case EventType.other:
        return AppColors.textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.appointment:
        return Icons.event_note;
      case EventType.medication:
        return Icons.medication_outlined;
      case EventType.checkup:
        return Icons.health_and_safety_outlined;
      case EventType.labTest:
        return Icons.science_outlined;
      case EventType.therapy:
        return Icons.accessibility_new_outlined;
      case EventType.other:
        return Icons.event_outlined;
    }
  }
}

class CalendarEvent {
  const CalendarEvent({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.eventType,
    this.location,
    this.doctorName,
    this.color,
  });

  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final EventType eventType;
  final String? location;
  final String? doctorName;
  final Color? color;
}
