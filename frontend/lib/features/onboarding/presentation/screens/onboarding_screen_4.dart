import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../domain/onboarding_page_repository.dart';
import '../widgets/onboarding_base_screen.dart';

class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: OnboardingBaseScreen(
          pageData: OnboardingPageRepository.page4,
          onSkipPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.registration),
          onActionPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.registration),
        ),
      ),
    );
  }
}
