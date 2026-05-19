import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../appointments/presentation/screens/appointment_booking_screen.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: 'Appointments Help',
          messages: const <String>[
            'Start one guided booking flow and choose the consultation mode inside the flow.',
            'The app will look up active providers before you send the request.',
            'Use appointment history to revisit earlier consultation details.',
          ],
          icons: const <IconData>[
            Icons.calendar_month_outlined,
            Icons.apartment_outlined,
            Icons.history_outlined,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _openBooking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppointmentBookingScreen(),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.appointmentHistory);
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onPressed,
    required String buttonLabel,
    required bool primary,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                child: Icon(icon, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (primary)
            PrimaryButtonWidget(
              text: buttonLabel,
              onPressed: onPressed,
              icon: Icons.arrow_forward,
            )
          else
            SecondaryButtonWidget(
              text: buttonLabel,
              onPressed: onPressed,
              textColor: AppColors.secondary,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadii.large,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Onsite and teleconsultation are now part of one guided booking flow, so you can pick the right mode without bouncing between separate screens.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;
    final isTablet = screenWidth >= 600;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppScreenHeader(
                title: 'Appointments',
                onBackPressed: () => Navigator.of(context).pop(),
                onHelpPressed: () => _showHelp(context),
                isTablet: isTablet,
                topPadding: 0,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadii.extraLarge,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppRadii.extraLarge,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.textPrimary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Appointments made simple',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book an onsite or teleconsultation request, pick a provider, and send it through the gateway in one clean flow.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const <Widget>[
                        _StaticStepChip(label: 'Choose mode', icon: Icons.tune_outlined),
                        _StaticStepChip(
                          label: 'Pick provider',
                          icon: Icons.apartment_outlined,
                        ),
                        _StaticStepChip(
                          label: 'Review & send',
                          icon: Icons.verified_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildActionCard(
                title: 'Start appointment request',
                description:
                    'Open the guided request flow and choose either onsite or teleconsultation inside the same screen.',
                icon: Icons.add_circle_outline,
                onPressed: () => _openBooking(context),
                buttonLabel: 'Start request',
                primary: true,
              ),
              const SizedBox(height: 14),
              _buildActionCard(
                title: 'Appointment history',
                description:
                    'View past appointment records and previously saved consultation details.',
                icon: Icons.history_outlined,
                onPressed: () => _openHistory(context),
                buttonLabel: 'View history',
                primary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticStepChip extends StatelessWidget {
  const _StaticStepChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.large,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
