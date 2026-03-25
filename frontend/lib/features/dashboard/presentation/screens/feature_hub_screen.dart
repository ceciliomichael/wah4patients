import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../domain/dashboard_models.dart';

class FeatureHubScreen extends StatelessWidget {
  const FeatureHubScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actions,
    required this.onActionTap,
    required this.helpTitle,
    required this.helpMessages,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<HubActionData> actions;
  final void Function(HubActionData action) onActionTap;
  final String helpTitle;
  final List<String> helpMessages;

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: helpTitle,
          messages: helpMessages,
          icons: List<IconData>.filled(helpMessages.length, Icons.info_outline),
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _goToDashboard(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  Widget _buildBackToDashboardButton(BuildContext context) {
    return PrimaryButtonWidget(
      text: 'Back to Dashboard',
      onPressed: () => _goToDashboard(context),
      icon: Icons.home_outlined,
      iconPosition: IconPosition.leading,
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(HubActionData action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        child: InkWell(
          onTap: () => onActionTap(action),
          borderRadius: AppRadii.large,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: AppRadii.large,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: action.accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadii.medium,
                  ),
                  child: Icon(
                    action.icon,
                    color: action.accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildScrollableContent() {
    return <Widget>[
      _buildHeroCard(),
      const SizedBox(height: 20),
      ...actions.map(_buildActionCard),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 32.0 : 16.0;

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 24.0,
              ),
              child: AppScreenHeader(
                title: title,
                onBackPressed: () => Navigator.of(context).pop(),
                onHelpPressed: () => _showHelpDialog(context),
                isTablet: screenWidth > 600,
                topPadding: 0,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 24,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildScrollableContent(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                24,
              ),
              child: _buildBackToDashboardButton(context),
            ),
          ],
        ),
      ),
    );
  }
}
