import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../dashboard/domain/dashboard_models.dart';

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({super.key, required this.data, this.onTap});

  final DashboardMetricData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEmpty = !data.hasData;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.large,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: data.accentColor.withValues(alpha: 0.08),
            borderRadius: AppRadii.large,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.small,
                    ),
                    child: Icon(data.icon, size: 20, color: data.accentColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _MetricTag(
                    label: isEmpty ? 'No data' : 'This week',
                    accentColor: data.accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (isEmpty) ...<Widget>[
                Text(
                  'No records this week',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: data.accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add a new entry in Personal Records.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ] else ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      data.value,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: data.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        data.unit,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: data.accentColor.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _formatEntryCount(data.entryCount),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatEntryCount(int count) {
    if (count == 1) {
      return '1 reading this week';
    }

    return '$count readings this week';
  }
}

class _MetricTag extends StatelessWidget {
  const _MetricTag({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
