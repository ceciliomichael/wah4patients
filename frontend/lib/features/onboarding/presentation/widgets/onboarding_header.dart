import 'package:flutter/material.dart';

import '../../../../core/widgets/ui/indicators/page_indicator_widget.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.fadeAnimation,
  });

  final int currentPage;
  final int pageCount;
  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PageIndicatorStyles.onboarding(
                currentPage: currentPage,
                pageCount: pageCount,
              ),
            ],
          ),
        );
      },
    );
  }
}
