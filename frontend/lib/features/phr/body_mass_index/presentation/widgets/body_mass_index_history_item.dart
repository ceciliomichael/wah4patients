import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_border_radii.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../models/body_mass_index_models.dart';
import '../utils/body_mass_index_calculations.dart';

class BodyMassIndexHistoryItem extends StatelessWidget {
  const BodyMassIndexHistoryItem({super.key, required this.entry});

  final BodyMassIndexHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final categoryColor = bmiCategoryColor(entry.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: AppRadii.medium,
            ),
            child: Icon(
              Icons.monitor_weight_outlined,
              color: categoryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.bmi.toStringAsFixed(1)} BMI',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatMeasurement(entry)} · ${entry.gender.label} · ${entry.age} yrs',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            formatDate(entry.recordedAt),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
