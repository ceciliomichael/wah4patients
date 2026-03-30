import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/presentation/screens/registration_personal_details_screen.dart';
import 'package:frontend/features/auth/presentation/widgets/auth_surface_card.dart';

void main() {
  testWidgets(
    'renders personal details fields outside a card and shows requirement labels',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegistrationPersonalDetailsScreen(
            email: 'patient@example.com',
            registrationToken: 'token-123',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AuthSurfaceCard), findsNothing);
      expect(find.text('Tell us your name'), findsOneWidget);
      expect(find.text('First name *'), findsOneWidget);
      expect(find.text('Second name (Optional)'), findsOneWidget);
      expect(find.text('Middle name (Optional)'), findsOneWidget);
      expect(find.text('Last name *'), findsOneWidget);
      expect(find.text('Continue to Password'), findsOneWidget);
      expect(find.text('Back'), findsWidgets);
      expect(find.byTooltip('Back'), findsOneWidget);
    },
  );
}
