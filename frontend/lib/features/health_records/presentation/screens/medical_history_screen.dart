import 'package:flutter/material.dart';

import '../../data/health_records_api_client.dart';
import '../models/health_record_models.dart';
import '../widgets/health_record_data_screen.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

  static const HealthRecordScreenContent _content = HealthRecordScreenContent(
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
    entries: <HealthRecordEntry>[],
  );

  @override
  Widget build(BuildContext context) {
    return const HealthRecordDataScreen(
      section: HealthRecordSection.medicalHistory,
      content: _content,
    );
  }
}
