import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_border_radii.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../models/body_mass_index_models.dart';

class BodyMassIndexUnitToggle extends StatelessWidget {
  const BodyMassIndexUnitToggle({
    super.key,
    required this.unitSystem,
    required this.onUnitSystemChanged,
  });

  final BmiUnitSystem unitSystem;
  final ValueChanged<BmiUnitSystem> onUnitSystemChanged;

  @override
  Widget build(BuildContext context) {
    final isMetric = unitSystem == BmiUnitSystem.metric;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              label: 'Metric (kg/cm)',
              selected: isMetric,
              selectedColor: AppColors.primary,
              onTap: () => onUnitSystemChanged(BmiUnitSystem.metric),
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.border),
          Expanded(
            child: _buildSegment(
              label: 'Imperial (lb/in)',
              selected: !isMetric,
              selectedColor: AppColors.secondary,
              onTap: () => onUnitSystemChanged(BmiUnitSystem.imperial),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required bool selected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color:
            selected ? selectedColor.withValues(alpha: 0.12) : Colors.transparent,
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
