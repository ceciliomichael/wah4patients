import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../legal/presentation/privacy_statement_screen.dart';
import 'about_app_screen.dart';
import 'about_us_screen.dart';
import 'personal_information_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.showBackButton = true,
    this.wrapWithSafeArea = true,
    this.centerContent = false,
  });

  final bool showBackButton;
  final bool wrapWithSafeArea;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: centerContent
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(showBackButton: showBackButton),
                      const SizedBox(height: 32),
                      _ProfileInfoCard(),
                      const SizedBox(height: 32),
                      _SectionCard(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        description:
                            'Manage your personal details and profile settings',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const PersonalInformationScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(title: 'Legal'),
                      const SizedBox(height: 12),
                      _MenuCard(
                        title: 'Privacy Statement',
                        icon: Icons.privacy_tip_outlined,
                        description:
                            'View our privacy statement and data usage information',
                        isSignOut: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const PrivacyStatementScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(title: 'About'),
                      const SizedBox(height: 12),
                      _MenuCard(
                        title: 'About Us',
                        icon: Icons.group_outlined,
                        description: 'Learn about our team and mission',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const AboutUsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _MenuCard(
                        title: 'About the App',
                        icon: Icons.info_outlined,
                        description:
                            'View app version, build details, and information',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const AboutAppScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      PrimaryButtonWidget(
                        text: 'Sign Out',
                        backgroundColor: AppColors.danger,
                        onPressed: () => _showLogoutConfirmationModal(context),
                        icon: Icons.logout,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (wrapWithSafeArea) {
      return SafeArea(child: content);
    }

    return content;
  }

  void _showLogoutConfirmationModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Sign Out',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Do you want to sign out of the preview build and return to the splash screen?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SecondaryButtonWidget(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                const SizedBox(height: 8),
                PrimaryButtonWidget(
                  text: 'Sign Out',
                  backgroundColor: AppColors.danger,
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.splash,
                      (route) => false,
                    );
                  },
                  icon: Icons.logout,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    if (!showBackButton) {
      return Center(
        child: Text(
          'Profile',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            size: 28,
            color: AppColors.textPrimary,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        Text(
          'Profile',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'WP',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'WAH Patient',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'preview@wahforpatients.com',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 34),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.onTap,
    this.isSignOut = false,
  });

  final String title;
  final IconData icon;
  final String description;
  final VoidCallback onTap;
  final bool isSignOut;

  @override
  Widget build(BuildContext context) {
    final bool dangerMode = isSignOut;
    final Color cardColor = dangerMode ? AppColors.danger : AppColors.surface;
    final Color iconColor = dangerMode ? AppColors.white : AppColors.primary;
    final Color titleColor = dangerMode
        ? AppColors.white
        : AppColors.textPrimary;
    final Color subtitleColor = dangerMode
        ? AppColors.white.withValues(alpha: 0.88)
        : AppColors.textSecondary;
    final Color trailingColor = dangerMode
        ? AppColors.white.withValues(alpha: 0.9)
        : AppColors.textSecondary;
    final Color borderColor = dangerMode
        ? AppColors.danger.withValues(alpha: 0.65)
        : AppColors.border;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(color: subtitleColor),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.chevron_right, color: trailingColor),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
