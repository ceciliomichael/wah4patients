import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../domain/onboarding_page_repository.dart';
import '../widgets/onboarding_base_screen.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: OnboardingBaseScreen(
          pageData: OnboardingPageRepository.page2,
          onSkipPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding4),
          onActionPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding3),
        ),
      ),
    );
  }
}
