import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../models/appointment_booking_models.dart';
import 'appointment_step_header.dart';

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
        const AppointmentSectionLabel('CONSULTATION TYPE'),
        ...appointmentModeOptions.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppointmentSelectableRow(
              icon: option.icon,
              iconColor: option.mode == AppointmentBookingMode.onsite
                  ? AppColors.primary
                  : AppColors.secondary,
              title: option.title,
              subtitle: option.description,
              isSelected: selectedMode == option.mode,
              onTap: () => onChanged(option.mode),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can change this later if needed.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
