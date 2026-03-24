import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class PageIndicatorStyles {
  PageIndicatorStyles._();

  static Widget onboarding({
    required int currentPage,
    required int pageCount,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
