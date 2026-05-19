import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_notification_center.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/data/auth_api_client.dart';
import '../../../auth/data/auth_local_store.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../auth/domain/models/auth_api_models.dart';
import '../../domain/profile_sync_readiness.dart';
import '../widgets/patient_profile_form_widget.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({
    super.key,
    this.showBackButton = true,
    this.wrapWithSafeArea = true,
    this.centerContent = false,
    this.profileRefresh,
  });

  final bool showBackButton;
  final bool wrapWithSafeArea;
  final bool centerContent;
  final Future<bool> Function()? profileRefresh;

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  bool _isSubmitting = false;
  final GlobalKey _identifiersSectionKey = GlobalKey();

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    unawaited((widget.profileRefresh ?? AuthSession.refreshProfileFromBackend)());
  }

  Future<void> _saveProfile(PatientProfileDraft draft) async {
    if (_isSubmitting) {
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await AuthApiClient.instance.updateMyProfile(
        accessToken: accessToken,
        profile: draft,
      );

      if (!mounted) {
        return;
      }

      AuthSession.setProfile(result.profile);
      await AuthLocalStore.clearProfileCompletionPromptDismissed();
      if (!mounted) {
        return;
      }

      AppNotificationCenter.instance.showSuccess('Personal details updated.');
      Navigator.of(context).pop();
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      AppNotificationCenter.instance.showError(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final content = ValueListenableBuilder<int>(
      valueListenable: AuthSession.notifier,
      builder: (context, _, __) {
        final readiness = evaluateProfileSyncReadiness(AuthSession.profile);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: widget.centerContent
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    _ProfileHeader(
                      showBackButton: widget.showBackButton,
                      onBackPressed: _goBack,
                    ),
                    const SizedBox(height: 20),
                    _ProfileSummaryRow(
                      displayName: AuthSession.shortDisplayName,
                      email: AuthSession.userEmail ?? '',
                      initials: _buildInitials(
                        AuthSession.givenNames,
                        AuthSession.familyName,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SyncRecordsButton(
                      onPressed: () => _handleSyncRecordsPressed(readiness),
                    ),
                    const SizedBox(height: 20),
                    PatientProfileFormWidget(
                      initialProfile: AuthSession.profile,
                      isSubmitting: _isSubmitting,
                      isReadOnly: AuthSession.profile.isSyncLocked,
                      identifiersSectionKey: _identifiersSectionKey,
                      onSave: _saveProfile,
                      onReset: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.wrapWithSafeArea) {
      return SafeArea(child: content);
    }

    return content;
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

  Future<void> _openSyncWizard() async {
    await Navigator.of(context).pushNamed(AppRoutes.syncRecords);
  }

  Future<void> _handleSyncRecordsPressed(ProfileSyncReadiness readiness) async {
    if (readiness.isReady) {
      await _openSyncWizard();
      return;
    }

    await _scrollToIdentifiersSection();
  }

  Future<void> _scrollToIdentifiersSection() async {
    final sectionContext = _identifiersSectionKey.currentContext;
    if (sectionContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      sectionContext,
      alignment: 0.12,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.showBackButton,
    required this.onBackPressed,
  });

  final bool showBackButton;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    if (!showBackButton) {
      return Text(
        'Personal Information',
        style: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: onBackPressed,
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 4),
        Text(
          'Personal Information',
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProfileSummaryRow extends StatelessWidget {
  const _ProfileSummaryRow({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isEmpty ? 'WAH Patient' : displayName,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncRecordsButton extends StatelessWidget {
  const _SyncRecordsButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.sync_outlined),
      label: const Text('Sync records'),
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        minimumSize: const Size.fromHeight(48),
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.medium),
      ),
    );
  }
}
