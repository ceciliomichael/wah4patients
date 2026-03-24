import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Segmented OTP input that keeps the form contract while showing one box per digit.
class OtpCodeField extends FormField<String> {
  const OtpCodeField({
    super.key,
    this.length = 6,
    this.autofocus = true,
    this.isEnabled = true,
    this.boxHeight = 56,
    this.onChanged,
    super.initialValue = '',
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(length > 0),
       super(builder: _placeholderBuilder);

  final int length;
  final bool autofocus;
  final bool isEnabled;
  final double boxHeight;
  final ValueChanged<String>? onChanged;

  static Widget _placeholderBuilder(FormFieldState<String> field) {
    return const SizedBox.shrink();
  }

  @override
  FormFieldState<String> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends FormFieldState<String> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  OtpCodeField get _otpField => widget as OtpCodeField;

  @override
  void initState() {
    super.initState();

    _controllers = List<TextEditingController>.generate(
      _otpField.length,
      (index) => TextEditingController(
        text: _characterAt(widget.initialValue ?? '', index),
      ),
    );

    _focusNodes = List<FocusNode>.generate(_otpField.length, (index) {
      return FocusNode();
    });

    if (_otpField.autofocus && _focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _focusNodes.first.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    _setCode(widget.initialValue ?? '');

    if (_otpField.autofocus && _focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _focusNodes.first.requestFocus();
      });
    }
  }

  String _characterAt(String value, int index) {
    if (index >= value.length) {
      return '';
    }

    return value[index];
  }

  void _setCode(String value) {
    for (var index = 0; index < _controllers.length; index++) {
      final digit = _characterAt(value, index);
      _controllers[index].value = TextEditingValue(
        text: digit,
        selection: TextSelection.collapsed(offset: digit.length),
      );
    }

    didChange(value);
    _otpField.onChanged?.call(value);
  }

  void _handleDigitChanged(int index, String rawValue) {
    if (!_otpField.isEnabled) {
      return;
    }

    final digitsOnly = rawValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      _controllers[index].clear();
      final code = _controllers.map((controller) => controller.text).join();
      didChange(code);
      _otpField.onChanged?.call(code);
      return;
    }

    if (digitsOnly.length == 1) {
      _controllers[index].value = TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );

      final code = _controllers.map((controller) => controller.text).join();
      didChange(code);
      _otpField.onChanged?.call(code);

      if (index < _controllers.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }

      return;
    }

    final remainingSlots = _controllers.length - index;
    final digitsToApply = digitsOnly.substring(
      0,
      digitsOnly.length > remainingSlots ? remainingSlots : digitsOnly.length,
    );

    for (var offset = 0; offset < remainingSlots; offset++) {
      final targetIndex = index + offset;
      _controllers[targetIndex].clear();
      if (offset < digitsToApply.length) {
        _controllers[targetIndex].value = TextEditingValue(
          text: digitsToApply[offset],
          selection: const TextSelection.collapsed(offset: 1),
        );
      }
    }

    final nextIndex = index + digitsToApply.length;
    final code = _controllers.map((controller) => controller.text).join();
    didChange(code);
    _otpField.onChanged?.call(code);

    if (nextIndex < _controllers.length) {
      _focusNodes[nextIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }
  }

  InputDecoration _buildDecoration({required bool hasError}) {
    final borderColor = hasError ? AppColors.danger : AppColors.border;
    final focusedBorderColor = hasError ? AppColors.danger : AppColors.primary;

    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: EdgeInsets.zero,
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: AppRadii.medium,
        borderSide: BorderSide(color: AppColors.danger, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AutofillGroup(
          child: Row(
            children: List<Widget>.generate(_controllers.length, (index) {
              return Expanded(
                child: SizedBox(
                  height: _otpField.boxHeight,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    enabled: _otpField.isEnabled,
                    keyboardType: TextInputType.number,
                    textInputAction: index == _controllers.length - 1
                        ? TextInputAction.done
                        : TextInputAction.next,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: AppColors.primary,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    autofillHints: index == 0
                        ? const <String>[AutofillHints.oneTimeCode]
                        : null,
                    decoration: _buildDecoration(hasError: hasError),
                    onChanged: (value) => _handleDigitChanged(index, value),
                  ),
                ),
              );
            }, growable: false).intersperse(const SizedBox(width: 8)),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            errorText ?? '',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}

extension _WidgetListSpacing on List<Widget> {
  List<Widget> intersperse(Widget separator) {
    if (isEmpty) {
      return this;
    }

    final items = <Widget>[];
    for (var index = 0; index < length; index++) {
      if (index > 0) {
        items.add(separator);
      }
      items.add(this[index]);
    }

    return items;
  }
}
