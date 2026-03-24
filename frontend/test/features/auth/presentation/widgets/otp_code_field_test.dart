import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/domain/auth_validators.dart';
import 'package:frontend/features/auth/presentation/widgets/otp_code_field.dart';

void main() {
  testWidgets('renders six otp boxes and supports validation reset', (
    WidgetTester tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final otpFieldKey = GlobalKey<FormFieldState<String>>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: OtpCodeField(
              key: otpFieldKey,
              autofocus: false,
              validator: validateOtp,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(6));

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();

    final populatedFields = tester.widgetList<TextField>(
      find.byType(TextField),
    );
    expect(
      populatedFields
          .map((field) => field.controller?.text ?? '')
          .toList(growable: false),
      equals(<String>['1', '2', '3', '4', '5', '6']),
    );
    expect(formKey.currentState?.validate(), isTrue);

    otpFieldKey.currentState?.reset();
    await tester.pump();

    final clearedFields = tester.widgetList<TextField>(find.byType(TextField));
    expect(
      clearedFields.every((field) => (field.controller?.text ?? '').isEmpty),
      isTrue,
    );
  });
}
