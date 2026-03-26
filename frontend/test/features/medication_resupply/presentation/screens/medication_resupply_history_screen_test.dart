import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/medication_resupply/presentation/screens/medication_resupply_history_screen.dart';

void main() {
  testWidgets('expands prescription history card inline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MedicationResupplyHistoryScreen()),
    );

    expect(find.text('Amlodipine'), findsOneWidget);
    expect(
      find.text('Requested for the next weekly refill window.'),
      findsNothing,
    );
    expect(find.text('Close'), findsNothing);

    await tester.tap(find.text('Amlodipine'));
    await tester.pumpAndSettle();

    expect(
      find.text('Requested for the next weekly refill window.'),
      findsOneWidget,
    );
    expect(find.text('Close'), findsNothing);
  });
}
