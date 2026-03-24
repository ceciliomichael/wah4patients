import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/wah4p_app.dart';
import 'package:frontend/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('shows splash then advances to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const WAH4PApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Healthier,'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.textContaining('Your health records'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
