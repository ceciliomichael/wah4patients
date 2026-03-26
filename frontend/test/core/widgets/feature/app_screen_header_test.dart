import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/widgets/feature/app_screen_header.dart';

void main() {
  testWidgets('renders a tappable back button with ink splash surface', (
    WidgetTester tester,
  ) async {
    var backPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppScreenHeader(
            title: 'Health Records',
            onBackPressed: () {
              backPressed = true;
            },
            onHelpPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byType(InkWell), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(backPressed, isTrue);
  });
}
