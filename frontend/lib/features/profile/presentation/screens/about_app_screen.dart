import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

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
                  _AppBadge(isTablet: isTablet),
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    icon: Icons.favorite_outline,
                    title: 'Why this app exists',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'WAH for Patients exists to make health information and care-related updates easier to access, easier to understand, and easier to keep track of in daily life.',
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
                        icon: Icons.visibility_outlined,
                        text:
                            'Helps patients see their information in one clear place.',
                      ),
                      _BulletItem(
                        icon: Icons.schedule_outlined,
                        text:
                            'Makes it easier to stay aware of appointments and reminders.',
                      ),
                      _BulletItem(
                        icon: Icons.chat_bubble_outline,
                        text:
                            'Supports better awareness of updates shared by care partners.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    icon: Icons.groups_outlined,
                    title: 'Who it is for',
                  ),
                  const SizedBox(height: 12),
                  const _FeatureCardList(
                    items: <_FeatureCardData>[
                      _FeatureCardData(
                        icon: Icons.person_outline,
                        title: 'Patients',
                        body:
                            'For people who want a simpler way to stay connected to their health information and care journey.',
                      ),
                      _FeatureCardData(
                        icon: Icons.home_work_outlined,
                        title: 'Families and caregivers',
                        body:
                            'For people helping a loved one keep track of important care-related details and updates.',
                      ),
                      _FeatureCardData(
                        icon: Icons.local_hospital_outlined,
                        title: 'Partner facilities',
                        body:
                            'For health partners that want to present information in a clearer, more patient-friendly way.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    icon: Icons.check_circle_outline,
                    title: 'What the app helps with',
                  ),
                  const SizedBox(height: 12),
                  const _SimpleBulletList(
                    items: <_BulletItem>[
                      _BulletItem(
                        icon: Icons.medical_information_outlined,
                        text:
                            'Bringing important health information into a more understandable view.',
                      ),
                      _BulletItem(
                        icon: Icons.alarm_on_outlined,
                        text:
                            'Helping users remember the care-related moments that matter.',
                      ),
                      _BulletItem(
                        icon: Icons.handshake_outlined,
                        text:
                            'Strengthening the connection between patients and their care providers.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    icon: Icons.waving_hand_outlined,
                    title: 'A simple experience',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The app is built to feel approachable and calm, so patients can focus on their care instead of figuring out where to look. The goal is clarity, convenience, and confidence.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
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
            'About the App',
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
            'A patient-first app focused on clarity, access, and support.',
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

class _AppBadge extends StatelessWidget {
  const _AppBadge({required this.isTablet});

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
        child: const Icon(
          Icons.favorite_outline,
          size: 48,
          color: AppColors.primary,
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

class _FeatureCardList extends StatelessWidget {
  const _FeatureCardList({required this.items});

  final List<_FeatureCardData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FeatureCard(data: item),
            ),
          )
          .toList(),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data});

  final _FeatureCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.body,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
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

class _BulletItem {
  const _BulletItem({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _FeatureCardData {
  const _FeatureCardData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
