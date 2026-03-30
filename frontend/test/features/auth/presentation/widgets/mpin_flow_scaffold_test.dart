import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/widgets/ui/buttons/primary_button_widget.dart';
import 'package:frontend/core/widgets/ui/buttons/secondary_button_widget.dart';
import 'package:frontend/features/auth/presentation/widgets/mpin_flow_scaffold.dart';
import 'package:frontend/features/auth/presentation/widgets/mpin_numeric_keypad.dart';
import 'package:frontend/features/auth/presentation/widgets/mpin_pin_indicator.dart';

void main() {
  testWidgets('renders the unified mpin flow scaffold', (
    WidgetTester tester,
  ) async {
    var backPressed = false;
    var secondaryPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: MpinFlowScaffold(
          title: 'App Locked',
          subtitle: 'Enter your MPIN to continue securely.',
          surfaceTitle: 'Unlock with MPIN',
          surfaceSubtitle: 'Use the 4-digit code saved on this device.',
          heroIcon: Icons.lock_outline,
          onBackPressed: () {
            backPressed = true;
          },
          content: const Text('Content body'),
          primaryAction: PrimaryButtonWidget(
            text: 'Unlock App',
            onPressed: () {},
            icon: Icons.lock_open,
          ),
          secondaryAction: SecondaryButtonWidget(
            text: 'Sign out',
            onPressed: () {
              secondaryPressed = true;
            },
            icon: Icons.logout,
            textColor: AppColors.danger,
          ),
        ),
      ),
    );

    expect(find.text('App Locked'), findsOneWidget);
    expect(find.text('Enter your MPIN to continue securely.'), findsOneWidget);
    expect(find.text('Unlock with MPIN'), findsOneWidget);
    expect(
      find.text('Use the 4-digit code saved on this device.'),
      findsOneWidget,
    );
    expect(find.text('Content body'), findsOneWidget);
    expect(find.text('Unlock App'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    expect(backPressed, isTrue);

    await tester.tap(find.text('Sign out'));
    await tester.pump();
    expect(secondaryPressed, isTrue);
  });

  testWidgets('fits the mpin flow on a compact phone viewport', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(380, 799));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MpinFlowScaffold(
          title: 'Enter your MPIN',
          subtitle: 'Continue securely on this device.',
          surfaceTitle: 'Enter your MPIN',
          surfaceSubtitle: '',
          heroIcon: Icons.lock_outline,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MpinPinIndicator(filledCount: 0, isError: false),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: MpinNumericKeypad(
                    onDigitTap: (_) {},
                    onDeleteTap: () {},
                    showBiometricButton: false,
                  ),
                ),
              ),
            ],
          ),
          primaryAction: PrimaryButtonWidget(
            text: 'Continue',
            onPressed: () {},
            icon: Icons.arrow_forward,
          ),
          secondaryAction: SecondaryButtonWidget(
            text: 'Sign out',
            onPressed: () {},
            icon: Icons.logout,
            textColor: AppColors.danger,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
