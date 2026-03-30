import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
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

  Future<void> _openMpinSetup() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    await Navigator.of(context).pushNamed(AppRoutes.mpinSetup);
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
      const SnackBar(
        content: Text('Please sign in again to access security settings.'),
      ),
    );
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

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
        body: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
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
                    ),
                    const SizedBox(height: 16),
                    _PageHeader(isTablet: isTablet),
                    const SizedBox(height: 28),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _SectionTitle(
                              icon: Icons.shield_outlined,
                              title: 'Authenticator app',
                            ),
                            const SizedBox(height: 12),
                            AuthSurfaceCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Set up Google Authenticator as your second factor for safer sign-ins.',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.6,
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
                            const SizedBox(height: 24),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 24),
                            const _SectionTitle(
                              icon: Icons.pin_outlined,
                              title: 'App MPIN',
                            ),
                            const SizedBox(height: 12),
                            AuthSurfaceCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Use a secure 4-digit MPIN to quickly unlock this app on your device.',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  PrimaryButtonWidget(
                                    text: 'Set up MPIN',
                                    onPressed: _openMpinSetup,
                                    icon: Icons.pin,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 24),
                            const _SectionTitle(
                              icon: Icons.gpp_bad_outlined,
                              title: 'Disable 2FA',
                            ),
                            const SizedBox(height: 12),
                            Form(
                              key: _disableFormKey,
                              child: AuthSurfaceCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Confirm your password and current authenticator code to disable.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.6,
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
                                      onPressed: _isDisabling
                                          ? null
                                          : _disable2fa,
                                      isLoading: _isDisabling,
                                      icon: Icons.gpp_bad_outlined,
                                      backgroundColor: AppColors.danger,
                                      textColor: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButtonWidget(
                      text: 'Back to Profile',
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(AppRoutes.profile);
                      },
                      icon: Icons.arrow_forward,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'Security',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontSize: isTablet ? 36.0 : 30.0,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Manage your two-factor authentication settings.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
