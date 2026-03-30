import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/profile/presentation/screens/personal_information_screen.dart';

void main() {
  setUp(() {
    AuthSession.clear();
  });

  testWidgets(
    'renders the profile personal information form without a card shell',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PersonalInformationScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Edit name details'), findsOneWidget);
      expect(find.text('First name *'), findsOneWidget);
      expect(find.text('Last name *'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    },
  );
}
