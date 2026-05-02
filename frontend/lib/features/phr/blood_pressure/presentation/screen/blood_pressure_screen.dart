import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_border_radii.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../auth/domain/auth_session.dart';
import '../../../data/personal_records_api_client.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();

  _BloodPressureHistoryEntry? _latestEntry;
  final List<_BloodPressureHistoryEntry> _history = <_BloodPressureHistoryEntry>[];
  bool _isLoadingHistory = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadHistory());
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
          'Your readings are saved to the database and loaded back into history.',
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

  Future<void> _loadHistory() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _historyError = 'Please sign in again to load blood pressure records.';
        _isLoadingHistory = false;
      });
      return;
    }

    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final response = await PersonalRecordsApiClient.instance
          .getBloodPressureRecords(accessToken: accessToken);
      final history = response.records
          .map(_BloodPressureHistoryEntry.fromRecord)
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _history
          ..clear()
          ..addAll(history);
        _latestEntry = _history.isEmpty ? null : _history.first;
        _isLoadingHistory = false;
      });
    } on PersonalRecordsApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _historyError = error.message;
        _isLoadingHistory = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
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

  Future<void> _saveReading() async {
    final systolic = int.tryParse(_systolicController.text.trim());
    final diastolic = int.tryParse(_diastolicController.text.trim());

    if (systolic == null ||
        diastolic == null ||
        systolic <= 0 ||
        diastolic <= 0) {
      _showSnackBar('Enter valid systolic and diastolic readings.');
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _showSnackBar('Please sign in again to save blood pressure records.');
      return;
    }

    try {
      final response = await PersonalRecordsApiClient.instance
          .createBloodPressureRecord(
        accessToken: accessToken,
        systolicMmHg: systolic,
        diastolicMmHg: diastolic,
      );
      final entry = _BloodPressureHistoryEntry.fromRecord(response);

      if (!mounted) {
        return;
      }

      setState(() {
        _latestEntry = entry;
        _history.insert(0, entry);
        _systolicController.clear();
        _diastolicController.clear();
      });

      _showSnackBar('Blood pressure entry saved to the database.');
    } on PersonalRecordsApiException catch (error) {
      _showSnackBar(error.message);
    }
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
            'Readings are saved to the database so you can compare recent values immediately.',
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: AppRadii.extraLarge,
                ),
                child: Icon(
                  Icons.favorite_outline,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Latest Reading',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHistoryRow(
            label: 'Systolic',
            value: '${entry.systolic} mmHg',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildHistoryRow(
            label: 'Diastolic',
            value: '${entry.diastolic} mmHg',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildHistoryRow(
            label: 'Category',
            value: entry.category,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildHistoryRow(
            label: 'Recorded on',
            value: _formatDate(entry.recordedAt),
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
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_historyError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _historyError!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Text(
          'No blood pressure readings saved yet.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = _history[index];
        final categoryColor = _categoryColor(entry.category);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: AppRadii.extraLarge,
                    ),
                    child: Icon(
                      Icons.favorite_outline,
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reading ${index + 1}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildHistoryRow(
                label: 'Systolic',
                value: '${entry.systolic} mmHg',
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
              _buildHistoryRow(
                label: 'Diastolic',
                value: '${entry.diastolic} mmHg',
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
              _buildHistoryRow(
                label: 'Category',
                value: entry.category,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
              _buildHistoryRow(
                label: 'Recorded on',
                value: _formatDate(entry.recordedAt),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          textAlign: TextAlign.end,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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

  factory _BloodPressureHistoryEntry.fromRecord(
    BloodPressureRecordResponse record,
  ) {
    return _BloodPressureHistoryEntry(
      recordedAt: record.recordedAt,
      systolic: record.systolicMmHg,
      diastolic: record.diastolicMmHg,
      category: classifyBloodPressure(record.systolicMmHg, record.diastolicMmHg),
    );
  }
}

String classifyBloodPressure(int systolic, int diastolic) {
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
