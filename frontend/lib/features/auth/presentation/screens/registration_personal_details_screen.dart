import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../profile/presentation/widgets/patient_name_fields_form.dart';
import '../../domain/models/auth_api_models.dart';

class RegistrationPersonalDetailsScreen extends StatefulWidget {
  const RegistrationPersonalDetailsScreen({
    super.key,
    required this.email,
    required this.registrationToken,
  });

  final String email;
  final String registrationToken;

  @override
  State<RegistrationPersonalDetailsScreen> createState() =>
      _RegistrationPersonalDetailsScreenState();
}

class _RegistrationPersonalDetailsScreenState
    extends State<RegistrationPersonalDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  Future<void> _continue() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_isSubmitting) {
      return;
    }

    final profileDraft = RegistrationProfileDraft(
      firstName: _firstNameController.text,
      secondName: _secondNameController.text,
      middleName: _middleNameController.text,
      lastName: _lastNameController.text,
    );

    if (profileDraft.givenNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter at least one given name before continuing.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamed(
        AppRoutes.registrationPassword,
        arguments: RegistrationPasswordArguments(
          email: widget.email,
          registrationToken: widget.registrationToken,
          profileDraft: profileDraft,
        ),
      );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 48.0 : 24.0;

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
        body: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            24,
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
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    splashRadius: 20,
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Step 3 of 4',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (dialogContext) {
                          return HelpModalWidget(
                            title: 'Personal Details Help',
                            messages: const [
                              'Use the names you want visible across the app.',
                              'The details are stored in FHIR-friendly name fields.',
                              'You can edit these details later from your profile.',
                            ],
                            icons: const [
                              Icons.badge_outlined,
                              Icons.storage_outlined,
                              Icons.edit_note_outlined,
                            ],
                            onClose: () => Navigator.of(dialogContext).pop(),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.help_outline, size: 20),
                    label: Text(
                      'Help',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: const Size(40, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
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
                              'Tell us your name',
                              style: AppTextStyles.headlineLarge.copyWith(
                                fontSize: 36,
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
                                  color: AppColors.primary,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrimaryButtonWidget(
                text: 'Continue to Password',
                onPressed: _isSubmitting ? null : _continue,
                isLoading: _isSubmitting,
                icon: Icons.arrow_forward,
              ),
              const SizedBox(height: 12),
              Center(
                child: SecondaryButtonWidget(
                  text: 'Back',
                  onPressed: _goBack,
                  textColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
