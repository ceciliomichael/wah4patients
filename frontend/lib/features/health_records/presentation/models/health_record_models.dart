import 'package:flutter/material.dart';

class HealthRecordDetailField {
  const HealthRecordDetailField({required this.label, required this.value});

  final String label;
  final String value;
}

class HealthRecordEntry {
  const HealthRecordEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.caption,
    required this.filterValue,
    required this.statusLabel,
    required this.statusColor,
    required this.accentColor,
    required this.icon,
    required this.details,
  });

  final String id;
  final String title;
  final String subtitle;
  final String caption;
  final String filterValue;
  final String statusLabel;
  final Color statusColor;
  final Color accentColor;
  final IconData icon;
  final List<HealthRecordDetailField> details;
}

class HealthRecordScreenContent {
  const HealthRecordScreenContent({
    required this.title,
    required this.searchHint,
    required this.filterOptions,
    required this.helpTitle,
    required this.helpMessages,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.entries,
  });

  final String title;
  final String searchHint;
  final List<String> filterOptions;
  final String helpTitle;
  final List<String> helpMessages;
  final String emptyTitle;
  final String emptyMessage;
  final List<HealthRecordEntry> entries;
}
