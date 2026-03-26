import 'package:flutter/material.dart';

import '../../../constants/app_border_radii.dart';
import '../../../constants/app_colors.dart';

class PageIndicatorStyles {
  PageIndicatorStyles._();

  static Widget onboarding({required int currentPage, required int pageCount}) {
    return onboardingWithProgress(
      pageProgress: currentPage.toDouble(),
      pageCount: pageCount,
    );
  }

  static Widget onboardingWithProgress({
    required double pageProgress,
    required int pageCount,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(pageCount, (index) {
        final distance = (pageProgress - index).abs().clamp(0.0, 1.0);
        final activation = 1.0 - distance;
        final width = 8.0 + (12.0 * activation);
        final alpha = 0.45 + (0.55 * activation);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: width,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: alpha),
            borderRadius: AppRadii.pill,
          ),
        );
      }),
    );
  }
}
