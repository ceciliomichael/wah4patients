import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/dashboard/domain/dashboard_models.dart';
import 'package:frontend/features/dashboard/presentation/widgets/dashboard_metric_card.dart';

void main() {
  testWidgets('shows a simple empty weekly state when there is no data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardMetricCard(
            data: DashboardMetricData(
              label: 'BMI',
              value: '--',
              unit: 'kg/m²',
              icon: Icons.monitor_weight_outlined,
              accentColor: Colors.blue,
              hasData: false,
              entryCount: 0,
            ),
          ),
        ),
      ),
    );

    expect(find.text('No records this week'), findsOneWidget);
    expect(find.text('Add a new entry in Personal Records.'), findsOneWidget);
    expect(find.byIcon(Icons.monitor_weight_outlined), findsOneWidget);
    expect(find.text('No data'), findsOneWidget);
  });

  testWidgets('shows a compact static summary when there is data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardMetricCard(
            data: DashboardMetricData(
              label: 'BMI',
              value: '23.6',
              unit: 'kg/m²',
              icon: Icons.monitor_weight_outlined,
              accentColor: Colors.blue,
              hasData: true,
              entryCount: 1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('23.6'), findsOneWidget);
    expect(find.text('kg/m²'), findsOneWidget);
    expect(find.text('1 reading this week'), findsOneWidget);
    expect(find.text('This week'), findsOneWidget);
  });
}
