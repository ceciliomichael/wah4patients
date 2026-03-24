import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../models/body_mass_index_models.dart';

/// Shared BMI presentation helpers used by the screen and related widgets.
double calculateBmi({
  required double weight,
  required double height,
  required BmiUnitSystem unitSystem,
}) {
  return unitSystem == BmiUnitSystem.metric
      ? weight / math.pow(height / 100, 2)
      : (703 * weight) / math.pow(height, 2);
}

String bmiCategoryForValue(double bmi) {
  if (bmi < 18.5) {
    return 'Underweight';
  }
  if (bmi < 25) {
    return 'Normal';
  }
  if (bmi < 30) {
    return 'Overweight';
  }
  return 'Obesity';
}

Color bmiCategoryColor(String category) {
  return switch (category) {
    'Underweight' => AppColors.secondary,
    'Normal' => AppColors.success,
    'Overweight' => AppColors.tertiary,
    'Obesity' => AppColors.danger,
    _ => AppColors.primary,
  };
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatDate(DateTime dateTime) {
  final day = dateTime.day.toString().padLeft(2, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  return '$day/$month/${dateTime.year}';
}

String formatTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour > 12
      ? local.hour - 12
      : (local.hour == 0 ? 12 : local.hour);
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')} $period';
}

String weightUnitLabel(BmiUnitSystem unitSystem) {
  return unitSystem == BmiUnitSystem.metric ? 'kg' : 'lb';
}

String heightUnitLabel(BmiUnitSystem unitSystem) {
  return unitSystem == BmiUnitSystem.metric ? 'cm' : 'in';
}

String weightHint(BmiUnitSystem unitSystem) {
  return unitSystem == BmiUnitSystem.metric
      ? 'Enter weight in kg'
      : 'Enter weight in pounds';
}

String heightHint(BmiUnitSystem unitSystem) {
  return unitSystem == BmiUnitSystem.metric
      ? 'Enter height in cm'
      : 'Enter height in inches';
}

String formatMeasurement(BodyMassIndexHistoryEntry entry) {
  return entry.unitSystem == BmiUnitSystem.metric
      ? '${entry.weight.toStringAsFixed(1)} kg · ${entry.height.toStringAsFixed(0)} cm'
      : '${entry.weight.toStringAsFixed(1)} lb · ${entry.height.toStringAsFixed(0)} in';
}
