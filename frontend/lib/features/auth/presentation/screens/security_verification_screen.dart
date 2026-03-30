import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../data/auth_api_client.dart';
import '../../data/mpin_local_store.dart';
import '../../domain/auth_session.dart';
import '../../domain/models/auth_api_models.dart';
import '../../domain/auth_validators.dart';
import '../controllers/mpin_entry_controller.dart';
import '../widgets/auth_surface_card.dart';
import '../widgets/mpin_flow_scaffold.dart';
import '../widgets/mpin_numeric_keypad.dart';
import '../widgets/mpin_pin_indicator.dart';
import '../widgets/otp_code_field.dart';

class SecurityVerificationArguments {
  const SecurityVerificationArguments({
    required this.purpose,
    this.preferredMethod,
  });

  final String purpose;
  final SecurityVerificationMethod? preferredMethod;
}

enum SecurityVerificationMethod { emailOtp, authenticator }

class SecurityVerificationScreen extends StatefulWidget {
  const SecurityVerificationScreen({super.key, required this.arguments});

  final SecurityVerificationArguments arguments;

  @override
  State<SecurityVerificationScreen> createState() =>
      _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState extends State<SecurityVerificationScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _otpFieldKey =
      GlobalKey<FormFieldState<String>>();
  final MpinEntryController _authenticatorController = MpinEntryController(
    requiredLength: 6,
  );

  late final AnimationController _errorShakeController;

  bool _sendingEmailOtp = false;
  bool _verifying = false;
  bool _emailOtpRequested = false;
  bool _hasInputError = false;

  SecuritySettingsStatusResult? _status;

  @override
  void initState() {
    super.initState();
    _errorShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _loadStatus();
  }

  @override
  void dispose() {
    _errorShakeController.dispose();
    _authenticatorController.dispose();
    super.dispose();
  }

  Future<void> _playErrorAnimation() async {
    setState(() {
      _hasInputError = true;
    });
    await _errorShakeController.forward(from: 0);
    if (!mounted) {
      return;
    }
    setState(() {
      _hasInputError = false;
    });
  }

  Future<void> _loadStatus() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }
    final deviceId = await MpinLocalStore.readOrCreateDeviceId();

    try {
      final status = await AuthApiClient.instance.getSecuritySettingsStatus(
        accessToken: accessToken,
        deviceId: deviceId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _status = status;
      });
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      Navigator.of(context).pop();
    }
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }

  SecurityVerificationMethod get _verificationMethod {
    return widget.arguments.preferredMethod ??
        (_status?.isTotpEnabled == true
            ? SecurityVerificationMethod.authenticator
            : SecurityVerificationMethod.emailOtp);
  }

  Future<void> _requestEmailOtp() async {
    final email = AuthSession.userEmail?.trim() ?? '';
    if (email.isEmpty || _sendingEmailOtp) {
      return;
    }

    setState(() {
      _sendingEmailOtp = true;
    });

    try {
      final response = await AuthApiClient.instance.requestSecurityEmailOtp(
        email: email,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _emailOtpRequested = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
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
          _sendingEmailOtp = false;
        });
      }
    }
  }

  Future<void> _verifyEmailOtp() async {
    if (_formKey.currentState?.validate() != true || _verifying) {
      return;
    }

    final code = _otpFieldKey.currentState?.value?.trim() ?? '';
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    final email = AuthSession.userEmail?.trim() ?? '';
    if (accessToken.isEmpty || email.isEmpty) {
      _goToLogin();
      return;
    }

    setState(() {
      _verifying = true;
    });

    try {
      final VerifySecurityActionResult result = await AuthApiClient.instance
          .verifySecurityEmailOtp(email: email, otpCode: code);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(result.securityVerificationToken);
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
          _verifying = false;
        });
      }
    }
  }

  Future<void> _verifyAuthenticator() async {
    if (!_authenticatorController.isComplete || _verifying) {
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    try {
      await _authenticatorController.submit((code) async {
        try {
          final VerifySecurityActionResult result = await AuthApiClient.instance
              .verifyTotpForSecurityAction(
                accessToken: accessToken,
                code: code,
              );

          if (!mounted) {
            return;
          }

          Navigator.of(context).pop(result.securityVerificationToken);
        } on AuthApiException catch (error) {
          _authenticatorController.registerFailure(message: error.message);
          await _playErrorAnimation();
        }
      });
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      _authenticatorController.clear();
      _authenticatorController.setError(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasExplicitMethod = widget.arguments.preferredMethod != null;
    final usingAuthenticator =
        _verificationMethod == SecurityVerificationMethod.authenticator;
    final title = usingAuthenticator
        ? 'Verify with Authenticator'
        : 'Verify with Email OTP';
    final subtitle = usingAuthenticator
        ? 'Enter the code from Google Authenticator to continue ${widget.arguments.purpose}.'
        : '2FA is not enabled. Verify using email OTP to continue ${widget.arguments.purpose}.';

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (usingAuthenticator) {
      return AnimatedBuilder(
        animation: Listenable.merge([
          _authenticatorController,
          _errorShakeController,
        ]),
        builder: (context, _) {
          final bool canInteract =
              !_authenticatorController.isSubmitting &&
              !_authenticatorController.isLocked;
          final double shake =
              (1 - (_errorShakeController.value - 0.5).abs() * 2) * 10;

          return MpinFlowScaffold(
            title: 'Verify with Authenticator',
            subtitle:
                'Enter the 6-digit code to continue ${widget.arguments.purpose}.',
            surfaceTitle: 'Authenticator code',
            surfaceSubtitle:
                'Use the code from Google Authenticator on this account.',
            heroIcon: Icons.verified_user_outlined,
            onBackPressed: _authenticatorController.isSubmitting
                ? null
                : () => Navigator.of(context).pop(),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Transform.translate(
                  offset: Offset(shake, 0),
                  child: MpinPinIndicator(
                    filledCount: _authenticatorController.value.length,
                    length: 6,
                    isError: _hasInputError,
                    showDigits: true,
                    displayValue: _authenticatorController.value,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: MpinNumericKeypad(
                      isEnabled: canInteract,
                      showBiometricButton: false,
                      onDigitTap: _onAuthenticatorDigitTap,
                      onDeleteTap: _onAuthenticatorDeleteTap,
                    ),
                  ),
                ),
                if (_authenticatorController.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _authenticatorController.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.danger,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            onPressed: _verifying ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            tooltip: 'Back',
          ),
          title: Text(
            'Security Verification',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: hasExplicitMethod || _status != null
                  ? AuthSurfaceCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subtitle,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!usingAuthenticator) ...[
                              PrimaryButtonWidget(
                                text: _emailOtpRequested
                                    ? 'Resend email OTP'
                                    : 'Send email OTP',
                                onPressed: _sendingEmailOtp
                                    ? null
                                    : _requestEmailOtp,
                                isLoading: _sendingEmailOtp,
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 12),
                            ],
                            OtpCodeField(
                              key: _otpFieldKey,
                              validator: validateOtp,
                              isEnabled: !_verifying,
                            ),
                            const SizedBox(height: 16),
                            PrimaryButtonWidget(
                              text: 'Verify',
                              onPressed: _verifying
                                  ? null
                                  : (usingAuthenticator
                                        ? _verifyAuthenticator
                                        : _verifyEmailOtp),
                              isLoading: _verifying,
                              icon: Icons.verified_outlined,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const AuthSurfaceCard(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _onAuthenticatorDigitTap(String digit) {
    if (_authenticatorController.isSubmitting ||
        _authenticatorController.isLocked) {
      return;
    }

    _authenticatorController.appendDigit(digit);
    if (_authenticatorController.isComplete) {
      _verifyAuthenticator();
    }
  }

  void _onAuthenticatorDeleteTap() {
    _authenticatorController.removeLastDigit();
  }
}
