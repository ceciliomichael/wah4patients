import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../domain/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_surface_card.dart';
import '../widgets/password_requirements_list.dart';

class PasswordRegistrationScreen extends StatefulWidget {
  const PasswordRegistrationScreen({super.key, required this.email});

  final String email;

  @override
  State<PasswordRegistrationScreen> createState() =>
      _PasswordRegistrationScreenState();
}

class _PasswordRegistrationScreenState
    extends State<PasswordRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  late final TapGestureRecognizer _privacyStatementRecognizer;

  bool _passwordVisible = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_rebuild);
    _confirmPasswordController.addListener(_rebuild);
    _passwordFocusNode.addListener(_rebuild);
    _confirmPasswordFocusNode.addListener(_rebuild);
    _privacyStatementRecognizer = TapGestureRecognizer()
      ..onTap = _showPrivacyPreview;
  }

  @override
  void dispose() {
    _passwordController.removeListener(_rebuild);
    _confirmPasswordController.removeListener(_rebuild);
    _passwordFocusNode.removeListener(_rebuild);
    _confirmPasswordFocusNode.removeListener(_rebuild);
    _privacyStatementRecognizer.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _canSubmit {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    return _agreedToTerms &&
        validatePassword(password) == null &&
        validatePasswordConfirmation(password, confirmPassword) == null;
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _showPrivacyPreview() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: 'Privacy Statement',
          messages: const [
            'This is a local frontend preview of the registration flow.',
            'No backend or account storage is connected yet.',
            'The final privacy policy can be wired in later.',
          ],
          icons: const [
            Icons.visibility_off_outlined,
            Icons.storage_outlined,
            Icons.description_outlined,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _createAccount() {
    if (_formKey.currentState?.validate() != true || !_canSubmit) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 48.0 : 24.0;
    final requirementsVisible =
        _passwordFocusNode.hasFocus || _passwordController.text.isNotEmpty;

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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 32,
                bottom: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthHeader(
                        stepLabel: 'Step 3 of 3',
                        title: 'Create a password',
                        subtitle:
                            'Choose a strong password to keep your account secure.',
                        onBackPressed: _goBack,
                        helpTitle: 'Password Help',
                        helpMessages: const [
                          'Use at least 8 characters.',
                          'Include upper and lower case letters and a number.',
                          'This flow is frontend-only for now.',
                        ],
                        helpIcons: const [
                          Icons.lock_outline,
                          Icons.password_outlined,
                          Icons.info_outline,
                        ],
                      ),
                      const SizedBox(height: 18),
                      AuthSurfaceCard(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscureText: !_passwordVisible,
                                textInputAction: TextInputAction.next,
                                validator: validatePassword,
                                onFieldSubmitted: (_) =>
                                    _confirmPasswordFocusNode.requestFocus(),
                                style: AppTextStyles.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              PasswordRequirementsList(
                                password: _passwordController.text,
                                isVisible: requirementsVisible,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Confirm Password',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocusNode,
                                obscureText: !_passwordVisible,
                                textInputAction: TextInputAction.done,
                                validator: (value) =>
                                    validatePasswordConfirmation(
                                      _passwordController.text,
                                      value?.trim() ?? '',
                                    ),
                                onFieldSubmitted: (_) => _createAccount(),
                                style: AppTextStyles.bodyLarge,
                                decoration: InputDecoration(
                                  hintText: 'Re-enter your password',
                                  prefixIcon: const Icon(
                                    Icons.lock_reset_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Checkbox(
                                      value: _agreedToTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _agreedToTerms = value ?? false;
                                        });
                                      },
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 1),
                                      child: Text.rich(
                                        TextSpan(
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                          children: [
                                            const TextSpan(
                                              text:
                                                  'By registering, you agree to the ',
                                            ),
                                            TextSpan(
                                              text: 'Privacy Statement',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    color: AppColors.secondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              recognizer:
                                                  _privacyStatementRecognizer,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButtonWidget(
                        text: 'Create Account',
                        onPressed: _canSubmit ? _createAccount : null,
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
