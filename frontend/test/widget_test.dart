import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/wah4p_app.dart';
import 'package:frontend/app/startup_gate_screen.dart';

void main() {
  testWidgets('shows splash then advances to onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const WAH4PApp());

    expect(find.byType(StartupGateScreen), findsOneWidget);
    expect(find.text('Starting WAH for Patients'), findsOneWidget);
  });
}
