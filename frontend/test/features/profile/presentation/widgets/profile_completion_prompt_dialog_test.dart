import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/widgets/ui/buttons/primary_button_widget.dart';
import 'package:frontend/features/profile/presentation/widgets/profile_completion_prompt_dialog.dart';

void main() {
  testWidgets('renders the profile completion prompt with both actions', (
    WidgetTester tester,
  ) async {
    var completePressed = false;
    var skipPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ProfileCompletionPromptDialog(
                  onCompleteProfile: () {
                    completePressed = true;
                  },
                  onSkipForNow: () {
                    skipPressed = true;
                  },
                  onClose: () {},
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Complete profile'), findsWidgets);
    expect(
      find.textContaining('future WAH facility sync'),
      findsOneWidget,
    );
    expect(find.text('Skip for now'), findsOneWidget);

    await tester.tap(find.text('Skip for now'));
    await tester.pump();
    expect(skipPressed, isTrue);

    await tester.tap(find.byType(PrimaryButtonWidget));
    await tester.pump();
    expect(completePressed, isTrue);
  });
}
