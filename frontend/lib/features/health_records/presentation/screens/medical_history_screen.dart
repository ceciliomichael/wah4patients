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
      'Active',
      'Confirmed',
      'Resolved',
      'Completed',
      'In Progress',
      'Cancelled',
    ],
    helpTitle: 'Medical History Help',
    helpMessages: <String>[
      'Review diagnoses, procedures, and when they were recorded.',
      'Check the status, verification state, body site, severity, and notes.',
      'Tap any record to open the full patient-facing details.',
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
