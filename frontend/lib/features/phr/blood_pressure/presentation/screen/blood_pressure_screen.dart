import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_border_radii.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../../../core/widgets/ui/buttons/primary_button_widget.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();

  _BloodPressureHistoryEntry? _latestEntry;

  final List<_BloodPressureHistoryEntry> _history =
      <_BloodPressureHistoryEntry>[
        _BloodPressureHistoryEntry(
          recordedAt: DateTime.now().subtract(const Duration(days: 1)),
          systolic: 118,
          diastolic: 78,
          category: 'Normal',
        ),
        _BloodPressureHistoryEntry(
          recordedAt: DateTime.now().subtract(const Duration(days: 4)),
          systolic: 124,
          diastolic: 82,
          category: 'Elevated',
        ),
        _BloodPressureHistoryEntry(
          recordedAt: DateTime.now().subtract(const Duration(days: 9)),
          systolic: 136,
          diastolic: 88,
          category: 'Stage 1 Hypertension',
        ),
      ];

  @override
  void initState() {
    super.initState();
    _latestEntry = _history.first;
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => HelpModalWidget(
        title: 'Blood Pressure Help',
        messages: const <String>[
          'Enter your systolic and diastolic readings, then review the category below.',
          'The screen stores readings locally for the current session only.',
          'Use the history tab to compare recent measurements at a glance.',
        ],
        icons: const <IconData>[
          Icons.favorite_outline,
          Icons.monitor_heart_outlined,
          Icons.history_outlined,
        ],
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  String _classify(int systolic, int diastolic) {
    if (systolic >= 180 || diastolic >= 120) {
      return 'Hypertensive Crisis';
    }
    if (systolic >= 140 || diastolic >= 90) {
      return 'Stage 2 Hypertension';
    }
    if (systolic >= 130 || diastolic >= 80) {
      return 'Stage 1 Hypertension';
    }
    if (systolic >= 120 && diastolic < 80) {
      return 'Elevated';
    }
    return 'Normal';
  }

  Color _categoryColor(String category) {
    return switch (category) {
      'Normal' => AppColors.success,
      'Elevated' => AppColors.secondary,
      'Stage 1 Hypertension' => AppColors.tertiary,
      'Stage 2 Hypertension' => AppColors.primary,
      'Hypertensive Crisis' => AppColors.danger,
      _ => AppColors.primary,
    };
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year}';
  }

  void _saveReading() {
    final systolic = int.tryParse(_systolicController.text.trim());
    final diastolic = int.tryParse(_diastolicController.text.trim());

    if (systolic == null ||
        diastolic == null ||
        systolic <= 0 ||
        diastolic <= 0) {
      _showSnackBar('Enter valid systolic and diastolic readings.');
      return;
    }

    final entry = _BloodPressureHistoryEntry(
      recordedAt: DateTime.now(),
      systolic: systolic,
      diastolic: diastolic,
      category: _classify(systolic, diastolic),
    );

    setState(() {
      _latestEntry = entry;
      _history.insert(0, entry);
    });

    _showSnackBar('Blood pressure entry saved locally for this session.');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth >= 900
                  ? constraints.maxWidth * 0.16
                  : constraints.maxWidth >= 600
                  ? 32.0
                  : 16.0;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(constraints.maxWidth >= 600),
                    const SizedBox(height: 12),
                    _buildTabBar(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [_buildAddRecordTab(), _buildHistoryTab()],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return AppScreenHeader(
      title: 'Blood Pressure',
      isTablet: isTablet,
      topPadding: 24.0,
      onBackPressed: () => Navigator.of(context).pop(),
      onHelpPressed: _showHelpDialog,
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      tabs: const <Tab>[
        Tab(icon: Icon(Icons.add), text: 'Add Record'),
        Tab(icon: Icon(Icons.history), text: 'History'),
      ],
    );
  }

  Widget _buildAddRecordTab() {
    final latestEntry = _latestEntry;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (latestEntry != null) ...[
            _buildSummaryCard(latestEntry),
            const SizedBox(height: 20),
          ],
          _buildSectionCard(
            title: 'Current Reading',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 520;
                final systolicField = _buildInputField(
                  controller: _systolicController,
                  label: 'Systolic',
                  hintText: 'e.g. 120',
                  icon: Icons.arrow_upward,
                );
                final diastolicField = _buildInputField(
                  controller: _diastolicController,
                  label: 'Diastolic',
                  hintText: 'e.g. 80',
                  icon: Icons.arrow_downward,
                );

                if (!isWide) {
                  return Column(
                    children: [
                      systolicField,
                      const SizedBox(height: 16),
                      diastolicField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: systolicField),
                    const SizedBox(width: 16),
                    Expanded(child: diastolicField),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButtonWidget(
            text: _latestEntry == null ? 'Check Reading' : 'Save New Reading',
            onPressed: _saveReading,
          ),
          const SizedBox(height: 12),
          Text(
            'Readings are stored locally in this session so you can compare recent values immediately.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(_BloodPressureHistoryEntry entry) {
    final categoryColor = _categoryColor(entry.category);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite_outline, color: categoryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Reading',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.systolic}/${entry.diastolic}',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.pill,
                ),
                child: Text(
                  entry.category,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metricChip('Systolic', '${entry.systolic} mmHg'),
              _metricChip('Diastolic', '${entry.diastolic} mmHg'),
              _metricChip('Recorded', _formatDate(entry.recordedAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadii.large,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _history[index];
        final categoryColor = _categoryColor(entry.category);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.extraLarge,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.medium,
                ),
                child: Icon(Icons.favorite_outline, color: categoryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.systolic}/${entry.diastolic} · ${entry.category}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recorded on ${_formatDate(entry.recordedAt)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.pill,
                ),
                child: Text(
                  entry.category,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BloodPressureHistoryEntry {
  const _BloodPressureHistoryEntry({
    required this.recordedAt,
    required this.systolic,
    required this.diastolic,
    required this.category,
  });

  final DateTime recordedAt;
  final int systolic;
  final int diastolic;
  final String category;
}
