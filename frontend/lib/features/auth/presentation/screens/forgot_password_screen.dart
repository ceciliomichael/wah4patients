import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../data/auth_api_client.dart';
import '../../domain/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_surface_card.dart';
import '../widgets/otp_code_field.dart';
import '../widgets/password_requirements_list.dart';

enum _ForgotPasswordStage {
  requestEmail,
  verifyOtp,
  resetPassword,
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _requestFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _otpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _otpFieldKey =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  Timer? _resendTimer;
  _ForgotPasswordStage _stage = _ForgotPasswordStage.requestEmail;
  bool _requestingCode = false;
  bool _resendingCode = false;
  bool _verifyingCode = false;
  bool _resettingPassword = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  int _resendCooldownSeconds = 0;
  String _passwordResetToken = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail.trim().isNotEmpty) {
      _emailController.text = widget.initialEmail.trim();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim();

  void _startCooldown(int cooldownSeconds) {
    _resendTimer?.cancel();
    setState(() {
      _resendCooldownSeconds = cooldownSeconds;
    });

    if (cooldownSeconds <= 0) {
      return;
    }

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCooldownSeconds <= 0) {
        timer.cancel();
        return;
      }

      setState(() {
        _resendCooldownSeconds--;
      });
    });
  }

  void _resetOtpAttemptState() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _resendCooldownSeconds = 0;
    _passwordResetToken = '';
    _otpFieldKey.currentState?.reset();
  }

  void _goBack() {
    switch (_stage) {
      case _ForgotPasswordStage.requestEmail:
        Navigator.of(context).pop();
        return;
      case _ForgotPasswordStage.verifyOtp:
        setState(() {
          _stage = _ForgotPasswordStage.requestEmail;
          _resetOtpAttemptState();
        });
        return;
      case _ForgotPasswordStage.resetPassword:
        setState(() {
          _stage = _ForgotPasswordStage.verifyOtp;
          _passwordController.clear();
          _confirmPasswordController.clear();
          _passwordVisible = false;
          _confirmPasswordVisible = false;
        });
        return;
    }
  }

  Future<void> _requestResetCode() async {
    if (_requestFormKey.currentState?.validate() != true) {
      return;
    }

    if (_requestingCode) {
      return;
    }

    setState(() {
      _requestingCode = true;
    });

    try {
      final response = await AuthApiClient.instance.requestPasswordResetOtp(
        email: _email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _stage = _ForgotPasswordStage.verifyOtp;
        _passwordResetToken = '';
      });
      _otpFieldKey.currentState?.reset();
      _startCooldown(response.cooldownSeconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
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
          _requestingCode = false;
        });
      }
    }
  }

  Future<void> _resendResetCode() async {
    if (_stage != _ForgotPasswordStage.verifyOtp ||
        _resendCooldownSeconds > 0 ||
        _resendingCode) {
      return;
    }

    setState(() {
      _resendingCode = true;
    });

    try {
      final response = await AuthApiClient.instance.resendPasswordResetOtp(
        email: _email,
      );

      if (!mounted) {
        return;
      }

      _otpFieldKey.currentState?.reset();
      _startCooldown(response.cooldownSeconds);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
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
          _resendingCode = false;
        });
      }
    }
  }

  Future<void> _verifyResetCode() async {
    if (_otpFormKey.currentState?.validate() != true) {
      return;
    }

    final otpCode = _otpFieldKey.currentState?.value?.trim() ?? '';
    if (_verifyingCode) {
      return;
    }

    setState(() {
      _verifyingCode = true;
    });

    try {
      final response = await AuthApiClient.instance.verifyPasswordResetOtp(
        email: _email,
        otpCode: otpCode,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _stage = _ForgotPasswordStage.resetPassword;
        _passwordResetToken = response.passwordResetToken;
        _passwordController.clear();
        _confirmPasswordController.clear();
        _passwordVisible = false;
        _confirmPasswordVisible = false;
      });
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
          _verifyingCode = false;
        });
      }
    }
  }

  Future<void> _completePasswordReset() async {
    if (_passwordFormKey.currentState?.validate() != true) {
      return;
    }

    if (_passwordResetToken.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing password reset token. Please verify your code again.'),
        ),
      );
      return;
    }

    if (_resettingPassword) {
      return;
    }

    setState(() {
      _resettingPassword = true;
    });

    try {
      final response = await AuthApiClient.instance.completePasswordReset(
        email: _email,
        password: _passwordController.text,
        passwordResetToken: _passwordResetToken.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.login,
        arguments: _email,
      );
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
          _resettingPassword = false;
        });
      }
    }
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _ignoreResendTap() {}

  String get _headerTitle {
    switch (_stage) {
      case _ForgotPasswordStage.requestEmail:
        return 'Reset password';
      case _ForgotPasswordStage.verifyOtp:
        return 'Enter the OTP';
      case _ForgotPasswordStage.resetPassword:
        return 'Create a new password';
    }
  }

  String get _headerSubtitle {
    switch (_stage) {
      case _ForgotPasswordStage.requestEmail:
        return 'Enter your email address and we will send a password reset code.';
      case _ForgotPasswordStage.verifyOtp:
        return 'Enter the 6-digit code we sent to your email address.';
      case _ForgotPasswordStage.resetPassword:
        return 'Choose a strong new password for your account.';
    }
  }

  Widget _buildCurrentStepCard() {
    switch (_stage) {
      case _ForgotPasswordStage.requestEmail:
        return Form(
          key: _requestFormKey,
          child: AuthSurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email Address',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: validateEmail,
                  enabled: !_requestingCode,
                  onFieldSubmitted: (_) => _requestResetCode(),
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case _ForgotPasswordStage.verifyOtp:
        return Form(
          key: _otpFormKey,
          child: AuthSurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification code',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                OtpCodeField(
                  key: _otpFieldKey,
                  validator: validateOtp,
                  isEnabled: !_verifyingCode,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sent to $_email',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      case _ForgotPasswordStage.resetPassword:
        return Form(
          key: _passwordFormKey,
          child: AuthSurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Password',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  enabled: !_resettingPassword,
                  obscureText: !_passwordVisible,
                  textInputAction: TextInputAction.next,
                  validator: validatePassword,
                  onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Enter your new password',
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
                  isVisible: true,
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirm Password',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  enabled: !_resettingPassword,
                  obscureText: !_confirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  validator: (value) => validatePasswordConfirmation(
                    _passwordController.text,
                    value?.trim() ?? '',
                  ),
                  onFieldSubmitted: (_) => _completePasswordReset(),
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your new password',
                    prefixIcon: const Icon(
                      Icons.lock_reset_outlined,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _confirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildPrimaryAction() {
    switch (_stage) {
      case _ForgotPasswordStage.requestEmail:
        return PrimaryButtonWidget(
          text: 'Send reset code',
          onPressed: _requestingCode ? null : _requestResetCode,
          isLoading: _requestingCode,
          icon: Icons.send_outlined,
        );
      case _ForgotPasswordStage.verifyOtp:
        return PrimaryButtonWidget(
          text: 'Verify code',
          onPressed: _verifyingCode ? null : _verifyResetCode,
          isLoading: _verifyingCode,
          icon: Icons.verified_user_outlined,
        );
      case _ForgotPasswordStage.resetPassword:
        return PrimaryButtonWidget(
          text: 'Reset password',
          onPressed: _resettingPassword ? null : _completePasswordReset,
          isLoading: _resettingPassword,
          icon: Icons.lock_reset_outlined,
        );
    }
  }

  Widget _buildSecondaryAction() {
    switch (_stage) {
      case _ForgotPasswordStage.requestEmail:
        return Center(
          child: SecondaryButtonWidget(
            text: 'Back to Sign In',
            onPressed: _goBack,
            textColor: AppColors.secondary,
          ),
        );
      case _ForgotPasswordStage.verifyOtp:
        return Center(
          child: _resendingCode
              ? Text(
                  'Sending new code...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              : SecondaryButtonWidget(
                  text: _resendCooldownSeconds > 0
                      ? 'Resend code (${_formatCountdown(_resendCooldownSeconds)})'
                      : 'Resend code',
                  onPressed: _resendCooldownSeconds > 0
                      ? _ignoreResendTap
                      : _resendResetCode,
                  textColor: _resendCooldownSeconds > 0
                      ? AppColors.textSecondary
                      : AppColors.secondary,
                ),
        );
      case _ForgotPasswordStage.resetPassword:
        return Center(
          child: SecondaryButtonWidget(
            text: 'Back to OTP',
            onPressed: _goBack,
            textColor: AppColors.secondary,
          ),
        );
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
                            switch (_stage) {
                              _ForgotPasswordStage.requestEmail => 'Step 1 of 3',
                              _ForgotPasswordStage.verifyOtp => 'Step 2 of 3',
                              _ForgotPasswordStage.resetPassword => 'Step 3 of 3',
                            },
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      AuthHeader(
                        title: _headerTitle,
                        subtitle: _headerSubtitle,
                        centerTitle: true,
                      ),
                      const SizedBox(height: 18),
                      _buildCurrentStepCard(),
                      const SizedBox(height: 16),
                      _buildPrimaryAction(),
                      const SizedBox(height: 12),
                      _buildSecondaryAction(),
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
