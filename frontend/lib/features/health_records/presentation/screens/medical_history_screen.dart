import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/health_record_models.dart';
import '../widgets/health_record_screen_template.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HealthRecordScreenTemplate(
      content: HealthRecordScreenContent(
        title: 'Medical History',
        searchHint: 'Search medical history',
        filterOptions: <String>[
          'All',
          'Completed',
          'In Progress',
          'Preparation',
          'Not Done',
        ],
        helpTitle: 'Medical History Help',
        helpMessages: <String>[
          'Search diagnoses, procedures, and recorded outcomes.',
          'Use the status filter to narrow the list quickly.',
          'Tap any record to review the stored details.',
        ],
        emptyTitle: 'No matching medical history',
        emptyMessage: 'Try a different search term or status filter.',
        entries: <HealthRecordEntry>[
          HealthRecordEntry(
            id: 'mh-001',
            title: 'Appendectomy',
            subtitle: 'Appendix removal procedure',
            summaryLabel: 'Recorded',
            summaryValue: 'March 12, 2024',
            filterValue: 'Completed',
            statusLabel: 'Completed',
            statusColor: AppColors.success,
            accentColor: AppColors.primary,
            icon: Icons.history_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Category', value: 'Surgery'),
              HealthRecordDetailField(
                label: 'Outcome',
                value: 'Recovered well',
              ),
              HealthRecordDetailField(
                label: 'Facility',
                value: 'WAH General Hospital',
              ),
              HealthRecordDetailField(label: 'Date', value: 'March 12, 2024'),
            ],
          ),
          HealthRecordEntry(
            id: 'mh-002',
            title: 'Physical Therapy',
            subtitle: 'Lower back mobility sessions',
            summaryLabel: 'Follow-up',
            summaryValue: 'April 2026',
            filterValue: 'In Progress',
            statusLabel: 'In Progress',
            statusColor: AppColors.secondary,
            accentColor: AppColors.secondary,
            icon: Icons.accessibility_new_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(
                label: 'Category',
                value: 'Rehabilitation',
              ),
              HealthRecordDetailField(
                label: 'Outcome',
                value: 'Mobility improving',
              ),
              HealthRecordDetailField(label: 'Provider', value: 'Dr. Santos'),
              HealthRecordDetailField(
                label: 'Plan',
                value: 'Continue 2 sessions weekly',
              ),
            ],
          ),
          HealthRecordEntry(
            id: 'mh-003',
            title: 'CT Scan Preparation',
            subtitle: 'Imaging prep instructions',
            summaryLabel: 'Note',
            summaryValue: 'Preparation checklist pending',
            filterValue: 'Preparation',
            statusLabel: 'Preparation',
            statusColor: AppColors.tertiary,
            accentColor: AppColors.tertiary,
            icon: Icons.assignment_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Category', value: 'Imaging'),
              HealthRecordDetailField(
                label: 'Status note',
                value: 'Fasting required before visit',
              ),
              HealthRecordDetailField(label: 'Requested by', value: 'Dr. Cruz'),
              HealthRecordDetailField(
                label: 'Target date',
                value: 'April 02, 2026',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
