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

enum TemperatureUnitSystem { celsius, fahrenheit }

extension on TemperatureUnitSystem {
  String get label => switch (this) {
    TemperatureUnitSystem.celsius => 'Celsius',
    TemperatureUnitSystem.fahrenheit => 'Fahrenheit',
  };

  String get symbol => switch (this) {
    TemperatureUnitSystem.celsius => '°C',
    TemperatureUnitSystem.fahrenheit => '°F',
  };
}

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  final TextEditingController _temperatureController = TextEditingController();

  TemperatureUnitSystem _unitSystem = TemperatureUnitSystem.celsius;
  _TemperatureHistoryEntry? _latestEntry;

  final List<_TemperatureHistoryEntry> _history = <_TemperatureHistoryEntry>[];
  bool _isLoadingHistory = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadHistory());
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => HelpModalWidget(
        title: 'Body Temperature Help',
        messages: const <String>[
          'Choose the unit you want to enter, then type your temperature reading.',
          'Temperature readings are saved to the database and loaded into history.',
          'Use the history tab to compare recent values and categories.',
        ],
        icons: const <IconData>[
          Icons.thermostat_outlined,
          Icons.swap_horiz_outlined,
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
        _historyError = 'Please sign in again to load temperature records.';
        _isLoadingHistory = false;
      });
      return;
    }

    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final response = await PersonalRecordsApiClient.instance.getTemperatureRecords(
        accessToken: accessToken,
      );
      final history = response.records
          .map(_TemperatureHistoryEntry.fromRecord)
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

  double _toCelsius(double value) {
    return _unitSystem == TemperatureUnitSystem.celsius
        ? value
        : (value - 32) * 5 / 9;
  }

  Color _categoryColor(String category) {
    return switch (category) {
      'Low' => AppColors.secondary,
      'Normal' => AppColors.success,
      'Elevated' => AppColors.tertiary,
      'Fever' => AppColors.danger,
      _ => AppColors.primary,
    };
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year}';
  }

  void _toggleUnitSystem(TemperatureUnitSystem value) {
    if (_unitSystem == value) {
      return;
    }

    setState(() {
      _unitSystem = value;
    });
  }

  Future<void> _saveTemperature() async {
    final temperature = double.tryParse(_temperatureController.text.trim());
    if (temperature == null || temperature <= 0) {
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in again to save temperature records.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    try {
      final response = await PersonalRecordsApiClient.instance.createTemperatureRecord(
        accessToken: accessToken,
        temperatureValue: double.parse(temperature.toStringAsFixed(1)),
        temperatureUnit: _unitSystem == TemperatureUnitSystem.celsius
            ? 'celsius'
            : 'fahrenheit',
      );
      final entry = _TemperatureHistoryEntry.fromRecord(response);

      if (!mounted) {
        return;
      }

      setState(() {
        _latestEntry = entry;
        _history.insert(0, entry);
        _temperatureController.clear();
      });
    } on PersonalRecordsApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: AppColors.primary),
      );
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
      title: 'Temperature',
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
          Text(
            'Temperature Entry',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TemperatureUnitToggle(
            unitSystem: _unitSystem,
            onUnitSystemChanged: _toggleUnitSystem,
          ),
          const SizedBox(height: 12),
          Text(
            'Temperature (${_unitSystem.symbol})',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _temperatureController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: _unitSystem == TemperatureUnitSystem.celsius
                  ? 'Enter temperature in °C'
                  : 'Enter temperature in °F',
              prefixIcon: const Icon(
                Icons.thermostat_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButtonWidget(
            text: 'SAVE TEMPERATURE',
            onPressed: _saveTemperature,
          ),
          const SizedBox(height: 12),
          Text(
            'Selected unit: ${_unitSystem.symbol}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(_TemperatureHistoryEntry entry) {
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
                  Icons.thermostat_outlined,
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Latest Temperature',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTemperatureRow(
            label: 'Value',
            value:
                '${entry.temperature.toStringAsFixed(1)}${entry.unitSystem.symbol}',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildTemperatureRow(
            label: 'Celsius',
            value: '${_toCelsius(entry.temperature).toStringAsFixed(1)}°C',
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildTemperatureRow(label: 'Category', value: entry.category),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 12),
          _buildTemperatureRow(
            label: 'Recorded on',
            value: _formatDate(entry.recordedAt),
          ),
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
          'No temperature records saved yet.',
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
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadii.extraLarge,
                    ),
                    child: const Icon(
                      Icons.thermostat_outlined,
                      color: AppColors.primary,
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
              _buildTemperatureRow(
                label: 'Value',
                value:
                    '${entry.temperature.toStringAsFixed(1)}${entry.unitSystem.symbol}',
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
              _buildTemperatureRow(
                label: 'Celsius',
                value: '${_toCelsius(entry.temperature).toStringAsFixed(1)}°C',
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
              _buildTemperatureRow(label: 'Category', value: entry.category),
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1),
              const SizedBox(height: 12),
              _buildTemperatureRow(
                label: 'Recorded on',
                value: _formatDate(entry.recordedAt),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemperatureRow({required String label, required String value}) {
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

class _TemperatureHistoryEntry {
  const _TemperatureHistoryEntry({
    required this.recordedAt,
    required this.temperature,
    required this.unitSystem,
    required this.category,
  });

  final DateTime recordedAt;
  final double temperature;
  final TemperatureUnitSystem unitSystem;
  final String category;

  factory _TemperatureHistoryEntry.fromRecord(TemperatureRecordResponse record) {
    final unitSystem = record.temperatureUnit == 'fahrenheit'
        ? TemperatureUnitSystem.fahrenheit
        : TemperatureUnitSystem.celsius;
    return _TemperatureHistoryEntry(
      recordedAt: record.recordedAt,
      temperature: record.temperatureValue,
      unitSystem: unitSystem,
      category: _categorizeTemperature(record.normalizedCelsius),
    );
  }
}

String _categorizeTemperature(double celsius) {
  if (celsius < 36.0) {
    return 'Low';
  }
  if (celsius < 37.3) {
    return 'Normal';
  }
  if (celsius < 38.0) {
    return 'Elevated';
  }
  return 'Fever';
}

class TemperatureUnitToggle extends StatelessWidget {
  const TemperatureUnitToggle({
    super.key,
    required this.unitSystem,
    required this.onUnitSystemChanged,
  });

  final TemperatureUnitSystem unitSystem;
  final ValueChanged<TemperatureUnitSystem> onUnitSystemChanged;

  @override
  Widget build(BuildContext context) {
    final isCelsius = unitSystem == TemperatureUnitSystem.celsius;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: _buildSegment(
              label: TemperatureUnitSystem.celsius.label,
              selected: isCelsius,
              onTap: () => onUnitSystemChanged(TemperatureUnitSystem.celsius),
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.border),
          Expanded(
            child: _buildSegment(
              label: TemperatureUnitSystem.fahrenheit.label,
              selected: !isCelsius,
              onTap: () =>
                  onUnitSystemChanged(TemperatureUnitSystem.fahrenheit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? AppColors.tertiary.withValues(alpha: 0.12)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.tertiary : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
