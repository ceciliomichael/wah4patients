import 'package:flutter/material.dart';

import '../../data/health_records_api_client.dart';
import '../models/health_record_models.dart';
import '../widgets/health_record_data_screen.dart';

class ImmunizationRecordsScreen extends StatelessWidget {
  const ImmunizationRecordsScreen({super.key});

  static const HealthRecordScreenContent _content = HealthRecordScreenContent(
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
    entries: <HealthRecordEntry>[],
  );

  @override
  Widget build(BuildContext context) {
    return const HealthRecordDataScreen(
      section: HealthRecordSection.immunizations,
      content: _content,
    );
  }
}
