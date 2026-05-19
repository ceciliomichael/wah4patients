import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../models/appointment_booking_models.dart';

class AppointmentModeStep extends StatelessWidget {
  const AppointmentModeStep({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  final AppointmentBookingMode? selectedMode;
  final ValueChanged<AppointmentBookingMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Choose consultation mode',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start with the simplest option, then the app will guide you through scheduling, provider lookup, and the final request.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ...appointmentModeOptions.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: selectedMode == option.mode
                  ? AppColors.textPrimary.withValues(alpha: 0.06)
                  : AppColors.surface,
              borderRadius: AppRadii.large,
              child: InkWell(
                onTap: () => onChanged(option.mode),
                borderRadius: AppRadii.large,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.large,
                    border: Border.all(
                      color: selectedMode == option.mode
                          ? AppColors.textPrimary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: selectedMode == option.mode
                              ? AppColors.textPrimary.withValues(alpha: 0.08)
                              : AppColors.surfaceVariant,
                          borderRadius: AppRadii.medium,
                        ),
                        child: Icon(
                          option.icon,
                          color: AppColors.textPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        selectedMode == option.mode
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selectedMode == option.mode
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
