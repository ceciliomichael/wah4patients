import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class MpinPinIndicator extends StatelessWidget {
  const MpinPinIndicator({
    super.key,
    required this.filledCount,
    this.length = 4,
    this.isError = false,
  });

  final int filledCount;
  final int length;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(length, (index) {
        final bool isFilled = index < filledCount;
        final Color borderColor = isError
            ? AppColors.danger
            : (isFilled ? AppColors.primary : AppColors.border);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? (isError ? AppColors.danger : AppColors.primary)
                : AppColors.surface,
            border: Border.all(color: borderColor, width: isFilled ? 2 : 1.3),
          ),
        );
      }),
    );
  }
}
