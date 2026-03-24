import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AppointmentScheduleStep extends StatelessWidget {
  const AppointmentScheduleStep({
    super.key,
    required this.selectedDateIndex,
    required this.selectedTimeSlot,
    required this.dateOptions,
    required this.timeSlots,
    required this.onDateSelected,
    required this.onTimeSlotSelected,
  });

  final int? selectedDateIndex;
  final String? selectedTimeSlot;
  final List<DateTime> dateOptions;
  final List<String> timeSlots;
  final ValueChanged<int> onDateSelected;
  final ValueChanged<String> onTimeSlotSelected;

  String _weekdayLabel(DateTime date) {
    return switch (date.weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      _ => 'Sun',
    };
  }

  String _monthLabel(DateTime date) {
    return switch (date.month) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mar',
      4 => 'Apr',
      5 => 'May',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sep',
      10 => 'Oct',
      11 => 'Nov',
      _ => 'Dec',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Available Dates',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dateOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final date = dateOptions[index];
              final isSelected = selectedDateIndex == index;

              return Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : AppColors.surface,
                borderRadius: AppRadii.large,
                child: InkWell(
                  onTap: () => onDateSelected(index),
                  borderRadius: AppRadii.large,
                  child: Container(
                    width: 84,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.large,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekdayLabel(date),
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 13,
                            height: 1.0,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontSize: 18,
                            height: 1.0,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _monthLabel(date),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11,
                            height: 1.0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Time Slots',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: timeSlots.map((slot) {
            final isSelected = selectedTimeSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              selectedColor: AppColors.secondary.withValues(alpha: 0.12),
              labelStyle: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onTimeSlotSelected(slot),
              side: BorderSide(
                color: isSelected ? AppColors.secondary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
            );
          }).toList(),
        ),
      ],
    );
  }
}
