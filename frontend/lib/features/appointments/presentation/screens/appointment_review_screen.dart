import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../models/appointment_booking_models.dart';

class AppointmentReviewScreen extends StatelessWidget {
  const AppointmentReviewScreen({super.key, required this.summary});

  final AppointmentBookingSummary summary;

  String _formatDate(DateTime date) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: 'Review Booking Help',
          messages: <String>[
            'Check each booking detail carefully before you confirm.',
            'Use Back to return to the previous step if you want to change something.',
            'Confirming here keeps the flow readable before any backend write is added.',
          ],
          icons: const <IconData>[
            Icons.fact_check_outlined,
            Icons.edit_outlined,
            Icons.check_circle_outline,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
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

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
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
                title: summary.mode.reviewTitle,
                isTablet: isTablet,
                topPadding: 24.0,
                onBackPressed: () => Navigator.of(context).pop(),
                onHelpPressed: () => _showHelpDialog(context),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.extraLarge,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: summary.mode.accentColor.withValues(alpha: 0.08),
                        borderRadius: AppRadii.large,
                      ),
                      child: Icon(
                        summary.mode.icon,
                        color: summary.mode.accentColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.mode.title,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please review the details below before you confirm this booking.',
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
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionCard(
                        title: 'Consultation Details',
                        children: <Widget>[
                          _buildDetailRow(
                            'Type',
                            summary.consultationType.title,
                          ),
                          _buildDetailRow('Date', _formatDate(summary.date)),
                          _buildDetailRow('Time', summary.timeSlot),
                          _buildDetailRow(
                            summary.mode.locationLabel,
                            summary.location,
                          ),
                          _buildDetailRow('Provider', summary.provider),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildSectionCard(
                        title: 'Reason and Notes',
                        children: <Widget>[
                          _buildDetailRow('Reason', summary.reason),
                          if (notes.isNotEmpty)
                            _buildDetailRow('Notes', notes),
                          if (summary.mode == AppointmentBookingMode.teleconsultation)
                            _buildDetailRow(
                              'Remote readiness',
                              summary.teleReady
                                  ? 'Confirmed'
                                  : 'Not confirmed',
                            ),
                        ],
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
                      text: 'Confirm Booking',
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
