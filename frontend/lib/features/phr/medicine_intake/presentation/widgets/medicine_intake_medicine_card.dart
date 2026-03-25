import 'package:flutter/material.dart';

import '../../../../../core/constants/app_border_radii.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../domain/medicine_status.dart';
import '../models/medicine_intake_models.dart';

class MedicineIntakeMedicineCard extends StatelessWidget {
  const MedicineIntakeMedicineCard({
    super.key,
    required this.entry,
    required this.isExpanded,
    required this.onTap,
  });

  final MedicineIntakeEntry entry;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = entry.status.color;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.extraLarge,
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: AppRadii.extraLarge,
                  ),
                  child: Icon(
                    entry.status.icon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.dosage,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              label: 'Schedule',
              value: entry.schedule,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),
            _buildDetailRow(
              label: 'Next dose',
              value: entry.nextDose,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),
            _buildDetailRow(
              label: 'Status',
              value: entry.status.label,
              valueColor: statusColor,
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
              _buildNotesSection(entry.notes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          notes,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    TextAlign valueTextAlign = TextAlign.end,
    TextStyle? valueStyle,
    bool valueExpanded = false,
  }) {
    final resolvedValueStyle = valueStyle ??
        AppTextStyles.titleSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: valueColor ?? AppColors.textPrimary,
        );

    return Row(
      crossAxisAlignment: valueExpanded
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
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
        if (valueExpanded)
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: valueTextAlign,
              style: resolvedValueStyle,
            ),
          )
        else
          Text(
            value,
            textAlign: valueTextAlign,
            style: resolvedValueStyle,
          ),
      ],
    );
  }
}
