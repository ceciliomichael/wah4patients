import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../dashboard/domain/dashboard_models.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DashboardServiceCard extends StatelessWidget {
  const DashboardServiceCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final DashboardServiceCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: data.accentColor.withValues(alpha: 0.08),
      borderRadius: AppRadii.large,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.large,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.medium,
                ),
                child: Icon(data.icon, size: 28, color: data.accentColor),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
