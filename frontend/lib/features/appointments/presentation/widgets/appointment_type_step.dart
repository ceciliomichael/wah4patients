import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/appointment_booking_models.dart';
import 'appointment_step_header.dart';

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
      children: [
        const AppointmentSectionLabel('VISIT TYPE'),
        ...List<Widget>.generate(options.length, (index) {
          final option = options[index];
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppointmentSelectableRow(
              icon: option.icon,
              iconColor: option.accentColor,
              title: option.title,
              subtitle: option.description,
              isSelected: isSelected,
              onTap: () => onSelected(index),
            ),
          );
        }),
        const SizedBox(height: 4),
        Text(
          'Not sure? Pick the one closest to your reason for visiting.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
