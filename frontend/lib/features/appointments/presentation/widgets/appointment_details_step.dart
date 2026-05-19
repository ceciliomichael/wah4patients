import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../interoperability/domain/interoperability_models.dart';
import '../models/appointment_booking_models.dart';

class AppointmentDetailsStep extends StatelessWidget {
  const AppointmentDetailsStep({
    super.key,
    required this.mode,
    required this.provider,
    required this.locationOptions,
    required this.selectedLocation,
    required this.reasonController,
    required this.notesController,
    required this.teleReady,
    required this.onLocationChanged,
    required this.onTeleReadyChanged,
  });

  final AppointmentBookingMode mode;
  final InteroperabilityProviderSummary provider;
  final List<AppointmentLocationOption> locationOptions;
  final String? selectedLocation;
  final TextEditingController reasonController;
  final TextEditingController notesController;
  final bool teleReady;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<bool> onTeleReadyChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Provider',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.extraLarge,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.large,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.local_hospital_outlined,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.facilityCode} • ${provider.location}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          mode.locationLabel,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: locationOptions.map((option) {
            final isSelected = selectedLocation == option.label;
            return ChoiceChip(
              label: Text(option.label),
              selected: isSelected,
              selectedColor: AppColors.textPrimary.withValues(alpha: 0.06),
              labelStyle: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => onLocationChanged(option.label),
              side: BorderSide(
                color: isSelected ? AppColors.textPrimary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
            );
          }).toList(growable: false),
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
                activeColor: AppColors.textPrimary,
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
