import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/calendar_event.dart';

class EventTypeFilterWidget extends StatelessWidget {
  const EventTypeFilterWidget({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final EventType? selectedType;
  final ValueChanged<EventType?> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SizedBox(
      height: isSmallScreen ? 40.0 : 48.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                'All',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: isSmallScreen ? 12.0 : 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: selectedType == null,
              onSelected: (selected) {
                if (selected) {
                  onTypeSelected(null);
                }
              },
              backgroundColor: AppColors.background,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTextStyles.labelLarge.copyWith(
                color: selectedType == null ? AppColors.primary : AppColors.black,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: selectedType == null ? AppColors.primary : Colors.transparent,
                ),
              ),
            ),
          ),
          ...EventType.values.map((type) {
            final isSelected = selectedType == type;
            final typeColor = type.color;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(
                  type.label,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: isSmallScreen ? 12.0 : 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  onTypeSelected(selected ? type : null);
                },
                backgroundColor: AppColors.background,
                selectedColor: typeColor.withValues(alpha: 0.15),
                checkmarkColor: typeColor,
                labelStyle: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? typeColor : AppColors.black,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                    color: isSelected ? typeColor : Colors.transparent,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
