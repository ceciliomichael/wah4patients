import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_border_radii.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../models/body_mass_index_models.dart';
import '../utils/body_mass_index_calculations.dart';

class BodyMassIndexResultDialog extends StatelessWidget {
  const BodyMassIndexResultDialog({
    super.key,
    required this.entry,
    required this.onConfirmPressed,
  });

  final BodyMassIndexHistoryEntry entry;
  final VoidCallback onConfirmPressed;

  @override
  Widget build(BuildContext context) {
    final categoryColor = bmiCategoryColor(entry.category);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.calculate, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Your BMI Result',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: AppRadii.large,
              ),
              child: Column(
                children: [
                  Text(
                    entry.bmi.toStringAsFixed(1),
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    entry.category.toUpperCase(),
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Date: ${formatDate(entry.recordedAt)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Time: ${formatTime(entry.recordedAt)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'BMI is a simple estimate and does not account for body composition.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        PrimaryButtonWidget(
          text: 'OK',
          onPressed: onConfirmPressed,
          fullWidth: false,
          size: AppButtonSize.small,
        ),
      ],
    );
  }
}
