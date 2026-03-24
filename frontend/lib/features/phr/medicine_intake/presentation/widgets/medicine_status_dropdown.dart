import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_border_radii.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../domain/medicine_status.dart';

class MedicineStatusDropdown extends StatefulWidget {
  const MedicineStatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MedicineStatus? value;
  final ValueChanged<MedicineStatus?> onChanged;

  @override
  State<MedicineStatusDropdown> createState() => _MedicineStatusDropdownState();
}

class _MedicineStatusDropdownState extends State<MedicineStatusDropdown> {
  static const double _triggerSize = 56.0;
  static const double _menuItemHeight = 54.0;
  static const double _screenMargin = 16.0;
  static const double _menuGap = 8.0;

  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  String _menuLabelFor(MedicineStatus? status) {
    return status?.menuLabel ?? 'All Status';
  }

  IconData _iconFor(MedicineStatus? status) {
    return status?.icon ?? Icons.filter_list;
  }

  double _measureTextWidth(BuildContext context, String text, TextStyle style) {
    final textScaler = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  bool get _isOpen => _overlayEntry != null;

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
      return;
    }

    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final buttonOffset = renderBox.localToGlobal(Offset.zero);
    final buttonRect = buttonOffset & renderBox.size;

    final menuLabelStyle = AppTextStyles.labelLarge.copyWith(
      fontWeight: FontWeight.w600,
    );
    final menuLabels = <MedicineStatus?>[null, ...MedicineStatus.values];
    final longestMenuLabel = menuLabels
        .map(_menuLabelFor)
        .map((label) => _measureTextWidth(context, label, menuLabelStyle))
        .fold<double>(0, math.max);

    final maxAllowedWidth = math.max(
      0.0,
      screenSize.width - (_screenMargin * 2),
    );
    final menuWidth = math.min(
      maxAllowedWidth,
      longestMenuLabel + 14 + 18 + 10 + 14 + 14,
    );
    final menuHeight = menuLabels.length * _menuItemHeight;

    final openAbove =
        buttonRect.bottom + _menuGap + menuHeight >
            screenSize.height - _screenMargin &&
        buttonRect.top - _menuGap - menuHeight >= _screenMargin;

    final top = openAbove
        ? buttonRect.top - _menuGap - menuHeight
        : buttonRect.bottom + _menuGap;

    final left = (buttonRect.right - menuWidth)
        .clamp(_screenMargin, screenSize.width - menuWidth - _screenMargin)
        .toDouble();
    final clampedTop = top
        .clamp(
          _screenMargin,
          math.max(
            _screenMargin,
            screenSize.height - menuHeight - _screenMargin,
          ),
        )
        .toDouble();

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeMenu,
          child: Stack(
            children: [
              Positioned(
                left: left,
                top: clampedTop,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: menuWidth,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.large,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadii.large,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: menuLabels.map((status) {
                          final isSelected = status == widget.value;
                          final itemColor = isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary;

                          return Material(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.09)
                                : AppColors.surface,
                            child: InkWell(
                              onTap: () {
                                widget.onChanged(status);
                                _closeMenu();
                              },
                              child: SizedBox(
                                height: _menuItemHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _iconFor(status),
                                        size: 18,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _menuLabelFor(status),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                color: itemColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    setState(() {
      _overlayEntry = overlayEntry;
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.value != null;

    return SizedBox(
      key: _buttonKey,
      width: _triggerSize,
      height: _triggerSize,
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        child: InkWell(
          onTap: _toggleMenu,
          borderRadius: AppRadii.large,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.large,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.filter_list,
                color: isSelected ? AppColors.secondary : AppColors.primary,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
