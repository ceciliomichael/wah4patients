import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('shows branding on the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    await tester.pump(const Duration(seconds: 2));

    expect(find.text('WAH for Patients'), findsOneWidget);
    expect(find.text('Healthier,'), findsOneWidget);
    expect(find.text('Happier'), findsOneWidget);
    expect(find.text('Communities'), findsOneWidget);
  });
}
