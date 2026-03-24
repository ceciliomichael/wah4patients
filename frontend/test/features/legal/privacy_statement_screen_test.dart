import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/legal/presentation/privacy_statement_screen.dart';

class _PrivacyLauncher extends StatelessWidget {
  const _PrivacyLauncher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyStatementScreen(),
              ),
            );
          },
          child: const Text('Open privacy'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('renders the archived privacy statement content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyStatementScreen()));

    expect(find.text('Privacy Statement'), findsOneWidget);
    expect(find.text('Effective Date: August 1, 2026'), findsOneWidget);
    expect(find.text('1. Personal Data Collected'), findsOneWidget);
    expect(
      find.text('11. Data Protection Officer Contact Details'),
      findsOneWidget,
    );
    expect(find.text('Email: privacy@wah.ph'), findsOneWidget);
  });

  testWidgets('back button returns to the previous screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _PrivacyLauncher()));

    expect(find.text('Open privacy'), findsOneWidget);

    await tester.tap(find.text('Open privacy'));
    await tester.pumpAndSettle();

    expect(find.text('Privacy Statement'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Open privacy'), findsOneWidget);
    expect(find.text('Privacy Statement'), findsNothing);
  });
}
