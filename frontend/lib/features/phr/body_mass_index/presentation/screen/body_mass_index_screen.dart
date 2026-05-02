import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../auth/domain/auth_session.dart';
import '../../../data/personal_records_api_client.dart';
import '../../../../../../core/widgets/feature/help_modal_widget.dart';
import '../models/body_mass_index_models.dart';
import '../utils/body_mass_index_calculations.dart';
import '../widgets/body_mass_index_add_record_form.dart';
import '../widgets/body_mass_index_header.dart';
import '../widgets/body_mass_index_history_empty_state.dart';
import '../widgets/body_mass_index_history_item.dart';
import '../widgets/body_mass_index_result_dialog.dart';
import '../widgets/body_mass_index_tab_bar.dart';
import '../widgets/body_mass_index_today_summary_card.dart';

class BodyMassIndexScreen extends StatefulWidget {
  const BodyMassIndexScreen({super.key});

  @override
  State<BodyMassIndexScreen> createState() => _BodyMassIndexScreenState();
}

class _BodyMassIndexScreenState extends State<BodyMassIndexScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  BmiUnitSystem _unitSystem = BmiUnitSystem.metric;
  BmiGender _selectedGender = BmiGender.female;
  int _age = 28;

  final List<BodyMassIndexHistoryEntry> _history = <BodyMassIndexHistoryEntry>[];
  bool _isLoadingHistory = true;
  String? _historyError;

  BodyMassIndexHistoryEntry? get _latestEntry =>
      _history.isEmpty ? null : _history.first;

  bool get _hasTodayEntry {
    final latestEntry = _latestEntry;
    return latestEntry != null && isSameDay(latestEntry.recordedAt, DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadHistory());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => HelpModalWidget(
        title: 'BMI Help',
        messages: const <String>[
          'Switch between metric and imperial units before entering your values.',
          'Your readings are saved to the database and loaded back into history.',
          'Use the history tab to review recent BMI entries on this screen.',
        ],
        icons: const <IconData>[
          Icons.swap_horiz_outlined,
          Icons.person_outline,
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
        _historyError = 'Please sign in again to load BMI records.';
        _isLoadingHistory = false;
      });
      return;
    }

    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });

    try {
      final response = await PersonalRecordsApiClient.instance.getBmiRecords(
        accessToken: accessToken,
      );
      final history = response.records
          .map(BodyMassIndexHistoryEntry.fromRecord)
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _history
          ..clear()
          ..addAll(history);
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

  void _toggleUnitSystem(BmiUnitSystem nextSystem) {
    if (_unitSystem == nextSystem) {
      return;
    }

    setState(() {
      _unitSystem = nextSystem;
      _weightController.clear();
      _heightController.clear();
    });
  }

  void _increaseAge() {
    setState(() {
      _age += 1;
    });
  }

  void _decreaseAge() {
    if (_age <= 12) {
      return;
    }

    setState(() {
      _age -= 1;
    });
  }

  Future<void> _calculateBmi() async {
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    if (weight == null || height == null || weight <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid weight and height values.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in again to save BMI records.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    try {
      final response = await PersonalRecordsApiClient.instance.createBmiRecord(
        accessToken: accessToken,
        weightValue: weight,
        heightValue: height,
        measurementSystem: _unitSystem == BmiUnitSystem.metric
            ? 'metric'
            : 'imperial',
      );
      final entry = BodyMassIndexHistoryEntry.fromRecord(response);

      if (!mounted) {
        return;
      }

      setState(() {
        _history.insert(0, entry);
        _weightController.clear();
        _heightController.clear();
      });

      _showResultDialog(entry);
    } on PersonalRecordsApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showResultDialog(BodyMassIndexHistoryEntry entry) {
    showDialog<void>(
      context: context,
      builder: (context) => BodyMassIndexResultDialog(
        entry: entry,
        onConfirmPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: DefaultTabController(
          length: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BodyMassIndexHeader(
                  title: 'Body Mass Index (BMI)',
                  isTablet: isTablet,
                  onBackPressed: () => Navigator.of(context).pop(),
                  onHelpPressed: _showHelpDialog,
                ),
                const SizedBox(height: 4),
                const BodyMassIndexTabBar(),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _buildAddRecordTab(),
                      _buildHistoryTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddRecordTab() {
    final latestEntry = _latestEntry;

    if (_hasTodayEntry && latestEntry != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: BodyMassIndexTodaySummaryCard(entry: latestEntry),
      );
    }

    return BodyMassIndexAddRecordForm(
      unitSystem: _unitSystem,
      selectedGender: _selectedGender,
      age: _age,
      weightController: _weightController,
      heightController: _heightController,
      onUnitSystemChanged: _toggleUnitSystem,
      onGenderChanged: (gender) {
        setState(() {
          _selectedGender = gender;
        });
      },
      onAgeDecreased: _decreaseAge,
      onAgeIncreased: _increaseAge,
      onCalculatePressed: _calculateBmi,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return const BodyMassIndexHistoryEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return BodyMassIndexHistoryItem(entry: _history[index]);
      },
    );
  }
}
