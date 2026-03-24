import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/calendar_event.dart';

class CalendarViewModeDropdown extends StatefulWidget {
  const CalendarViewModeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CalendarViewMode value;
  final ValueChanged<CalendarViewMode> onChanged;

  @override
  State<CalendarViewModeDropdown> createState() =>
      _CalendarViewModeDropdownState();
}

class _CalendarViewModeDropdownState extends State<CalendarViewModeDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  String _labelFor(CalendarViewMode mode) {
    switch (mode) {
      case CalendarViewMode.month:
        return 'Month';
      case CalendarViewMode.week:
        return 'Week';
      case CalendarViewMode.day:
        return 'Day';
    }
  }

  String _menuLabelFor(CalendarViewMode mode) {
    switch (mode) {
      case CalendarViewMode.month:
        return 'Month View';
      case CalendarViewMode.week:
        return 'Week View';
      case CalendarViewMode.day:
        return 'Day View';
    }
  }

  IconData _iconFor(CalendarViewMode mode) {
    switch (mode) {
      case CalendarViewMode.month:
        return Icons.calendar_view_month_outlined;
      case CalendarViewMode.week:
        return Icons.view_week_outlined;
      case CalendarViewMode.day:
        return Icons.today_outlined;
    }
  }

  double _measureTextWidth(
    BuildContext context,
    String text,
    TextStyle style,
  ) {
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
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
      return;
    }

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final menuLabelStyle = AppTextStyles.labelLarge.copyWith(
      fontWeight: FontWeight.w600,
    );
    final longestMenuLabel = CalendarViewMode.values
        .map(_menuLabelFor)
        .map((label) => _measureTextWidth(context, label, menuLabelStyle))
        .fold<double>(0, math.max);
    final menuWidth = longestMenuLabel + 12 + 18 + 10 + 14 + 14;

    final overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeMenu,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 8),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: menuWidth,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: CalendarViewMode.values.map((mode) {
                          final isSelected = mode == widget.value;
                          return Material(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.09)
                                : AppColors.surface,
                            child: InkWell(
                              onTap: () {
                                widget.onChanged(mode);
                                _closeMenu();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      _iconFor(mode),
                                      size: 18,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _menuLabelFor(mode),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
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
    _closeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collapsedLabelStyle = AppTextStyles.labelLarge.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: _toggleMenu,
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconFor(widget.value),
                    color: AppColors.primary,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _labelFor(widget.value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: collapsedLabelStyle,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
