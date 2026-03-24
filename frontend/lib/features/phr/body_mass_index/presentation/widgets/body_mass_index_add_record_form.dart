import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../models/body_mass_index_models.dart';
import '../utils/body_mass_index_calculations.dart';
import 'body_mass_index_age_picker.dart';
import 'body_mass_index_gender_selector.dart';
import 'body_mass_index_measurement_field.dart';
import 'body_mass_index_unit_toggle.dart';

class BodyMassIndexAddRecordForm extends StatelessWidget {
  const BodyMassIndexAddRecordForm({
    super.key,
    required this.unitSystem,
    required this.selectedGender,
    required this.age,
    required this.weightController,
    required this.heightController,
    required this.onUnitSystemChanged,
    required this.onGenderChanged,
    required this.onAgeDecreased,
    required this.onAgeIncreased,
    required this.onCalculatePressed,
  });

  final BmiUnitSystem unitSystem;
  final BmiGender selectedGender;
  final int age;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final ValueChanged<BmiUnitSystem> onUnitSystemChanged;
  final ValueChanged<BmiGender> onGenderChanged;
  final VoidCallback onAgeDecreased;
  final VoidCallback onAgeIncreased;
  final VoidCallback onCalculatePressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyMassIndexUnitToggle(
            unitSystem: unitSystem,
            onUnitSystemChanged: onUnitSystemChanged,
          ),
          const SizedBox(height: 20),
          BodyMassIndexGenderSelector(
            selectedGender: selectedGender,
            onGenderChanged: onGenderChanged,
          ),
          const SizedBox(height: 20),
          BodyMassIndexAgePicker(
            age: age,
            canDecrease: age > 12,
            onDecrease: onAgeDecreased,
            onIncrease: onAgeIncreased,
          ),
          const SizedBox(height: 20),
          BodyMassIndexMeasurementField(
            label: 'Weight (${weightUnitLabel(unitSystem)})',
            controller: weightController,
            hintText: weightHint(unitSystem),
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 20),
          BodyMassIndexMeasurementField(
            label: 'Height (${heightUnitLabel(unitSystem)})',
            controller: heightController,
            hintText: heightHint(unitSystem),
            icon: Icons.height_outlined,
          ),
          const SizedBox(height: 28),
          PrimaryButtonWidget(
            text: 'CALCULATE BMI',
            onPressed: onCalculatePressed,
          ),
          const SizedBox(height: 12),
          Text(
            'Enter height and weight to calculate BMI.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
