import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class MpinNumericKeypad extends StatelessWidget {
  const MpinNumericKeypad({
    super.key,
    required this.onDigitTap,
    required this.onDeleteTap,
    this.onBiometricTap,
    this.isEnabled = true,
    this.showBiometricButton = true,
  });

  final ValueChanged<String> onDigitTap;
  final VoidCallback onDeleteTap;
  final VoidCallback? onBiometricTap;
  final bool isEnabled;
  final bool showBiometricButton;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        for (int value = 1; value <= 9; value++)
          _MpinKeyButton(
            label: '$value',
            onPressed: isEnabled ? () => onDigitTap('$value') : null,
          ),
        _MpinKeyButton(
          icon: showBiometricButton ? Icons.fingerprint : null,
          onPressed: isEnabled && showBiometricButton ? onBiometricTap : null,
        ),
        _MpinKeyButton(
          label: '0',
          onPressed: isEnabled ? () => onDigitTap('0') : null,
        ),
        _MpinKeyButton(
          icon: Icons.backspace_outlined,
          onPressed: isEnabled ? onDeleteTap : null,
        ),
      ],
    );
  }
}

class _MpinKeyButton extends StatelessWidget {
  const _MpinKeyButton({this.label, this.icon, this.onPressed});

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: enabled ? AppColors.surface : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: label != null
                ? Text(
                    label!,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Icon(
                    icon ?? Icons.block,
                    color: enabled
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 26,
                  ),
          ),
        ),
      ),
    );
  }
}
