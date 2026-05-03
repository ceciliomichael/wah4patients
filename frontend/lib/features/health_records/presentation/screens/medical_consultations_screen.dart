import 'package:flutter/material.dart';

import '../../data/health_records_api_client.dart';
import '../models/health_record_models.dart';
import '../widgets/health_record_data_screen.dart';

class MedicalConsultationsScreen extends StatelessWidget {
  const MedicalConsultationsScreen({super.key});

  static const HealthRecordScreenContent _content = HealthRecordScreenContent(
    title: 'Medical Consultations',
    searchHint: 'Search consultations',
    filterOptions: <String>[
      'All',
      'Teleconsultation',
      'Onsite',
      'Follow-up',
    ],
    helpTitle: 'Medical Consultations Help',
    helpMessages: <String>[
      'Search consultations by reason, provider, or location.',
      'Use the type filter to narrow the consultation list.',
      'Tap any consultation to review its summary details.',
    ],
    emptyTitle: 'No matching consultations',
    emptyMessage: 'Try a different search term or consultation type.',
    entries: <HealthRecordEntry>[],
  );

  @override
  Widget build(BuildContext context) {
    return const HealthRecordDataScreen(
      section: HealthRecordSection.consultations,
      content: _content,
    );
  }
}
