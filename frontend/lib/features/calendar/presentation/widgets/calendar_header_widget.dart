import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/calendar_event.dart';
import 'calendar_view_mode_dropdown.dart';

class CalendarHeaderWidget extends StatelessWidget {
  const CalendarHeaderWidget({
    super.key,
    required this.selectedDate,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTodayPressed,
    this.currentViewMode,
    this.onViewModeChanged,
  });

  final DateTime selectedDate;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onTodayPressed;
  final CalendarViewMode? currentViewMode;
  final ValueChanged<CalendarViewMode>? onViewModeChanged;

  String _formatMonthYear() {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[selectedDate.month - 1]} ${selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      padding: EdgeInsets.only(
        left: isSmallScreen ? 12.0 : 16.0,
        top: isSmallScreen ? 12.0 : 16.0,
        right: isSmallScreen ? 8.0 : 12.0,
        bottom: isSmallScreen ? 12.0 : 16.0,
      ),
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (currentViewMode != null && onViewModeChanged != null)
                CalendarViewModeDropdown(
                  value: currentViewMode!,
                  onChanged: onViewModeChanged!,
                ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: onPreviousMonth,
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.primary,
                    iconSize: isSmallScreen ? 22.0 : 26.0,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 30.0 : 38.0,
                      minHeight: isSmallScreen ? 30.0 : 38.0,
                    ),
                  ),
                  IconButton(
                    onPressed: onNextMonth,
                    icon: const Icon(Icons.chevron_right),
                    color: AppColors.primary,
                    iconSize: isSmallScreen ? 22.0 : 26.0,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 30.0 : 38.0,
                      minHeight: isSmallScreen ? 30.0 : 38.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _formatMonthYear(),
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: isSmallScreen ? 18.0 : 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onTodayPressed,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 12.0,
                    vertical: isSmallScreen ? 4.0 : 8.0,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Today',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: isSmallScreen ? 12.0 : 14.0,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
