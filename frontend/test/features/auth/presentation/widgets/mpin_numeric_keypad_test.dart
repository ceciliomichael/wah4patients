import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/presentation/widgets/mpin_numeric_keypad.dart';

void main() {
  testWidgets('renders a ripple-free keypad and forwards taps', (
    WidgetTester tester,
  ) async {
    final tappedDigits = <String>[];
    var deleteTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            child: MpinNumericKeypad(
              onDigitTap: tappedDigits.add,
              onDeleteTap: () {
                deleteTapped = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(InkWell), findsNothing);

    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('0'));
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    expect(tappedDigits, equals(<String>['1', '2', '0']));
    expect(deleteTapped, isTrue);
  });
}
