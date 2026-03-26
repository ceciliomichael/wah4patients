import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/health_record_models.dart';
import '../widgets/health_record_screen_template.dart';

class ImmunizationRecordsScreen extends StatelessWidget {
  const ImmunizationRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HealthRecordScreenTemplate(
      content: HealthRecordScreenContent(
        title: 'Immunization Records',
        searchHint: 'Search immunization records',
        filterOptions: <String>[
          'All',
          'Completed',
          'Not Done',
          'Entered in Error',
        ],
        helpTitle: 'Immunization Records Help',
        helpMessages: <String>[
          'Search vaccines by name, clinic, or notes.',
          'Use the filter to review completed or pending records.',
          'Tap a vaccine entry to open the stored record details.',
        ],
        emptyTitle: 'No matching immunization records',
        emptyMessage: 'Try a different search term or status filter.',
        entries: <HealthRecordEntry>[
          HealthRecordEntry(
            id: 'imm-001',
            title: 'COVID-19 Booster',
            subtitle: 'mRNA vaccine booster dose',
            summaryLabel: 'Clinic',
            summaryValue: 'WAH Community Clinic',
            filterValue: 'Completed',
            statusLabel: 'Completed',
            statusColor: AppColors.success,
            accentColor: AppColors.secondary,
            icon: Icons.vaccines_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Dose', value: 'Booster'),
              HealthRecordDetailField(label: 'Date', value: 'January 08, 2026'),
              HealthRecordDetailField(
                label: 'Performer',
                value: 'Nurse Garcia',
              ),
              HealthRecordDetailField(label: 'Lot number', value: 'CVB-24018'),
              HealthRecordDetailField(
                label: 'Note',
                value: 'Administered at WAH Community Clinic',
              ),
            ],
          ),
          HealthRecordEntry(
            id: 'imm-002',
            title: 'Influenza Vaccine',
            subtitle: 'Seasonal flu shot',
            summaryLabel: 'Clinic',
            summaryValue: 'WAH Wellness Center',
            filterValue: 'Completed',
            statusLabel: 'Completed',
            statusColor: AppColors.success,
            accentColor: AppColors.primary,
            icon: Icons.health_and_safety_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Dose', value: 'Single dose'),
              HealthRecordDetailField(label: 'Date', value: 'October 14, 2025'),
              HealthRecordDetailField(label: 'Site', value: 'Left deltoid'),
              HealthRecordDetailField(
                label: 'Performer',
                value: 'WAH Wellness Center',
              ),
            ],
          ),
          HealthRecordEntry(
            id: 'imm-003',
            title: 'Hepatitis B Series',
            subtitle: 'Third dose not yet completed',
            summaryLabel: 'Note',
            summaryValue: 'Next dose due this quarter',
            filterValue: 'Not Done',
            statusLabel: 'Not Done',
            statusColor: AppColors.tertiary,
            accentColor: AppColors.tertiary,
            icon: Icons.schedule_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Series', value: 'Dose 3 of 3'),
              HealthRecordDetailField(label: 'Due date', value: 'May 10, 2026'),
              HealthRecordDetailField(
                label: 'Clinic',
                value: 'WAH Preventive Care',
              ),
              HealthRecordDetailField(
                label: 'Note',
                value: 'Bring previous vaccine card',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
