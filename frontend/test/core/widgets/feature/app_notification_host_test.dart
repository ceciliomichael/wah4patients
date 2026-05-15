import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/app/app_notification_center.dart';
import 'package:frontend/core/widgets/feature/app_notification_host.dart';

void main() {
  setUp(() {
    AppNotificationCenter.instance.dismiss();
  });

  tearDown(() {
    AppNotificationCenter.instance.dismiss();
  });

  testWidgets('shows notifications at the top and dismisses them', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              const SizedBox.expand(),
              AppNotificationHost(controller: AppNotificationCenter.instance),
            ],
          ),
        ),
      ),
    );

    AppNotificationCenter.instance.showSuccess(
      'Profile updated successfully.',
      duration: const Duration(seconds: 1),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Profile updated successfully.'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    final messageTopLeft = tester.getTopLeft(
      find.text('Profile updated successfully.'),
    );
    expect(messageTopLeft.dy, lessThan(140));

    await tester.drag(
      find.text('Profile updated successfully.'),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile updated successfully.'), findsNothing);

    AppNotificationCenter.instance.dismiss();
    await tester.pumpAndSettle();

    expect(find.text('Profile updated successfully.'), findsNothing);
  });
}
