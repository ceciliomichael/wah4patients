import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/health_record_models.dart';
import '../widgets/health_record_screen_template.dart';

class LaboratoryResultsScreen extends StatelessWidget {
  const LaboratoryResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HealthRecordScreenTemplate(
      content: HealthRecordScreenContent(
        title: 'Laboratory Results',
        searchHint: 'Search laboratory results',
        filterOptions: <String>['All', 'Laboratory', 'Radiology', 'Cardiology'],
        helpTitle: 'Laboratory Results Help',
        helpMessages: <String>[
          'Search test names, categories, or summary notes.',
          'Use the category filter to narrow the result list.',
          'Tap a result item to open the stored details.',
        ],
        emptyTitle: 'No matching laboratory results',
        emptyMessage: 'Try a different search term or category filter.',
        entries: <HealthRecordEntry>[
          HealthRecordEntry(
            id: 'lab-001',
            title: 'Complete Blood Count',
            subtitle: 'Routine laboratory panel',
            summaryLabel: 'Reviewed',
            summaryValue: 'March 03, 2026',
            filterValue: 'Laboratory',
            statusLabel: 'Laboratory',
            statusColor: AppColors.success,
            accentColor: AppColors.primaryDark,
            icon: Icons.science_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Category', value: 'Laboratory'),
              HealthRecordDetailField(
                label: 'Performer',
                value: 'WAH Diagnostics',
              ),
              HealthRecordDetailField(
                label: 'Conclusion',
                value: 'Values within expected range',
              ),
              HealthRecordDetailField(
                label: 'Collected',
                value: 'March 03, 2026',
              ),
            ],
          ),
          HealthRecordEntry(
            id: 'lab-002',
            title: 'Chest X-Ray',
            subtitle: 'Two-view radiology study',
            summaryLabel: 'Reported',
            summaryValue: 'February 12, 2026',
            filterValue: 'Radiology',
            statusLabel: 'Radiology',
            statusColor: AppColors.secondary,
            accentColor: AppColors.secondary,
            icon: Icons.monitor_heart_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Category', value: 'Radiology'),
              HealthRecordDetailField(
                label: 'Performer',
                value: 'WAH Imaging Center',
              ),
              HealthRecordDetailField(
                label: 'Conclusion',
                value: 'No acute cardiopulmonary findings',
              ),
              HealthRecordDetailField(
                label: 'Reported',
                value: 'February 12, 2026',
              ),
            ],
          ),
          HealthRecordEntry(
            id: 'lab-003',
            title: 'ECG Report',
            subtitle: 'Resting electrocardiogram',
            summaryLabel: 'Validated',
            summaryValue: 'January 28, 2026',
            filterValue: 'Cardiology',
            statusLabel: 'Cardiology',
            statusColor: AppColors.tertiary,
            accentColor: AppColors.tertiary,
            icon: Icons.favorite_outline,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Category', value: 'Cardiology'),
              HealthRecordDetailField(
                label: 'Performer',
                value: 'WAH Heart Center',
              ),
              HealthRecordDetailField(
                label: 'Conclusion',
                value: 'Normal sinus rhythm',
              ),
              HealthRecordDetailField(
                label: 'Reported',
                value: 'January 28, 2026',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
