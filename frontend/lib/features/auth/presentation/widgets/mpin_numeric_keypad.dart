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
      childAspectRatio: 1.52,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
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

class _MpinKeyButton extends StatefulWidget {
  const _MpinKeyButton({this.label, this.icon, this.onPressed});

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  State<_MpinKeyButton> createState() => _MpinKeyButtonState();
}

class _MpinKeyButtonState extends State<_MpinKeyButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final String? label = widget.label;
    final Color contentColor = enabled
        ? AppColors.primary
        : AppColors.textSecondary;
    final double scale = !enabled
        ? 1
        : _isPressed
        ? 0.88
        : (_isHovered ? 1.04 : 1.0);

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: enabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: enabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            scale: scale,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: enabled ? 1 : 0.4,
              child: label != null
                  ? Text(
                      label,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 18,
                        color: contentColor,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Icon(
                      widget.icon ?? Icons.block,
                      color: contentColor,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
