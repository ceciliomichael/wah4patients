import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../data/auth_api_client.dart';
import '../../data/mpin_local_store.dart';
import '../../domain/auth_session.dart';
import '../../domain/models/auth_api_models.dart';
import '../controllers/mpin_entry_controller.dart';
import '../widgets/mpin_flow_scaffold.dart';
import '../widgets/mpin_numeric_keypad.dart';
import '../widgets/mpin_pin_indicator.dart';

class MpinConfirmScreen extends StatefulWidget {
  const MpinConfirmScreen({super.key, required this.arguments});

  final MpinConfirmArguments arguments;

  @override
  State<MpinConfirmScreen> createState() => _MpinConfirmScreenState();
}

class _MpinConfirmScreenState extends State<MpinConfirmScreen> {
  final MpinEntryController _controller = MpinEntryController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveMpin() async {
    if (!_controller.isComplete || _controller.isSubmitting) {
      _controller.setError('Confirm your 4-digit MPIN');
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    await _controller.submit((pin) async {
      try {
        if (pin != widget.arguments.initialMpin) {
          _controller.clear();
          _controller.setError('MPIN does not match. Try again.');
          return;
        }

        await AuthApiClient.instance.setMpin(
          accessToken: accessToken,
          mpin: pin,
          confirmMpin: pin,
          securityVerificationToken: widget.arguments.securityVerificationToken,
        );

        final deviceId = await MpinLocalStore.readOrCreateDeviceId();
        await AuthApiClient.instance.registerMpinDevice(
          accessToken: accessToken,
          deviceId: deviceId,
        );
        await MpinLocalStore.setMpinEnabled(true);

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'MPIN saved successfully. This device is now registered for MPIN unlock.',
            ),
          ),
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.securitySettings,
          (route) => route.settings.name == AppRoutes.dashboard,
        );
      } on AuthApiException catch (error) {
        _controller.clear();
        _controller.setError(error.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MpinFlowScaffold(
          title: 'Confirm MPIN',
          subtitle: 'Re-enter your MPIN to finish setup.',
          surfaceTitle: 'Confirm your MPIN',
          surfaceSubtitle:
              'Type the same 4-digit code again to lock in your new MPIN.',
          heroIcon: Icons.verified_outlined,
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
            text: 'Save MPIN',
            onPressed: (_controller.isComplete && !_controller.isSubmitting)
                ? _saveMpin
                : null,
            isLoading: _controller.isSubmitting,
            icon: Icons.check,
          ),
        );
      },
    );
  }
}
