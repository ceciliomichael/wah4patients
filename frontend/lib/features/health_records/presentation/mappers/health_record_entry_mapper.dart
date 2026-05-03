import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/health_records_api_client.dart';
import '../models/health_record_models.dart';

HealthRecordEntry mapHealthRecordResponseToEntry(HealthRecordResponse record) {
  return HealthRecordEntry(
    id: record.id,
    title: record.title,
    subtitle: record.subtitle,
    summaryLabel: record.summaryLabel,
    summaryValue: record.summaryValue,
    filterValue: record.filterValue,
    statusLabel: record.statusLabel,
    statusColor: _mapColor(record.statusColorKey),
    accentColor: _mapColor(record.accentColorKey),
    icon: _mapIcon(record.iconKey),
    details: record.details
        .map(
          (detail) => HealthRecordDetailField(
            label: detail.label,
            value: detail.value,
          ),
        )
        .toList(growable: false),
  );
}

Color _mapColor(String key) {
  return switch (key.trim().toLowerCase()) {
    'primary' => AppColors.primary,
    'primary_dark' || 'primarydark' => AppColors.primaryDark,
    'secondary' => AppColors.secondary,
    'tertiary' => AppColors.tertiary,
    'success' => AppColors.success,
    'danger' || 'error' => AppColors.danger,
    _ => AppColors.primary,
  };
}

IconData _mapIcon(String key) {
  return switch (key.trim().toLowerCase()) {
    'history' || 'medical_history' => Icons.history_outlined,
    'vaccines' || 'immunization' => Icons.vaccines_outlined,
    'health_and_safety' => Icons.health_and_safety_outlined,
    'schedule' => Icons.schedule_outlined,
    'assignment' => Icons.assignment_outlined,
    'accessibility' => Icons.accessibility_new_outlined,
    'medical_services' || 'consultation' => Icons.medical_services_outlined,
    'video_call' || 'teleconsultation' => Icons.video_call_outlined,
    'local_hospital' => Icons.local_hospital_outlined,
    'science' || 'laboratory' => Icons.science_outlined,
    'monitor_heart' => Icons.monitor_heart_outlined,
    'favorite' || 'cardiology' => Icons.favorite_outline,
    _ => Icons.description_outlined,
  };
}
