import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../health_records/presentation/models/health_record_models.dart';
import '../../data/appointment_history_api_client.dart';

HealthRecordEntry mapAppointmentHistoryResponseToEntry(
  AppointmentHistoryRecordResponse record,
) {
  final appointmentMode = _readAppointmentMode(record.details);

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
            label: _formatDetailLabel(detail.label, appointmentMode),
            value: _formatDetailValue(detail.label, detail.value),
          ),
        )
        .toList(growable: false),
  );
}

String? _readAppointmentMode(List<AppointmentHistoryDetailResponse> details) {
  for (final detail in details) {
    final normalizedLabel = detail.label.trim().toLowerCase();
    if (normalizedLabel != 'mode') {
      continue;
    }

    final normalizedValue = detail.value.trim().toLowerCase();
    if (normalizedValue.contains('teleconsult')) {
      return 'teleconsultation';
    }
    if (normalizedValue.contains('onsite')) {
      return 'onsite';
    }
  }

  return null;
}

String _formatDetailLabel(String label, String? appointmentMode) {
  final normalizedLabel = label.trim().toLowerCase();
  if (normalizedLabel != 'location/platform') {
    return label;
  }

  return switch (appointmentMode) {
    'teleconsultation' => 'Platform',
    'onsite' => 'Location',
    _ => 'Location',
  };
}

String _formatDetailValue(String label, String value) {
  final normalizedLabel = label.trim().toLowerCase();
  if (normalizedLabel != 'scheduled at') {
    return value;
  }

  final parsedDate = DateTime.tryParse(value.trim());
  if (parsedDate == null) {
    return value;
  }

  final localDate = parsedDate.toLocal();
  final hour = localDate.hour % 12 == 0 ? 12 : localDate.hour % 12;
  final minute = localDate.minute.toString().padLeft(2, '0');
  final meridiem = localDate.hour >= 12 ? 'PM' : 'AM';

  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[localDate.month - 1]} ${localDate.day}, ${localDate.year} '
      '$hour:$minute $meridiem';
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
