import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum ResupplyRequestStatus { pending, approved, rejected, cancelled }

extension ResupplyRequestStatusX on ResupplyRequestStatus {
  String get label => switch (this) {
    ResupplyRequestStatus.pending => 'Pending',
    ResupplyRequestStatus.approved => 'Approved',
    ResupplyRequestStatus.rejected => 'Rejected',
    ResupplyRequestStatus.cancelled => 'Cancelled',
  };

  IconData get icon => switch (this) {
    ResupplyRequestStatus.pending => Icons.schedule_outlined,
    ResupplyRequestStatus.approved => Icons.check_circle_outline,
    ResupplyRequestStatus.rejected => Icons.highlight_off_outlined,
    ResupplyRequestStatus.cancelled => Icons.remove_circle_outline,
  };

  Color get color => switch (this) {
    ResupplyRequestStatus.pending => AppColors.tertiary,
    ResupplyRequestStatus.approved => AppColors.success,
    ResupplyRequestStatus.rejected => AppColors.danger,
    ResupplyRequestStatus.cancelled => AppColors.textSecondary,
  };

  Color get tint => color.withValues(alpha: 0.12);

  static ResupplyRequestStatus fromApiValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'approved':
        return ResupplyRequestStatus.approved;
      case 'rejected':
        return ResupplyRequestStatus.rejected;
      case 'cancelled':
        return ResupplyRequestStatus.cancelled;
      case 'pending':
      default:
        return ResupplyRequestStatus.pending;
    }
  }
}

class ResupplyPrescriptionOption {
  const ResupplyPrescriptionOption({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.icon,
  });

  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final IconData icon;
}

class ResupplyHistoryEntry {
  const ResupplyHistoryEntry({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.requestDate,
    required this.status,
    required this.note,
  });

  final String id;
  final String medicationName;
  final String dosage;
  final String requestDate;
  final ResupplyRequestStatus status;
  final String note;
}

class ResupplyHistoryScreenContent {
  const ResupplyHistoryScreenContent({
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
  final List<ResupplyHistoryEntry> entries;

  ResupplyHistoryScreenContent copyWith({
    String? title,
    String? searchHint,
    List<String>? filterOptions,
    String? helpTitle,
    List<String>? helpMessages,
    String? emptyTitle,
    String? emptyMessage,
    List<ResupplyHistoryEntry>? entries,
  }) {
    return ResupplyHistoryScreenContent(
      title: title ?? this.title,
      searchHint: searchHint ?? this.searchHint,
      filterOptions: filterOptions ?? this.filterOptions,
      helpTitle: helpTitle ?? this.helpTitle,
      helpMessages: helpMessages ?? this.helpMessages,
      emptyTitle: emptyTitle ?? this.emptyTitle,
      emptyMessage: emptyMessage ?? this.emptyMessage,
      entries: entries ?? this.entries,
    );
  }
}

const ResupplyHistoryScreenContent resupplyHistoryScreenContentShell =
    ResupplyHistoryScreenContent(
      title: 'Prescription History',
      searchHint: 'Search prescriptions',
      filterOptions: <String>[
        'All',
        'Pending',
        'Approved',
        'Rejected',
        'Cancelled',
      ],
      helpTitle: 'Prescription History Help',
      helpMessages: <String>[
        'Search by medicine name or note text.',
        'Use the status filter to narrow down the history list.',
        'Tap any card to expand its notes inline.',
      ],
      emptyTitle: 'No matching requests',
      emptyMessage: 'Try a different search term or status filter.',
      entries: <ResupplyHistoryEntry>[],
    );

const List<ResupplyPrescriptionOption> mockResupplyPrescriptionOptions =
    <ResupplyPrescriptionOption>[
      ResupplyPrescriptionOption(
        id: 'amlodipine',
        name: 'Amlodipine',
        dosage: '5 mg tablet',
        frequency: 'Once daily',
        icon: Icons.medication_outlined,
      ),
      ResupplyPrescriptionOption(
        id: 'atorvastatin',
        name: 'Atorvastatin',
        dosage: '20 mg tablet',
        frequency: 'Every night',
        icon: Icons.local_pharmacy_outlined,
      ),
      ResupplyPrescriptionOption(
        id: 'metformin',
        name: 'Metformin',
        dosage: '500 mg tablet',
        frequency: 'Twice daily',
        icon: Icons.tablet_outlined,
      ),
    ];
