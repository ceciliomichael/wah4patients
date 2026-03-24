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

const List<ResupplyHistoryEntry> mockResupplyHistoryEntries =
    <ResupplyHistoryEntry>[
      ResupplyHistoryEntry(
        id: 'r-001',
        medicationName: 'Amlodipine',
        dosage: '5 mg tablet',
        requestDate: 'March 18, 2026',
        status: ResupplyRequestStatus.approved,
        note: 'Requested for the next weekly refill window.',
      ),
      ResupplyHistoryEntry(
        id: 'r-002',
        medicationName: 'Atorvastatin',
        dosage: '20 mg tablet',
        requestDate: 'March 11, 2026',
        status: ResupplyRequestStatus.pending,
        note: 'Waiting for review from the assigned clinic.',
      ),
      ResupplyHistoryEntry(
        id: 'r-003',
        medicationName: 'Metformin',
        dosage: '500 mg tablet',
        requestDate: 'February 27, 2026',
        status: ResupplyRequestStatus.rejected,
        note: 'Needs updated prescription details before approval.',
      ),
      ResupplyHistoryEntry(
        id: 'r-004',
        medicationName: 'Losartan',
        dosage: '50 mg tablet',
        requestDate: 'February 14, 2026',
        status: ResupplyRequestStatus.cancelled,
        note: 'Request cancelled after dosage change.',
      ),
    ];
