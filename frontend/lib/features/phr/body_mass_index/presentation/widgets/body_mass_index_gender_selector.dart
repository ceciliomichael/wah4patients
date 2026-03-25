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
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.large,
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _GenderSegment(
                  label: 'Male',
                  selected: selectedGender == BmiGender.male,
                  selectedColor: AppColors.primary,
                  onTap: () => onGenderChanged(BmiGender.male),
                ),
              ),
              Container(width: 1, height: 48, color: AppColors.border),
              Expanded(
                child: _GenderSegment(
                  label: 'Female',
                  selected: selectedGender == BmiGender.female,
                  selectedColor: AppColors.secondary,
                  onTap: () => onGenderChanged(BmiGender.female),
                ),
              ),
              Container(width: 1, height: 48, color: AppColors.border),
              Expanded(
                child: _GenderSegment(
                  label: 'Other',
                  selected: selectedGender == BmiGender.other,
                  selectedColor: AppColors.tertiary,
                  onTap: () => onGenderChanged(BmiGender.other),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderSegment extends StatelessWidget {
  const _GenderSegment({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? selectedColor.withValues(alpha: 0.12)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? selectedColor : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
