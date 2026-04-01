import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/app_lock_state_service.dart';
import '../../../../core/config/screen_protection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../data/auth_api_client.dart';
import '../../data/mpin_local_store.dart';
import '../../domain/auth_session.dart';
import '../controllers/mpin_entry_controller.dart';
import '../widgets/mpin_flow_scaffold.dart';
import '../widgets/mpin_numeric_keypad.dart';
import '../widgets/mpin_pin_indicator.dart';

class MpinUnlockScreen extends StatefulWidget {
  const MpinUnlockScreen({super.key});

  @override
  State<MpinUnlockScreen> createState() => _MpinUnlockScreenState();
}

class _MpinUnlockScreenState extends State<MpinUnlockScreen>
    with SingleTickerProviderStateMixin {
  final MpinEntryController _controller = MpinEntryController();
  late final AnimationController _errorShakeController;
  Timer? _lockTimer;
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
    _lockTimer?.cancel();
    _errorShakeController.dispose();
    ScreenProtection.disableSecureMode();
    _controller.dispose();
    super.dispose();
  }

  void _startLockCountdown() {
    _lockTimer?.cancel();
    if (!_controller.isLocked) {
      return;
    }

    _lockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }

      _controller.syncLockState();
      if (!_controller.isLocked) {
        _lockTimer?.cancel();
      }
    });
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

  DateTime? _parseBackendLock(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return DateTime.tryParse(trimmed)?.toLocal();
  }

  String _formatLockDuration(Duration duration) {
    if (duration <= Duration.zero) {
      return 'less than a second';
    }

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes minute${minutes == 1 ? '' : 's'}';
    }

    return '$seconds second${seconds == 1 ? '' : 's'}';
  }

  Future<void> _unlock() async {
    if (_controller.isLocked) {
      _controller.setError(
        'Too many attempts. Try again in ${_formatLockDuration(_controller.remainingLockDuration)}.',
      );
      return;
    }

    if (!_controller.isComplete || _controller.isSubmitting) {
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _forceSignOut();
      return;
    }

    final isMpinEnabled = await MpinLocalStore.isMpinEnabled();
    if (!isMpinEnabled) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MPIN is not enabled on this device. Please sign in again.'),
        ),
      );
      _forceSignOut();
      return;
    }

    try {
      await _controller.submit((pin) async {
        final deviceId = await MpinLocalStore.readOrCreateDeviceId();

        try {
          final result = await AuthApiClient.instance.verifyMpin(
            accessToken: accessToken,
            mpin: pin,
            deviceId: deviceId,
          );

          final backendLock = _parseBackendLock(result.lockedUntil);
          if (backendLock != null && DateTime.now().isBefore(backendLock)) {
            _controller.registerFailure(
              remainingAttempts: result.remainingAttempts,
              backendLockedUntil: backendLock,
              message: 'Too many attempts. Please wait before retrying.',
            );
            _startLockCountdown();
            await _playErrorAnimation();
            return;
          }

          _controller.registerSuccess();
          AppLockStateService.clearBackgroundState();

          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.message)));
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.pop(true);
          } else {
            navigator.pushNamedAndRemoveUntil(
              AppRoutes.dashboard,
              (route) => false,
            );
          }
        } on AuthApiException catch (error) {
          final statusCode = error.statusCode;
          final shouldCountAsAttempt =
              statusCode == 400 ||
              statusCode == 401 ||
              statusCode == 403 ||
              statusCode == 429;

          if (!shouldCountAsAttempt) {
            _controller.clear();
            _controller.setError(error.message);
            return;
          }

          _controller.registerFailure(message: error.message);
          _startLockCountdown();
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
    if (_controller.isSubmitting || _controller.isLocked) {
      return;
    }

    _controller.appendDigit(digit);
    if (_controller.isComplete) {
      _unlock();
    }
  }

  void _onDeleteTap() {
    _controller.removeLastDigit();
  }

  void _forceSignOut() {
    AuthSession.clear();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, __) => KeyEventResult.handled,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _errorShakeController]),
        builder: (context, _) {
          final bool isLocked = _controller.isLocked;
          final bool canInteract = !_controller.isSubmitting && !isLocked;
          final Duration remaining = _controller.remainingLockDuration;
          final double shake =
              (1 - (_errorShakeController.value - 0.5).abs() * 2) * 10;

          return MpinFlowScaffold(
            title: 'Enter your MPIN',
            subtitle: 'Continue securely on this registered device.',
            surfaceTitle: 'Enter your MPIN',
            surfaceSubtitle: '',
            heroIcon: Icons.lock_outline,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Transform.translate(
                  offset: Offset(shake, 0),
                  child: MpinPinIndicator(
                    filledCount: _controller.value.length,
                    isError: _hasInputError,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: MpinNumericKeypad(
                      isEnabled: canInteract,
                      onDigitTap: _onDigitTap,
                      onDeleteTap: _onDeleteTap,
                      onBiometricTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Biometric sign-in will be available soon.',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (isLocked) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Locked for ${_formatLockDuration(remaining)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
            secondaryAction: SecondaryButtonWidget(
              text: 'Sign out',
              onPressed: _controller.isSubmitting ? null : _forceSignOut,
              icon: Icons.logout,
              textColor: AppColors.danger,
            ),
          );
        },
      ),
    );
  }
}
