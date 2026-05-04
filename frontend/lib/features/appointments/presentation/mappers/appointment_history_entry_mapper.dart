import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../health_records/presentation/models/health_record_models.dart';
import '../../data/appointment_history_api_client.dart';

HealthRecordEntry mapAppointmentHistoryResponseToEntry(
  AppointmentHistoryRecordResponse record,
) {
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
    'history' => Icons.history_outlined,
    'calendar' || 'calendar_month' => Icons.calendar_month_outlined,
    'event' => Icons.event_outlined,
    'schedule' => Icons.schedule_outlined,
    'local_hospital' => Icons.local_hospital_outlined,
    'medical_services' || 'consultation' => Icons.medical_services_outlined,
    'video_call' || 'teleconsultation' => Icons.video_call_outlined,
    'phone' || 'phone_call' => Icons.phone_in_talk_outlined,
    'location' || 'place' => Icons.place_outlined,
    'person' || 'provider' => Icons.person_outline,
    'check_circle' || 'completed' => Icons.check_circle_outline,
    'cancel' || 'cancelled' => Icons.cancel_outlined,
    _ => Icons.description_outlined,
  };
}
