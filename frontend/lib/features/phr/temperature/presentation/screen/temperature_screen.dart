import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_border_radii.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/constants/app_text_styles.dart';
import '../../../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../../../core/widgets/ui/buttons/primary_button_widget.dart';

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

  final List<_TemperatureHistoryEntry> _history = <_TemperatureHistoryEntry>[
    _TemperatureHistoryEntry(
      recordedAt: DateTime.now().subtract(const Duration(days: 1)),
      temperature: 36.6,
      unitSystem: TemperatureUnitSystem.celsius,
      category: 'Normal',
    ),
    _TemperatureHistoryEntry(
      recordedAt: DateTime.now().subtract(const Duration(days: 4)),
      temperature: 37.8,
      unitSystem: TemperatureUnitSystem.celsius,
      category: 'Elevated',
    ),
    _TemperatureHistoryEntry(
      recordedAt: DateTime.now().subtract(const Duration(days: 8)),
      temperature: 99.1,
      unitSystem: TemperatureUnitSystem.fahrenheit,
      category: 'Normal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _latestEntry = _history.first;
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
          'The screen converts values locally so the history remains easy to scan.',
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  double _toCelsius(double value) {
    return _unitSystem == TemperatureUnitSystem.celsius
        ? value
        : (value - 32) * 5 / 9;
  }

  String _categorize(double celsius) {
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

  void _saveTemperature() {
    final temperature = double.tryParse(_temperatureController.text.trim());
    if (temperature == null || temperature <= 0) {
      _showSnackBar('Enter a valid temperature reading.');
      return;
    }

    final celsius = _toCelsius(temperature);
    final entry = _TemperatureHistoryEntry(
      recordedAt: DateTime.now(),
      temperature: double.parse(temperature.toStringAsFixed(1)),
      unitSystem: _unitSystem,
      category: _categorize(celsius),
    );

    setState(() {
      _latestEntry = entry;
      _history.insert(0, entry);
    });

    _showSnackBar('Temperature entry saved locally for this session.');
  }

  void _toggleUnitSystem(TemperatureUnitSystem value) {
    if (_unitSystem == value) {
      return;
    }

    setState(() {
      _unitSystem = value;
      _temperatureController.clear();
    });
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
          _buildSectionCard(
            title: 'Temperature Entry',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: TemperatureUnitSystem.values.map((unit) {
                    final isSelected = _unitSystem == unit;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: unit == TemperatureUnitSystem.celsius ? 8 : 0,
                          left: unit == TemperatureUnitSystem.fahrenheit
                              ? 8
                              : 0,
                        ),
                        child: ChoiceChip(
                          label: Text(unit.label),
                          selected: isSelected,
                          selectedColor: AppColors.tertiary.withValues(
                            alpha: 0.12,
                          ),
                          labelStyle: AppTextStyles.labelLarge.copyWith(
                            color: isSelected
                                ? AppColors.tertiary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) => _toggleUnitSystem(unit),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.tertiary
                                : AppColors.border,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.large,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Temperature (${_unitSystem.symbol})',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _temperatureController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButtonWidget(
            text: _latestEntry == null
                ? 'Save Temperature'
                : 'Save New Reading',
            onPressed: _saveTemperature,
          ),
          const SizedBox(height: 12),
          Text(
            'Your latest reading stays visible above the form for quick comparison.',
            textAlign: TextAlign.center,
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
                child: Icon(Icons.thermostat_outlined, color: categoryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Temperature',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.temperature.toStringAsFixed(1)}${entry.unitSystem.symbol}',
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
              _metricChip(
                'Value',
                '${entry.temperature.toStringAsFixed(1)}${entry.unitSystem.symbol}',
              ),
              _metricChip(
                'Celsius',
                '${_toCelsius(entry.temperature).toStringAsFixed(1)}°C',
              ),
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
                child: Icon(Icons.thermostat_outlined, color: categoryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.temperature.toStringAsFixed(1)}${entry.unitSystem.symbol} · ${entry.category}',
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
}
