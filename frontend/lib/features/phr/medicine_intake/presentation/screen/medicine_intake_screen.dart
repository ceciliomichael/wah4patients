import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../domain/medicine_status.dart';
import '../models/medicine_intake_models.dart';
import '../widgets/medicine_intake_add_dialog.dart';
import '../widgets/medicine_intake_empty_state.dart';
import '../widgets/medicine_intake_filter_bar.dart';
import '../widgets/medicine_intake_header.dart';
import '../widgets/medicine_intake_medicine_card.dart';

class MedicineIntakeScreen extends StatefulWidget {
  const MedicineIntakeScreen({super.key});

  @override
  State<MedicineIntakeScreen> createState() => _MedicineIntakeScreenState();
}

class _MedicineIntakeScreenState extends State<MedicineIntakeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  MedicineStatus? _selectedStatus;
  final Set<String> _expandedMedicineIds = <String>{};

  final List<MedicineIntakeEntry> _medicines = <MedicineIntakeEntry>[
    const MedicineIntakeEntry(
      id: 'amlodipine',
      name: 'Amlodipine',
      dosage: '5 mg tablet',
      schedule: 'Once daily after breakfast',
      nextDose: 'Today, 8:00 AM',
      notes: 'Take with water and keep a consistent schedule.',
      status: MedicineStatus.active,
    ),
    const MedicineIntakeEntry(
      id: 'metformin',
      name: 'Metformin',
      dosage: '500 mg tablet',
      schedule: 'Twice daily with meals',
      nextDose: 'Today, 7:00 PM',
      notes: 'Usually taken after meals to reduce stomach upset.',
      status: MedicineStatus.active,
    ),
    const MedicineIntakeEntry(
      id: 'atorvastatin',
      name: 'Atorvastatin',
      dosage: '20 mg tablet',
      schedule: 'Once nightly',
      nextDose: 'Tonight, 9:00 PM',
      notes: 'Best taken in the evening for a steady routine.',
      status: MedicineStatus.paused,
    ),
    const MedicineIntakeEntry(
      id: 'multivitamin',
      name: 'Multivitamin',
      dosage: '1 capsule',
      schedule: 'Daily with breakfast',
      nextDose: 'Tomorrow, 8:00 AM',
      notes: 'Use this as a simple daily supplement reminder.',
      status: MedicineStatus.completed,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => HelpModalWidget(
        title: 'Medicine Intake Help',
        messages: const <String>[
          'Search or filter the list to find a medicine quickly.',
          'Tap a medicine card to expand its details and schedule notes.',
          'Use Add Medicine to create a new local record for the session.',
        ],
        icons: const <IconData>[
          Icons.search_outlined,
          Icons.medication_outlined,
          Icons.add_circle_outline,
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

  List<MedicineIntakeEntry> get _filteredMedicines {
    final normalizedQuery = _searchQuery.toLowerCase();

    return _medicines.where((medicine) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          medicine.name.toLowerCase().contains(normalizedQuery) ||
          medicine.dosage.toLowerCase().contains(normalizedQuery) ||
          medicine.schedule.toLowerCase().contains(normalizedQuery);
      final matchesStatus =
          _selectedStatus == null || medicine.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatus = null;
      _expandedMedicineIds.clear();
    });
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedMedicineIds.contains(id)) {
        _expandedMedicineIds.remove(id);
      } else {
        _expandedMedicineIds.add(id);
      }
    });
  }

  Future<void> _showAddMedicineDialog() async {
    final result = await showDialog<MedicineIntakeDraft>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MedicineIntakeAddDialog(),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _medicines.insert(
        0,
        MedicineIntakeEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: result.name,
          dosage: result.dosage,
          schedule: result.schedule,
          nextDose: result.nextDose,
          notes: result.notes,
          status: result.status,
        ),
      );
    });

    _showSnackBar('Medicine added locally for this session.');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  MedicineIntakeHeader(
                    title: 'Medicine Intake',
                    isTablet: constraints.maxWidth >= 600,
                    onBackPressed: () => Navigator.of(context).pop(),
                    onHelpPressed: _showHelpDialog,
                  ),
                  const SizedBox(height: 16),
                  MedicineIntakeFilterBar(
                    searchController: _searchController,
                    onQueryChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onClearSearch: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                    selectedStatus: _selectedStatus,
                    onStatusChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryButtonWidget(
                    text: 'Add Medicine',
                    onPressed: _showAddMedicineDialog,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredMedicines.isEmpty
                        ? MedicineIntakeEmptyState(
                            hasFilters:
                                _searchQuery.isNotEmpty ||
                                _selectedStatus != null,
                            onClearFilters: _clearFilters,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: _filteredMedicines.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final medicine = _filteredMedicines[index];
                              final isExpanded = _expandedMedicineIds.contains(
                                medicine.id,
                              );

                              return MedicineIntakeMedicineCard(
                                entry: medicine,
                                isExpanded: isExpanded,
                                onTap: () => _toggleExpanded(medicine.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
