import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/profile/presentation/screens/personal_information_screen.dart';

void main() {
  setUp(() {
    AuthSession.clear();
  });

  testWidgets(
    'renders the expanded patient profile screen with completion guidance',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PersonalInformationScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsWidgets);
      expect(find.text('Profile completion first'), findsNothing);
      expect(find.text('Sync records locked'), findsOneWidget);
      expect(find.text('Required profile details'), findsOneWidget);
      expect(find.text('PhilHealth ID or PhilSys ID'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('Identifiers'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Optional details'), findsOneWidget);
      expect(find.text('WAH facility sync coming soon'), findsNothing);
      expect(find.text('Sync records'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      final syncButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Sync records'),
      );
      expect(syncButton.onPressed, isNull);
      final resetButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Reset'),
      );
      expect(
        resetButton.style?.backgroundColor?.resolve(<MaterialState>{}),
        AppColors.surface,
      );
      expect(
        resetButton.style?.foregroundColor?.resolve(<MaterialState>{}),
        AppColors.textPrimary,
      );
      expect(find.text('First name *'), findsOneWidget);
      expect(find.text('Last name *'), findsOneWidget);
      expect(find.text('Birth date *'), findsOneWidget);
      expect(find.text('Gender *'), findsOneWidget);
      expect(find.text('Phone number *'), findsOneWidget);
      expect(find.text('PhilHealth ID'), findsOneWidget);
      expect(find.text('PhilSys ID'), findsOneWidget);
      expect(find.text('Address line 1 *'), findsOneWidget);
      expect(find.text('City / municipality *'), findsOneWidget);
      expect(find.text('Province *'), findsOneWidget);
      expect(find.text('Postal code *'), findsOneWidget);
      expect(find.text('Country *'), findsOneWidget);
      expect(find.text('Emergency contact phone'), findsOneWidget);
    },
  );
}
