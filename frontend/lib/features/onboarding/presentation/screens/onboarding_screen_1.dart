import 'package:flutter/material.dart';

import 'onboarding_flow_screen.dart';

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingFlowScreen(initialPageIndex: 0);
  }
}
