import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../interoperability/domain/interoperability_models.dart';
import '../models/appointment_booking_models.dart';
import 'appointment_step_header.dart';

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
        // Provider summary — inline, no card
        AppointmentSectionLabel(
          mode == AppointmentBookingMode.onsite ? 'VISITING' : 'CONSULTING WITH',
        ),
        _ProviderSummaryRow(provider: provider),
        const SizedBox(height: 28),

        // Location / platform
        if (mode == AppointmentBookingMode.teleconsultation) ...[
          const AppointmentSectionLabel('PLATFORM'),
          ...locationOptions.map((option) {
            final isSelected = selectedLocation == option.label;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LocationChip(
                label: option.label,
                description: option.description,
                isSelected: isSelected,
                onTap: () => onLocationChanged(option.label),
              ),
            );
          }),
          const SizedBox(height: 28),
        ],

        // Reason
        const AppointmentSectionLabel('REASON FOR VISIT'),
        _StyledTextField(
          controller: reasonController,
          hintText: 'Briefly describe why you are booking this appointment',
          maxLines: 3,
        ),
        const SizedBox(height: 28),

        // Notes
        const AppointmentSectionLabel('ADDITIONAL NOTES (OPTIONAL)'),
        _StyledTextField(
          controller: notesController,
          hintText: 'Anything else your doctor should know',
          maxLines: 4,
        ),

        // Tele-readiness (only for teleconsultation)
        if (mode == AppointmentBookingMode.teleconsultation) ...[
          const SizedBox(height: 24),
          _TeleReadinessRow(
            value: teleReady,
            onChanged: onTeleReadyChanged,
          ),
        ],
      ],
    );
  }
}

class _ProviderSummaryRow extends StatelessWidget {
  const _ProviderSummaryRow({required this.provider});

  final InteroperabilityProviderSummary provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.local_hospital_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.name,
                style: AppTextStyles.titleMedium.copyWith(
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
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.05)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.border,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.border,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _TeleReadinessRow extends StatelessWidget {
  const _TeleReadinessRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: value
          ? AppColors.secondary.withValues(alpha: 0.05)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value ? AppColors.secondary : AppColors.border,
              width: value ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                value ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: value ? AppColors.secondary : AppColors.border,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'I have a stable device and internet connection for this teleconsultation.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
