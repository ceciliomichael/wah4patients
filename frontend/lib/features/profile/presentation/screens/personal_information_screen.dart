import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../auth/data/auth_api_client.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../auth/domain/models/auth_api_models.dart';
import '../widgets/patient_name_fields_form.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({
    super.key,
    this.showBackButton = true,
    this.wrapWithSafeArea = true,
    this.centerContent = false,
  });

  final bool showBackButton;
  final bool wrapWithSafeArea;
  final bool centerContent;

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _hydrateFromSession();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _hydrateFromSession() {
    final givenNames = AuthSession.givenNames;
    _firstNameController.text = givenNames.isNotEmpty ? givenNames[0] : '';
    _secondNameController.text = givenNames.length > 1 ? givenNames[1] : '';
    _middleNameController.text = givenNames.length > 2 ? givenNames[2] : '';
    _lastNameController.text = AuthSession.familyName;
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session expired. Please sign in again.'),
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await AuthApiClient.instance.updateMyProfile(
        accessToken: accessToken,
        profile: RegistrationProfileDraft(
          firstName: _firstNameController.text,
          secondName: _secondNameController.text,
          middleName: _middleNameController.text,
          lastName: _lastNameController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      AuthSession.setProfile(result.profile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal details updated.')),
      );
      Navigator.of(context).pop();
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(_hydrateFromSession);
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

    final scaffold = Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverToBoxAdapter(
                  child: _ProfileTopContent(
                    title: 'Personal Information',
                    isTablet: isTablet,
                    showBackButton: widget.showBackButton,
                    onBackPressed: _goBack,
                    displayName: AuthSession.shortDisplayName,
                    email: AuthSession.userEmail ?? '',
                    initials: _buildInitials(
                      AuthSession.givenNames,
                      AuthSession.familyName,
                    ),
                    formKey: _formKey,
                    isSubmitting: _isSubmitting,
                    firstNameController: _firstNameController,
                    secondNameController: _secondNameController,
                    middleNameController: _middleNameController,
                    lastNameController: _lastNameController,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      const Spacer(),
                      _ProfileActionsFooter(
                        isWide: screenWidth >= 720,
                        isSubmitting: _isSubmitting,
                        onSavePressed: _saveProfile,
                        onResetPressed: _resetForm,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return widget.wrapWithSafeArea ? SafeArea(child: scaffold) : scaffold;
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.title,
    required this.isTablet,
    required this.showBackButton,
    required this.onBackPressed,
  });

  final String title;
  final bool isTablet;
  final bool showBackButton;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 12.0),
      child: Row(
        children: [
          if (showBackButton)
            _HeaderBackButton(onPressed: onBackPressed)
          else
            const SizedBox(width: 48, height: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: isTablet ? 24.0 : 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.medium,
        side: BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const RoundedRectangleBorder(
          borderRadius: AppRadii.medium,
        ),
        splashColor: AppColors.black.withValues(alpha: 0.12),
        highlightColor: AppColors.black.withValues(alpha: 0.08),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(
              Icons.arrow_back,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSummarySection extends StatelessWidget {
  const _ProfileSummarySection({
    required this.displayName,
    required this.email,
    required this.initials,
  });

  final String displayName;
  final String email;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
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
                'Profile summary',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayName.isEmpty ? 'Patient profile' : displayName,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email.isEmpty ? 'No email available' : email,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Keep your name details up to date across the app.',
                style: AppTextStyles.bodySmall.copyWith(
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

class _ProfileTopContent extends StatelessWidget {
  const _ProfileTopContent({
    required this.title,
    required this.isTablet,
    required this.showBackButton,
    required this.onBackPressed,
    required this.displayName,
    required this.email,
    required this.initials,
    required this.formKey,
    required this.isSubmitting,
    required this.firstNameController,
    required this.secondNameController,
    required this.middleNameController,
    required this.lastNameController,
  });

  final String title;
  final bool isTablet;
  final bool showBackButton;
  final VoidCallback onBackPressed;
  final String displayName;
  final String email;
  final String initials;
  final GlobalKey<FormState> formKey;
  final bool isSubmitting;
  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileHeader(
          title: title,
          isTablet: isTablet,
          showBackButton: showBackButton,
          onBackPressed: onBackPressed,
        ),
        const SizedBox(height: 16),
        _ProfileSummarySection(
          displayName: displayName,
          email: email,
          initials: initials,
        ),
        const SizedBox(height: 28),
        const Divider(height: 1),
        const SizedBox(height: 24),
        _ProfileFormSection(
          formKey: formKey,
          isSubmitting: isSubmitting,
          firstNameController: firstNameController,
          secondNameController: secondNameController,
          middleNameController: middleNameController,
          lastNameController: lastNameController,
        ),
      ],
    );
  }
}

class _ProfileFormSection extends StatelessWidget {
  const _ProfileFormSection({
    required this.formKey,
    required this.isSubmitting,
    required this.firstNameController,
    required this.secondNameController,
    required this.middleNameController,
    required this.lastNameController,
  });

  final GlobalKey<FormState> formKey;
  final bool isSubmitting;
  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Edit name details',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update the legal name details linked to your patient profile.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: formKey,
          child: PatientNameFieldsForm(
            firstNameController: firstNameController,
            secondNameController: secondNameController,
            middleNameController: middleNameController,
            lastNameController: lastNameController,
            enabled: !isSubmitting,
            showRequirementIndicators: true,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionsFooter extends StatelessWidget {
  const _ProfileActionsFooter({
    required this.isWide,
    required this.isSubmitting,
    required this.onSavePressed,
    required this.onResetPressed,
  });

  final bool isWide;
  final bool isSubmitting;
  final VoidCallback onSavePressed;
  final VoidCallback onResetPressed;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        children: [
          Expanded(
            child: PrimaryButtonWidget(
              text: 'Save Changes',
              onPressed: isSubmitting ? null : onSavePressed,
              isLoading: isSubmitting,
              icon: Icons.save_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SecondaryButtonWidget(
              text: 'Reset',
              onPressed: isSubmitting ? null : onResetPressed,
              textColor: AppColors.secondary,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButtonWidget(
          text: 'Save Changes',
          onPressed: isSubmitting ? null : onSavePressed,
          isLoading: isSubmitting,
          icon: Icons.save_outlined,
        ),
        const SizedBox(height: 12),
        SecondaryButtonWidget(
          text: 'Reset',
          onPressed: isSubmitting ? null : onResetPressed,
          textColor: AppColors.secondary,
        ),
      ],
    );
  }
}
