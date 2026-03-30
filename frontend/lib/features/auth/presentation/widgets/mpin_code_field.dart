import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class MpinCodeField extends StatefulWidget {
  const MpinCodeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    this.length = 4,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool isEnabled;
  final int length;

  @override
  State<MpinCodeField> createState() => _MpinCodeFieldState();
}

class _MpinCodeFieldState extends State<MpinCodeField> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant MpinCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_textController.text != widget.value) {
      _textController.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }

    if (!widget.isEnabled && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _requestKeyboardFocus() {
    if (!widget.isEnabled) {
      return;
    }

    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cells = List<Widget>.generate(widget.length, (index) {
      final hasValue = widget.value.length > index;
      return Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadii.medium,
            border: Border.all(
              color: hasValue ? AppColors.primary : AppColors.border,
              width: hasValue ? 2 : 1,
            ),
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 120),
              opacity: hasValue ? 1 : 0.25,
              child: Text(
                hasValue ? '•' : '○',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: hasValue ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: widget.isEnabled,
          showCursor: false,
          keyboardType: TextInputType.number,
          maxLength: widget.length,
          obscureText: true,
          obscuringCharacter: '•',
          enableSuggestions: false,
          autocorrect: false,
          autofillHints: const <String>[AutofillHints.password],
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(widget.length),
          ],
          style: const TextStyle(fontSize: 1, height: 0.001),
          decoration: const InputDecoration(
            counterText: '',
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: widget.onChanged,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _requestKeyboardFocus,
          child: Row(children: cells.intersperse(const SizedBox(width: 8))),
        ),
      ],
    );
  }
}

extension _MpinWidgetListSpacing on List<Widget> {
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
