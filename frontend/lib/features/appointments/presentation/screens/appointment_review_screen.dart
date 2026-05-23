import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../models/appointment_booking_models.dart';
import '../widgets/appointment_step_header.dart';

class AppointmentReviewScreen extends StatelessWidget {
  const AppointmentReviewScreen({super.key, required this.summary});

  final AppointmentBookingSummary summary;

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => HelpModalWidget(
        title: 'Review Booking Help',
        messages: const [
          'Check each detail carefully before you confirm.',
          'Use Back to return and change anything if needed.',
          'Confirming sends the request to your chosen provider.',
        ],
        icons: const [
          Icons.fact_check_outlined,
          Icons.edit_outlined,
          Icons.check_circle_outline,
        ],
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 24.0;
    final notes = summary.notes.trim();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppScreenHeader(
                title: 'Review Request',
                isTablet: isTablet,
                topPadding: 24.0,
                onBackPressed: () => Navigator.of(context).pop(),
                onHelpPressed: () => _showHelpDialog(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 24, bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: summary.mode.accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              summary.mode.icon,
                              color: summary.mode.accentColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  summary.mode.title,
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Review your details before sending the request to ${summary.provider.name}.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Details list
                      const AppointmentSectionLabel('APPOINTMENT DETAILS'),
                      _buildDetailRow('Type', summary.consultationType.title),
                      _buildDetailRow('Date', _formatDate(summary.date)),
                      _buildDetailRow('Time', summary.timeSlot),
                      if (summary.mode == AppointmentBookingMode.teleconsultation)
                        _buildDetailRow('Platform', summary.location),
                      _buildDetailRow('Provider', summary.provider.name),
                      _buildDetailRow('Location', '${summary.provider.facilityCode} • ${summary.provider.location}'),
                      
                      const SizedBox(height: 32),
                      const AppointmentSectionLabel('YOUR INFO'),
                      _buildDetailRow('Patient ID', summary.patientIdentifier.value),
                      _buildDetailRow('Reason', summary.reason),
                      if (notes.isNotEmpty) _buildDetailRow('Notes', notes),
                      if (summary.mode == AppointmentBookingMode.teleconsultation)
                        _buildDetailRow(
                          'Readiness',
                          summary.teleReady ? 'Confirmed connection & device' : 'Not confirmed',
                        ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButtonWidget(
                      text: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                      textColor: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButtonWidget(
                      text: 'Send Request',
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
