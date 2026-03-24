import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('shows numeric hints and moves back on backspace', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OtpCodeField(autofocus: false))),
    );

    final textFields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(
      textFields
          .asMap()
          .entries
          .map((entry) => entry.value.decoration?.hintText)
          .toList(growable: false),
      equals(<String>['1', '2', '3', '4', '5', '6']),
    );

    await tester.enterText(find.byType(TextField).at(4), '5');
    await tester.enterText(find.byType(TextField).at(5), '6');
    await tester.pump();

    await tester.tap(find.byType(TextField).at(5));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    final updatedFields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(updatedFields[4].controller?.text ?? '', isEmpty);
    expect(updatedFields[5].controller?.text ?? '', isEmpty);
  });

  testWidgets('splits pasted otp digits across boxes and keeps focus', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: OtpCodeField(autofocus: false))),
    );

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();

    final updatedFields = tester.widgetList<TextField>(find.byType(TextField));
    expect(
      updatedFields
          .map((field) => field.controller?.text ?? '')
          .toList(growable: false),
      equals(<String>['1', '2', '3', '4', '5', '6']),
    );
    expect(FocusManager.instance.primaryFocus, isNotNull);
  });
}
