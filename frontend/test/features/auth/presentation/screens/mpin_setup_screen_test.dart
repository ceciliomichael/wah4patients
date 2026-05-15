import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/app_router.dart';
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

  testWidgets('continues into MPIN confirmation without a route type crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: buildAppRoute,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.mpinSetup,
                      arguments: const MpinSetupArguments(
                        nextRouteAfterSave: AppRoutes.totpSetup,
                        nextRouteArguments: TotpSetupScreenArguments(
                          allowSkip: true,
                        ),
                      ),
                    );
                  },
                  child: const Text('Open MPIN setup'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Open MPIN setup'));
    await tester.pumpAndSettle();

    expect(find.text('Create MPIN'), findsOneWidget);

    for (final digit in <String>['1', '2', '3', '4']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm MPIN'), findsOneWidget);
  });
}
