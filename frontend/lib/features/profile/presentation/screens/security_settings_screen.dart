import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../auth/data/auth_api_client.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../auth/domain/auth_validators.dart';
import '../../../auth/presentation/widgets/auth_surface_card.dart';
import '../../../auth/presentation/widgets/otp_code_field.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final GlobalKey<FormState> _disableFormKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _otpFieldKey =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _passwordController = TextEditingController();

  bool _isDisabling = false;

  String? _validateCurrentPassword(String? value) {
    final password = value ?? '';
    if (password.trim().isEmpty) {
      return 'Please enter your current password';
    }

    return null;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openSetupFlow() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    await Navigator.of(context).pushNamed(AppRoutes.totpSetup);
  }

  Future<void> _disable2fa() async {
    if (_disableFormKey.currentState?.validate() != true) {
      return;
    }

    if (_isDisabling) {
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    setState(() {
      _isDisabling = true;
    });

    try {
      final response = await AuthApiClient.instance.disableTotp(
        accessToken: accessToken,
        password: _passwordController.text,
        code: _otpFieldKey.currentState?.value?.trim() ?? '',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
      _passwordController.clear();
      _otpFieldKey.currentState?.reset();
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
          _isDisabling = false;
        });
      }
    }
  }

  void _goToLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please sign in again to access security settings.')),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Security',
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Authenticator app',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set up Google Authenticator as your second factor for safer sign-ins.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButtonWidget(
                          text: 'Set up 2FA',
                          onPressed: _openSetupFlow,
                          icon: Icons.shield_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _disableFormKey,
                    child: AuthSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Disable 2FA',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Confirm your password and current authenticator code to disable.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            enabled: !_isDisabling,
                            validator: _validateCurrentPassword,
                            decoration: const InputDecoration(
                              hintText: 'Current password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OtpCodeField(
                            key: _otpFieldKey,
                            validator: validateOtp,
                            isEnabled: !_isDisabling,
                          ),
                          const SizedBox(height: 16),
                          PrimaryButtonWidget(
                            text: 'Disable 2FA',
                            onPressed: _isDisabling ? null : _disable2fa,
                            isLoading: _isDisabling,
                            icon: Icons.gpp_bad_outlined,
                            backgroundColor: AppColors.danger,
                            textColor: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SecondaryButtonWidget(
                      text: 'Back to Profile',
                      onPressed: () => Navigator.of(context).pop(),
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
}
