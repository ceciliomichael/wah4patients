import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../domain/onboarding_page_repository.dart';
import '../widgets/onboarding_base_screen.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: OnboardingBaseScreen(
          pageData: OnboardingPageRepository.page1,
          onSkipPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding4),
          onActionPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding2),
        ),
      ),
    );
  }
}
