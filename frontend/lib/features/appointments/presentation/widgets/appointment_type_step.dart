import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../models/appointment_booking_models.dart';

class AppointmentTypeStep extends StatelessWidget {
  const AppointmentTypeStep({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AppointmentTypeOption> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(options.length, (index) {
        final option = options[index];
        final isSelected = selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: isSelected
                ? option.accentColor.withValues(alpha: 0.05)
                : AppColors.surface,
            borderRadius: AppRadii.large,
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: AppRadii.large,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: AppRadii.large,
                  border: Border.all(
                    color: isSelected ? option.accentColor : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: option.accentColor.withValues(alpha: 0.12),
                        borderRadius: AppRadii.medium,
                      ),
                      child: Icon(
                        option.icon,
                        color: option.accentColor,
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
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? option.accentColor
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
