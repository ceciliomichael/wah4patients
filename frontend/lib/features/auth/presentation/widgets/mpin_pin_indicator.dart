import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class MpinPinIndicator extends StatelessWidget {
  const MpinPinIndicator({
    super.key,
    required this.filledCount,
    this.length = 4,
    this.isError = false,
    this.showDigits = false,
    this.displayValue = '',
  });

  final int filledCount;
  final int length;
  final bool isError;
  final bool showDigits;
  final String displayValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(length, (index) {
        final bool isFilled = index < filledCount;
        final Color borderColor = isError
            ? AppColors.danger
            : (isFilled ? AppColors.primary : AppColors.border);

        if (!showDigits) {
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
        }

        final String slotValue = index < displayValue.length
            ? displayValue[index]
            : '';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 42,
          height: 54,
          decoration: BoxDecoration(
            color: isFilled
                ? (isError ? AppColors.danger : AppColors.surfaceVariant)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isFilled ? 1.8 : 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            slotValue,
            style: AppTextStyles.headlineSmall.copyWith(
              color: isError
                  ? AppColors.danger
                  : (isFilled ? AppColors.primary : AppColors.textSecondary),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        );
      }),
    );
  }
}
