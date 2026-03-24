import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_border_radii.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../models/body_mass_index_models.dart';

class BodyMassIndexGenderSelector extends StatelessWidget {
  const BodyMassIndexGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  final BmiGender selectedGender;
  final ValueChanged<BmiGender> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BmiGender.values.map((gender) {
            final isSelected = selectedGender == gender;
            return ChoiceChip(
              label: Text(gender.label),
              selected: isSelected,
              selectedColor: AppColors.secondary.withValues(alpha: 0.1),
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onGenderChanged(gender),
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
