import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/domain/auth_session.dart';
import '../widgets/sign_out_confirmation_sheet_widget.dart';

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
    final content = ValueListenableBuilder<int>(
      valueListenable: AuthSession.notifier,
      builder: (context, _, __) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
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
                          _ProfileInfoCard(
                            displayName: AuthSession.shortDisplayName,
                            email: AuthSession.userEmail ?? '',
                            initials: _buildInitials(
                              AuthSession.givenNames,
                              AuthSession.familyName,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _MenuCard(
                            title: 'Personal Information',
                            icon: Icons.person_outline,
                            description:
                                'Manage your personal details and profile settings',
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.personalInformation),
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
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.privacyStatement),
                          ),
                          const SizedBox(height: 20),
                          _SectionHeader(title: 'Security'),
                          const SizedBox(height: 12),
                          _MenuCard(
                            title: 'Two-Factor Authentication',
                            icon: Icons.shield_outlined,
                            description:
                                'Set up Google Authenticator and manage account security.',
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.securitySettings),
                          ),
                          const SizedBox(height: 20),
                          _SectionHeader(title: 'About'),
                          const SizedBox(height: 12),
                          _MenuCard(
                            title: 'About Us',
                            icon: Icons.group_outlined,
                            description: 'Learn about our team and mission',
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.aboutUs),
                          ),
                          const SizedBox(height: 12),
                          _MenuCard(
                            title: 'About the App',
                            icon: Icons.info_outlined,
                            description:
                                'View app version, build details, and information',
                            onTap: () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.aboutApp),
                          ),
                          const SizedBox(height: 28),
                          _SectionHeader(title: 'Account'),
                          const SizedBox(height: 12),
                          _SignOutCard(
                            onTap: () => _showLogoutConfirmationModal(context),
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
      },
    );

    if (wrapWithSafeArea) {
      return SafeArea(child: content);
    }

    return content;
  }

  void _showLogoutConfirmationModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topRounded),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        return SignOutConfirmationSheetWidget(
          onSignOut: () {
            AuthSession.clear();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false);
          },
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
  const _ProfileInfoCard({
    required this.displayName,
    required this.email,
    required this.initials,
  });

  final String displayName;
  final String email;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
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
                initials,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            displayName.isEmpty ? 'WAH Patient' : displayName,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email.isEmpty ? 'Sign in to load your account email' : email,
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
        borderRadius: AppRadii.small,
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
        shape: RoundedRectangleBorder(borderRadius: AppRadii.small),
      ),
    );
  }
}

class _SignOutCard extends StatelessWidget {
  const _SignOutCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.large,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.large,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.logout,
                    color: AppColors.danger,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sign Out',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign out of your WAH4P account',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _buildInitials(List<String> givenNames, String familyName) {
  final initials = <String>[];
  if (givenNames.isNotEmpty && givenNames[0].trim().isNotEmpty) {
    initials.add(givenNames[0].trim()[0]);
  }
  if (familyName.trim().isNotEmpty) {
    initials.add(familyName.trim()[0]);
  }

  if (initials.isEmpty) {
    return 'WP';
  }

  return initials.join();
}
