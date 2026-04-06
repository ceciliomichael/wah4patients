import 'package:flutter/material.dart';

import '../../../../core/config/screen_protection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/auth_api_client.dart';
import '../../domain/auth_session.dart';
import '../services/mpin_device_registration_service.dart';
import '../services/post_login_route_service.dart';
import '../controllers/mpin_entry_controller.dart';
import '../widgets/mpin_flow_scaffold.dart';
import '../widgets/mpin_numeric_keypad.dart';
import '../widgets/mpin_pin_indicator.dart';

class TotpChallengeScreen extends StatefulWidget {
  const TotpChallengeScreen({
    super.key,
    required this.email,
    required this.mfaChallengeToken,
    this.nextRouteAfterSuccess,
    this.nextRouteArguments,
  });

  final String email;
  final String mfaChallengeToken;
  final String? nextRouteAfterSuccess;
  final Object? nextRouteArguments;

  @override
  State<TotpChallengeScreen> createState() => _TotpChallengeScreenState();
}

class _TotpChallengeScreenState extends State<TotpChallengeScreen>
    with SingleTickerProviderStateMixin {
  final MpinEntryController _controller = MpinEntryController(
    requiredLength: 6,
  );
  late final AnimationController _errorShakeController;
  bool _hasInputError = false;

  @override
  void initState() {
    super.initState();
    _errorShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    ScreenProtection.enableSecureMode();
  }

  @override
  void dispose() {
    _errorShakeController.dispose();
    ScreenProtection.disableSecureMode();
    _controller.dispose();
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

  Future<void> _registerCurrentDeviceAfterLogin(String accessToken) async {
    try {
      await MpinDeviceRegistrationService.registerCurrentDevice(
        accessToken: accessToken,
      );
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Signed in, but MPIN device registration failed: ${error.message}',
          ),
        ),
      );
    }
  }

  Future<void> _verify() async {
    if (!_controller.isComplete || _controller.isSubmitting) {
      return;
    }

    try {
      await _controller.submit((code) async {
        try {
          final result = await AuthApiClient.instance.verifyMfaChallenge(
            mfaChallengeToken: widget.mfaChallengeToken,
            code: code,
          );

          await AuthSession.persist(result);
          await _registerCurrentDeviceAfterLogin(result.accessToken);

          if (!mounted) {
            return;
          }

          final navigator = Navigator.of(context);

          final nextRoute = widget.nextRouteAfterSuccess;
          if (nextRoute != null && nextRoute.isNotEmpty) {
            navigator.pushNamedAndRemoveUntil(
              nextRoute,
              (route) => false,
              arguments: widget.nextRouteArguments,
            );
            return;
          }

          final postLoginRoute = await PostLoginRouteService
              .resolveNextRouteAfterLogin(
            accessToken: result.accessToken,
          );
          navigator.pushNamedAndRemoveUntil(
            postLoginRoute,
            (route) => false,
          );
        } on AuthApiException catch (error) {
          _controller.registerFailure(message: error.message);
          await _playErrorAnimation();
        }
      });
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      _controller.clear();
      _controller.setError(error.message);
    }
  }

  void _onDigitTap(String digit) {
    if (_controller.isSubmitting) {
      return;
    }

    _controller.appendDigit(digit);
    if (_controller.isComplete) {
      _verify();
    }
  }

  void _onDeleteTap() {
    _controller.removeLastDigit();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, __) => KeyEventResult.handled,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _errorShakeController]),
        builder: (context, _) {
          final bool canInteract =
              !_controller.isSubmitting && !_controller.isLocked;
          final double shake =
              (1 - (_errorShakeController.value - 0.5).abs() * 2) * 10;

          return MpinFlowScaffold(
            title: 'Verify with Authenticator',
            subtitle: 'Enter the 6-digit code to finish sign in.',
            surfaceTitle: 'Authenticator code',
            surfaceSubtitle:
                'Use the code from Google Authenticator on this account.',
            heroIcon: Icons.verified_user_outlined,
            onBackPressed: _controller.isSubmitting
                ? null
                : () => Navigator.of(context).pop(),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Transform.translate(
                  offset: Offset(shake, 0),
                  child: MpinPinIndicator(
                    filledCount: _controller.value.length,
                    length: 6,
                    isError: _hasInputError,
                    showDigits: true,
                    displayValue: _controller.value,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: MpinNumericKeypad(
                      isEnabled: canInteract,
                      showBiometricButton: false,
                      onDigitTap: _onDigitTap,
                      onDeleteTap: _onDeleteTap,
                    ),
                  ),
                ),
                if (_controller.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _controller.errorMessage!,
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
      ),
    );
  }
}
