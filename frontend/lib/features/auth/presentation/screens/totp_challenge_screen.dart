import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../data/auth_api_client.dart';
import '../../domain/auth_session.dart';
import '../../domain/auth_validators.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_surface_card.dart';
import '../widgets/otp_code_field.dart';

class TotpChallengeScreen extends StatefulWidget {
  const TotpChallengeScreen({
    super.key,
    required this.email,
    required this.mfaChallengeToken,
  });

  final String email;
  final String mfaChallengeToken;

  @override
  State<TotpChallengeScreen> createState() => _TotpChallengeScreenState();
}

class _TotpChallengeScreenState extends State<TotpChallengeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _otpFieldKey =
      GlobalKey<FormFieldState<String>>();

  bool _isVerifying = false;

  void _goBack() {
    Navigator.of(context).pop();
  }

  Future<void> _verify() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final code = _otpFieldKey.currentState?.value?.trim() ?? '';
    if (_isVerifying) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final result = await AuthApiClient.instance.verifyMfaChallenge(
        mfaChallengeToken: widget.mfaChallengeToken,
        code: code,
      );

      AuthSession.setFromLoginResult(result);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.dashboard,
        (route) => false,
      );
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
          _isVerifying = false;
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IconButton(
                        onPressed: _goBack,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                        alignment: Alignment.centerLeft,
                        tooltip: 'Back',
                      ),
                      const SizedBox(height: 8),
                      const AuthHeader(
                        title: 'Two-factor verification',
                        subtitle:
                            'Enter the 6-digit code from your authenticator app.',
                        centerTitle: false,
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: AuthSurfaceCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Authenticator code',
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              OtpCodeField(
                                key: _otpFieldKey,
                                validator: validateOtp,
                                isEnabled: !_isVerifying,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Signing in as ${widget.email}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      PrimaryButtonWidget(
                        text: 'Verify and continue',
                        onPressed: _isVerifying ? null : _verify,
                        isLoading: _isVerifying,
                        icon: Icons.verified_user_outlined,
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
