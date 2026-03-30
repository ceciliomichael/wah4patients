import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../auth/data/auth_api_client.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../auth/domain/models/auth_api_models.dart';
import '../widgets/patient_name_fields_form.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 48.0 : 24.0;
    final isWide = screenWidth >= 720;

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
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Personal Information',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
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
                          _buildInitials(
                            AuthSession.givenNames,
                            AuthSession.familyName,
                          ),
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
                            AuthSession.displayName.isEmpty
                                ? 'Patient profile'
                                : AuthSession.displayName,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AuthSession.userEmail ?? '',
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
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Edit name details',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Container(
                                width: 72,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),
                            Form(
                              key: _formKey,
                              child: PatientNameFieldsForm(
                                firstNameController: _firstNameController,
                                secondNameController: _secondNameController,
                                middleNameController: _middleNameController,
                                lastNameController: _lastNameController,
                                enabled: !_isSubmitting,
                                showRequirementIndicators: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: isWide
                  ? Row(
                      children: [
                        Expanded(
                          child: PrimaryButtonWidget(
                            text: 'Save Changes',
                            onPressed: _isSubmitting ? null : _saveProfile,
                            isLoading: _isSubmitting,
                            icon: Icons.save_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SecondaryButtonWidget(
                            text: 'Reset',
                            onPressed: _isSubmitting ? null : _resetForm,
                            textColor: AppColors.secondary,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButtonWidget(
                          text: 'Save Changes',
                          onPressed: _isSubmitting ? null : _saveProfile,
                          isLoading: _isSubmitting,
                          icon: Icons.save_outlined,
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: SecondaryButtonWidget(
                            text: 'Reset',
                            onPressed: _isSubmitting ? null : _resetForm,
                            textColor: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
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
