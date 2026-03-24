import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
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

  final List<BodyMassIndexHistoryEntry> _history = <BodyMassIndexHistoryEntry>[
    BodyMassIndexHistoryEntry(
      recordedAt: DateTime.now().subtract(const Duration(days: 1)),
      weight: 60,
      height: 163,
      bmi: 22.6,
      category: 'Normal',
      unitSystem: BmiUnitSystem.metric,
      gender: BmiGender.female,
      age: 28,
    ),
    BodyMassIndexHistoryEntry(
      recordedAt: DateTime.now().subtract(const Duration(days: 5)),
      weight: 68,
      height: 170,
      bmi: 23.5,
      category: 'Normal',
      unitSystem: BmiUnitSystem.metric,
      gender: BmiGender.other,
      age: 34,
    ),
    BodyMassIndexHistoryEntry(
      recordedAt: DateTime.now().subtract(const Duration(days: 11)),
      weight: 135,
      height: 67,
      bmi: 21.1,
      category: 'Normal',
      unitSystem: BmiUnitSystem.imperial,
      gender: BmiGender.male,
      age: 31,
    ),
  ];

  BodyMassIndexHistoryEntry? get _latestEntry =>
      _history.isEmpty ? null : _history.first;

  bool get _hasTodayEntry {
    final latestEntry = _latestEntry;
    return latestEntry != null && isSameDay(latestEntry.recordedAt, DateTime.now());
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
          'Add your age and gender to keep the record organized.',
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

  void _calculateBmi() {
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

    final bmiValue = double.parse(
      calculateBmi(
        weight: weight,
        height: height,
        unitSystem: _unitSystem,
      ).toStringAsFixed(1),
    );

    final entry = BodyMassIndexHistoryEntry(
      recordedAt: DateTime.now(),
      weight: weight,
      height: height,
      bmi: bmiValue,
      category: bmiCategoryForValue(bmiValue),
      unitSystem: _unitSystem,
      gender: _selectedGender,
      age: _age,
    );

    setState(() {
      _history.insert(0, entry);
    });

    _showResultDialog(entry);
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
