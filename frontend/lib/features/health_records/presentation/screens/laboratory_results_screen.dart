import 'package:flutter/material.dart';

import '../../data/health_records_api_client.dart';
import '../models/health_record_models.dart';
import '../widgets/health_record_data_screen.dart';

class LaboratoryResultsScreen extends StatelessWidget {
  const LaboratoryResultsScreen({super.key});

  static const HealthRecordScreenContent _content = HealthRecordScreenContent(
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
    entries: <HealthRecordEntry>[],
  );

  @override
  Widget build(BuildContext context) {
    return const HealthRecordDataScreen(
      section: HealthRecordSection.laboratoryResults,
      content: _content,
    );
  }
}
