import 'package:flutter/material.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/config/screen_protection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../data/auth_api_client.dart';
import '../../data/mpin_local_store.dart';
import '../../domain/auth_session.dart';
import '../../domain/models/auth_api_models.dart';
import '../controllers/mpin_entry_controller.dart';
import '../widgets/mpin_flow_scaffold.dart';
import '../widgets/mpin_numeric_keypad.dart';
import '../widgets/mpin_pin_indicator.dart';

class MpinLoginScreen extends StatefulWidget {
  const MpinLoginScreen({super.key, required this.arguments});

  final MpinLoginArguments arguments;

  @override
  State<MpinLoginScreen> createState() => _MpinLoginScreenState();
}

class _MpinLoginScreenState extends State<MpinLoginScreen> {
  final MpinEntryController _controller = MpinEntryController();

  @override
  void initState() {
    super.initState();
    ScreenProtection.enableSecureMode();
  }

  @override
  void dispose() {
    ScreenProtection.disableSecureMode();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_controller.isComplete || _controller.isSubmitting) {
      return;
    }

    try {
      await _controller.submit((pin) async {
        final deviceId = await MpinLocalStore.readOrCreateDeviceId();
        final result = await AuthApiClient.instance.verifyMpinChallenge(
          mfaChallengeToken: widget.arguments.mfaChallengeToken,
          mpin: pin,
          deviceId: deviceId,
        );

        await AuthSession.persist(result);

        if (!mounted) {
          return;
        }

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
      });
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MpinFlowScaffold(
          title: 'Verify with MPIN',
          subtitle: 'Use your registered device MPIN to finish sign in.',
          surfaceTitle: 'Enter your MPIN',
          surfaceSubtitle:
              'This device must be registered before MPIN login works.',
          heroIcon: Icons.pin_outlined,
          onBackPressed: _controller.isSubmitting
              ? null
              : () => Navigator.of(context).pop(),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MpinPinIndicator(
                filledCount: _controller.value.length,
                isError: _controller.errorMessage != null,
              ),
              const SizedBox(height: 16),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: MpinNumericKeypad(
                    isEnabled: !_controller.isSubmitting,
                    showBiometricButton: false,
                    onDigitTap: _controller.appendDigit,
                    onDeleteTap: _controller.removeLastDigit,
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
                ),
              ],
            ],
          ),
          primaryAction: PrimaryButtonWidget(
            text: 'Continue',
            onPressed: (_controller.isComplete && !_controller.isSubmitting)
                ? _authenticate
                : null,
            isLoading: _controller.isSubmitting,
            icon: Icons.login_outlined,
          ),
          secondaryAction: SecondaryButtonWidget(
            text: 'Use authenticator',
            onPressed: _controller.isSubmitting
                ? null
                : () => Navigator.of(context).pop(),
            icon: Icons.verified_user_outlined,
            textColor: AppColors.primary,
          ),
        );
      },
    );
  }
}
