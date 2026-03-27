import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/profile/presentation/screens/about_us_screen.dart';

class _AboutUsLauncher extends StatelessWidget {
  const _AboutUsLauncher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutUsScreen()),
            );
          },
          child: const Text('Open about us'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('renders the researched about us content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutUsScreen()));

    expect(find.text('About Us'), findsOneWidget);
    expect(find.text('Our mission'), findsOneWidget);
    expect(find.text('Official Mission'), findsOneWidget);
    expect(
      find.text(
        'To empower partner LGUs and health facilities through effective use of digital health technology and generation and sharing of quality electronic data for universal usability towards self-reliance.',
      ),
      findsOneWidget,
    );
    expect(find.text('Board of Trustees'), findsOneWidget);
    expect(find.text('Oscar F. Picazo'), findsOneWidget);
    expect(find.text('A decade of impact'), findsOneWidget);
    expect(find.text('Back to Profile'), findsOneWidget);
  });

  testWidgets('back button returns to the previous screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _AboutUsLauncher()));

    expect(find.text('Open about us'), findsOneWidget);

    await tester.tap(find.text('Open about us'));
    await tester.pumpAndSettle();

    expect(find.text('About Us'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Open about us'), findsOneWidget);
    expect(find.text('About Us'), findsNothing);
  });
}
