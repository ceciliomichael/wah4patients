import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../domain/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_surface_card.dart';
import '../widgets/otp_code_field.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _otpFieldKey =
      GlobalKey<FormFieldState<String>>();
  Timer? _resendTimer;
  int _resendCooldown = 45;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendTimer?.cancel();
    setState(() {
      _resendCooldown = 45;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCooldown == 0) {
        timer.cancel();
        return;
      }

      setState(() {
        _resendCooldown--;
      });
    });
  }

  void _resendCode() {
    if (_resendCooldown > 0 || _resending) {
      return;
    }

    setState(() {
      _resending = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preview mode: a new verification code was sent.'),
      ),
    );

    _otpFieldKey.currentState?.reset();
    _startCooldown();

    setState(() {
      _resending = false;
    });
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _verify() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamed(AppRoutes.registrationPassword, arguments: widget.email);
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
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
                      AuthHeader(
                        stepLabel: 'Step 2 of 3',
                        title: 'Enter the OTP sent to your email',
                        subtitle:
                            'Please check your inbox and enter the 6-digit code.',
                        onBackPressed: _goBack,
                        helpTitle: 'Verification Help',
                        helpMessages: const [
                          'If you do not see the email, check spam or junk.',
                          'The code is only for preview flow demonstration.',
                        ],
                        helpIcons: const [
                          Icons.mark_email_unread_outlined,
                          Icons.verified_user_outlined,
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
                                'OTP Code',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OtpCodeField(
                                key: _otpFieldKey,
                                validator: validateOtp,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sent to ${widget.email}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButtonWidget(
                        text: 'Verify OTP',
                        onPressed: _verify,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: _resending
                            ? Text(
                                'Sending new code...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              )
                            : SecondaryButtonWidget(
                                text: _resendCooldown > 0
                                    ? 'Resend code (${_formatCountdown(_resendCooldown)})'
                                    : 'Resend code',
                                onPressed: _resendCooldown > 0
                                    ? () {}
                                    : _resendCode,
                                textColor: _resendCooldown > 0
                                    ? AppColors.textSecondary
                                    : AppColors.secondary,
                              ),
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
