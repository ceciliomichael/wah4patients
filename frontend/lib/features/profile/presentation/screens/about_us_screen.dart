import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            mediaQuery.viewInsets.bottom + 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      splashRadius: 20,
                      tooltip: 'Back',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PageHeader(isTablet: isTablet),
                  const SizedBox(height: 28),
                  _LogoBadge(isTablet: isTablet),
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    icon: Icons.groups_outlined,
                    title: 'Who we are',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'WAH for Patients works with local partners to make digital health services easier to use, easier to understand, and easier to sustain.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  const _SimpleBulletList(
                    items: <_BulletItem>[
                      _BulletItem(
                        icon: Icons.health_and_safety_outlined,
                        text:
                            'Supports public health work with practical digital tools.',
                      ),
                      _BulletItem(
                        icon: Icons.developer_board_outlined,
                        text:
                            'Builds systems that help teams manage and share data.',
                      ),
                      _BulletItem(
                        icon: Icons.groups_outlined,
                        text:
                            'Grows with partners instead of replacing their local process.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    icon: Icons.flag_outlined,
                    title: 'Our mission',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'To empower partner LGUs and health facilities through effective use of digital health technology and generation and sharing of quality electronic data for universal usability towards self-reliance.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle(
                    icon: Icons.visibility_outlined,
                    title: 'What guides us',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Integrity, teamwork, innovation, and a strong appetite for learning shape how the team works with communities and partners.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  const _SimpleBulletList(
                    items: <_BulletItem>[
                      _BulletItem(
                        icon: Icons.verified_outlined,
                        text: 'Integrity in how we build and communicate.',
                      ),
                      _BulletItem(
                        icon: Icons.groups_outlined,
                        text: 'Teamwork across programs, operations, and support.',
                      ),
                      _BulletItem(
                        icon: Icons.auto_awesome_outlined,
                        text:
                            'Innovation that keeps public health work practical.',
                      ),
                      _BulletItem(
                        icon: Icons.school_outlined,
                        text: 'Learning that helps the platform keep improving.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    icon: Icons.timeline_outlined,
                    title: 'A short journey',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A few milestones show how the organization has grown alongside its partners.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const _TimelineList(items: _milestones),
                  const SizedBox(height: 32),
                  PrimaryButtonWidget(
                    text: 'Back to Profile',
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                        AppRoutes.profile,
                      );
                    },
                    icon: Icons.arrow_forward,
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

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'About Us',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontSize: isTablet ? 36.0 : 30.0,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'The people, partnership, and public health mission behind WAH for Patients.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final size = isTablet ? 120.0 : 96.0;

    return Center(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: Image.asset(
          'assets/images/logo/wahforpatients_horizontal.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleBulletList extends StatelessWidget {
  const _SimpleBulletList({required this.items});

  final List<_BulletItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BulletRow(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.item});

  final _BulletItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 16, color: AppColors.secondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.items});

  final List<_MilestoneData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (milestone) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _TimelineRow(milestone: milestone),
            ),
          )
          .toList(),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.milestone});

  final _MilestoneData milestone;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 48,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.year,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  milestone.body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BulletItem {
  const _BulletItem({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _MilestoneData {
  const _MilestoneData({
    required this.year,
    required this.title,
    required this.body,
  });

  final String year;
  final String title;
  final String body;
}

const List<_MilestoneData> _milestones = <_MilestoneData>[
  _MilestoneData(
    year: '2009',
    title: 'The project begins',
    body:
        'The Philippine Wireless Reach Project was created to investigate paperless recording and wireless electronic reporting of medical and health data.',
  ),
  _MilestoneData(
    year: '2010',
    title: 'WAH is branded',
    body:
        'The project becomes Wireless Access for Health and moves into pilot testing of the WAH Electronic Medical Recording system in four municipalities in Tarlac.',
  ),
  _MilestoneData(
    year: '2015',
    title: 'Built for sustainability',
    body:
        'WAH transforms into a non-stock, non-profit organization and expands its partnerships beyond Tarlac to more provinces across the country.',
  ),
  _MilestoneData(
    year: '2024',
    title: 'A decade of impact',
    body:
        'WAH marks its 10th anniversary by bringing partners together for conversations on UHC, PhilHealth Konsulta, interoperability, digital health, and health systems integration.',
  ),
];
