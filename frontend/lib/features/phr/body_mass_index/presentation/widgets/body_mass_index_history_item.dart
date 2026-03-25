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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.extraLarge,
                ),
                child: Icon(
                  Icons.monitor_weight_outlined,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Reading',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHistoryRow(
            label: 'BMI',
            value: entry.bmi.toStringAsFixed(1),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildHistoryRow(
            label: 'Measurement',
            value: formatMeasurement(entry),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildHistoryRow(
            label: 'Category',
            value: entry.category,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildHistoryRow(
            label: 'Recorded on',
            value: formatDate(entry.recordedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          textAlign: TextAlign.end,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
