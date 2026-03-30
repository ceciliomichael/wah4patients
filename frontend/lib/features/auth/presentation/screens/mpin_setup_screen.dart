import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../domain/models/auth_api_models.dart';
import '../controllers/mpin_entry_controller.dart';
import '../widgets/mpin_flow_scaffold.dart';
import '../widgets/mpin_numeric_keypad.dart';
import '../widgets/mpin_pin_indicator.dart';

class MpinSetupScreen extends StatefulWidget {
  const MpinSetupScreen({super.key, this.arguments});

  final MpinSetupArguments? arguments;

  @override
  State<MpinSetupScreen> createState() => _MpinSetupScreenState();
}

class _MpinSetupScreenState extends State<MpinSetupScreen> {
  final MpinEntryController _controller = MpinEntryController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_controller.isComplete || _controller.isSubmitting) {
      _controller.setError('Enter your 4-digit MPIN first');
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.mpinConfirm,
      arguments: MpinConfirmArguments(
        initialMpin: _controller.value,
        securityVerificationToken: widget.arguments?.securityVerificationToken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MpinFlowScaffold(
          title: 'Create MPIN',
          subtitle: 'Set a 4-digit MPIN for quick app unlock and login.',
          surfaceTitle: 'Enter your 4-digit MPIN',
          surfaceSubtitle:
              'Choose a code you can remember, then continue to confirm it.',
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
                ? _continue
                : null,
            icon: Icons.arrow_forward,
          ),
        );
      },
    );
  }
}
