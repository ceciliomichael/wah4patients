import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/dashboard/presentation/widgets/dashboard_header.dart';

void main() {
  testWidgets('renders a tappable help button with a full ink surface', (
    WidgetTester tester,
  ) async {
    var helpPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardHeader(
            userName: 'User',
            onHelpPressed: () {
              helpPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(InkWell), findsOneWidget);
    expect(find.byIcon(Icons.help_outline), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(helpPressed, isTrue);
  });
}
