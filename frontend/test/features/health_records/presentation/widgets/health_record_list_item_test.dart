import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/health_records/presentation/models/health_record_models.dart';
import 'package:frontend/features/health_records/presentation/widgets/health_record_list_item.dart';

void main() {
  testWidgets('renders a structured record card with details', (
    WidgetTester tester,
  ) async {
    const entry = HealthRecordEntry(
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
        HealthRecordDetailField(label: 'Performer', value: 'Nurse Garcia'),
        HealthRecordDetailField(label: 'Lot number', value: 'CVB-24018'),
        HealthRecordDetailField(
          label: 'Note',
          value: 'Administered at WAH Community Clinic',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HealthRecordListItem(
              entry: entry,
              isExpanded: true,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('COVID-19 Booster'), findsOneWidget);
    expect(find.text('mRNA vaccine booster dose'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Clinic'), findsOneWidget);
    expect(find.text('WAH Community Clinic'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Dose'), findsOneWidget);
    expect(find.text('Booster'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('January 08, 2026'), findsOneWidget);
    expect(find.text('Performer'), findsOneWidget);
    expect(find.text('Nurse Garcia'), findsOneWidget);
    expect(find.text('Lot number'), findsOneWidget);
    expect(find.text('CVB-24018'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Administered at WAH Community Clinic'), findsOneWidget);
  });
}
