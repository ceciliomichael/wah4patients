import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/app_routes.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/auth/presentation/screens/mpin_setup_screen.dart';

void main() {
  testWidgets('signup mpin setup does not expose a back escape', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MpinSetupScreen(
          arguments: const MpinSetupArguments(
            nextRouteAfterSave: AppRoutes.totpSetup,
            nextRouteArguments: TotpSetupScreenArguments(allowSkip: true),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Create MPIN'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    expect(
      find.text('Complete MPIN setup to continue registration.'),
      findsNothing,
    );
  });
}
