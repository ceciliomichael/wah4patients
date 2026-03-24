import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

enum DashboardAlertFilter { all, unread, priority }

class DashboardAlertsTab extends StatefulWidget {
  const DashboardAlertsTab({super.key});

  @override
  State<DashboardAlertsTab> createState() => _DashboardAlertsTabState();
}

class _DashboardAlertsTabState extends State<DashboardAlertsTab> {
  DashboardAlertFilter _filter = DashboardAlertFilter.all;

  static const List<_AlertItem> _alerts = <_AlertItem>[
    _AlertItem(
      title: 'Lab results are ready',
      subtitle: 'Your latest laboratory report can be reviewed now.',
      timeLabel: 'Just now',
      icon: Icons.science_outlined,
      color: AppColors.primary,
      unread: true,
      priority: true,
    ),
    _AlertItem(
      title: 'Medication refill reminder',
      subtitle: 'You may want to restock the remaining tablets soon.',
      timeLabel: '1h ago',
      icon: Icons.medication_outlined,
      color: AppColors.secondary,
      unread: true,
      priority: false,
    ),
    _AlertItem(
      title: 'Upcoming appointment',
      subtitle: 'Your consultation is scheduled for tomorrow morning.',
      timeLabel: 'Yesterday',
      icon: Icons.calendar_month_outlined,
      color: AppColors.tertiary,
      unread: false,
      priority: false,
    ),
    _AlertItem(
      title: 'Health tip',
      subtitle: 'Take a short walk to loosen up after a long screen session.',
      timeLabel: '2 days ago',
      icon: Icons.lightbulb_outline,
      color: AppColors.primaryDark,
      unread: false,
      priority: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final filtered = _alerts.where((alert) {
      return switch (_filter) {
        DashboardAlertFilter.all => true,
        DashboardAlertFilter.unread => alert.unread,
        DashboardAlertFilter.priority => alert.priority,
      };
    }).toList();

    final unreadCount = _alerts.where((alert) => alert.unread).length;
    final priorityCount = _alerts.where((alert) => alert.priority).length;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 20,
        18,
        isTablet ? 32 : 20,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Notification',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A lightweight notifications screen that keeps the same clean positioning.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.extraLarge,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AlertSummaryCard(
                    label: 'Unread',
                    value: unreadCount,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AlertSummaryCard(
                    label: 'Priority',
                    value: priorityCount,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DashboardAlertFilter.values.map((filter) {
              final selected = _filter == filter;
              final label = switch (filter) {
                DashboardAlertFilter.all => 'All',
                DashboardAlertFilter.unread => 'Unread',
                DashboardAlertFilter.priority => 'Priority',
              };

              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _filter = filter;
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.12),
                labelStyle: AppTextStyles.labelLarge.copyWith(
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.small,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          ...filtered.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: alert.unread
                      ? alert.color.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: AppRadii.large,
                  border: Border.all(
                    color: alert.unread
                        ? alert.color.withValues(alpha: 0.18)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.medium,
                      ),
                      child: Icon(alert.icon, color: alert.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.title,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                alert.timeLabel,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.subtitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.08),
              borderRadius: AppRadii.large,
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.tertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These alerts are frontend-only for now, so the layout is ready without any notification-service wiring.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertSummaryCard extends StatelessWidget {
  const _AlertSummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadii.large,
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertItem {
  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.icon,
    required this.color,
    required this.unread,
    required this.priority,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final IconData icon;
  final Color color;
  final bool unread;
  final bool priority;
}
