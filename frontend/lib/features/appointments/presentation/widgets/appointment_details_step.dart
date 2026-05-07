import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/inputs/bottom_sheet_select_form_field.dart';
import '../models/appointment_booking_models.dart';

class AppointmentDetailsStep extends StatelessWidget {
  const AppointmentDetailsStep({
    super.key,
    required this.mode,
    required this.locationOptions,
    required this.providerOptions,
    required this.selectedLocation,
    required this.selectedProvider,
    required this.reasonController,
    required this.notesController,
    required this.teleReady,
    required this.onLocationChanged,
    required this.onProviderChanged,
    required this.onTeleReadyChanged,
  });

  final AppointmentBookingMode mode;
  final List<AppointmentLocationOption> locationOptions;
  final List<String> providerOptions;
  final String? selectedLocation;
  final String? selectedProvider;
  final TextEditingController reasonController;
  final TextEditingController notesController;
  final bool teleReady;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<String?> onProviderChanged;
  final ValueChanged<bool> onTeleReadyChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          mode.locationLabel,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        BottomSheetSelectFormField<String>(
          value: selectedLocation,
          options: locationOptions
              .map(
                (option) => BottomSheetSelectOption<String>(
                  value: option.label,
                  label: option.label,
                  description: option.description,
                ),
              )
              .toList(),
          onChanged: onLocationChanged,
          label: mode.locationLabel,
          hintText: mode.locationHint,
          icon: mode.icon,
        ),
        if (selectedLocation != null) ...[
          const SizedBox(height: 8),
          Text(
            locationOptions
                .firstWhere((option) => option.label == selectedLocation)
                .description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Preferred Provider',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        BottomSheetSelectFormField<String>(
          value: selectedProvider,
          options: providerOptions
              .map(
                (provider) => BottomSheetSelectOption<String>(
                  value: provider,
                  label: provider,
                  icon: Icons.person_outline,
                ),
              )
              .toList(),
          onChanged: onProviderChanged,
          label: 'Preferred Provider',
          hintText: 'Select provider',
          icon: Icons.person_search_outlined,
        ),
        const SizedBox(height: 20),
        Text(
          'Reason for Appointment',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: reasonController,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Describe the main reason for the appointment',
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Additional Notes',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: notesController,
          maxLines: 4,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            hintText: 'Add instructions or notes for the care team',
          ),
        ),
        if (mode == AppointmentBookingMode.teleconsultation) ...[
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: teleReady,
                activeColor: AppColors.secondary,
                onChanged: (value) => onTeleReadyChanged(value ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'I am ready for a remote consultation and have a stable device or connection available.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
