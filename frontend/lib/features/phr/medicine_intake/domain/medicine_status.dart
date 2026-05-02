import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum MedicineStatus { active, paused, completed }

extension MedicineStatusX on MedicineStatus {
  String get label => switch (this) {
    MedicineStatus.active => 'Active',
    MedicineStatus.paused => 'Paused',
    MedicineStatus.completed => 'Completed',
  };

  String get menuLabel => switch (this) {
    MedicineStatus.active => 'Active Status',
    MedicineStatus.paused => 'Paused Status',
    MedicineStatus.completed => 'Completed Status',
  };

  IconData get icon => switch (this) {
    MedicineStatus.active => Icons.medication_outlined,
    MedicineStatus.paused => Icons.pause_circle_outline,
    MedicineStatus.completed => Icons.check_circle_outline,
  };

  Color get color => switch (this) {
    MedicineStatus.active => AppColors.success,
    MedicineStatus.paused => AppColors.tertiary,
    MedicineStatus.completed => AppColors.textSecondary,
  };

  String get apiValue => switch (this) {
    MedicineStatus.active => 'scheduled',
    MedicineStatus.paused => 'delayed',
    MedicineStatus.completed => 'taken',
  };
}

MedicineStatus medicineStatusFromApi(String value) {
  return switch (value) {
    'taken' => MedicineStatus.completed,
    'scheduled' => MedicineStatus.active,
    'delayed' || 'missed' || 'skipped' => MedicineStatus.paused,
    _ => MedicineStatus.active,
  };
}
