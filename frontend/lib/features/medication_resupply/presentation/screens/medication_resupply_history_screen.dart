import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../health_records/presentation/widgets/health_record_search_filter_bar.dart';
import '../models/medication_resupply_models.dart';
import '../widgets/medication_resupply_history_item.dart';
import '../widgets/resupply_screen_header.dart';

class MedicationResupplyHistoryScreen extends StatefulWidget {
  const MedicationResupplyHistoryScreen({super.key});

  @override
  State<MedicationResupplyHistoryScreen> createState() =>
      _MedicationResupplyHistoryScreenState();
}

class _MedicationResupplyHistoryScreenState
    extends State<MedicationResupplyHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedEntryIds = <String>{};

  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: 'Prescription History Help',
          messages: const <String>[
            'Search by medicine name or note text.',
            'Use the status filter to narrow down the history list.',
            'Tap any card to expand its notes inline.',
          ],
          icons: const <IconData>[
            Icons.search_outlined,
            Icons.filter_alt_outlined,
            Icons.medical_information_outlined,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _toggleExpanded(String entryId) {
    setState(() {
      if (_expandedEntryIds.contains(entryId)) {
        _expandedEntryIds.remove(entryId);
      } else {
        _expandedEntryIds.add(entryId);
      }
    });
  }

  List<ResupplyHistoryEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();

    return mockResupplyHistoryEntries.where((entry) {
      final matchesStatus =
          _statusFilter == 'All' ||
          entry.status.label.toLowerCase() == _statusFilter.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          entry.medicationName.toLowerCase().contains(query) ||
          entry.dosage.toLowerCase().contains(query) ||
          entry.note.toLowerCase().contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final filteredEntries = _filteredEntries;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: isTablet ? 32.0 : 16.0,
                right: isTablet ? 32.0 : 16.0,
                top: 8.0,
              ),
              child: ResupplyScreenHeader(
                title: 'Prescription History',
                onBackPressed: () => Navigator.of(context).pop(),
                onHelpPressed: _showHelpDialog,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.0 : 16.0),
              child: HealthRecordSearchFilterBar(
                searchController: _searchController,
                searchHint: 'Search prescriptions',
                selectedFilter: _statusFilter,
                filterOptions: const <String>[
                  'All',
                  'Pending',
                  'Approved',
                  'Rejected',
                  'Cancelled',
                ],
                onSearchChanged: (_) => setState(() {}),
                onClearSearch: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
                onFilterChanged: (value) {
                  setState(() {
                    _statusFilter = value ?? 'All';
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32.0 : 16.0,
                ),
                child: filteredEntries.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filteredEntries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          final isExpanded = _expandedEntryIds.contains(
                            entry.id,
                          );

                          return MedicationResupplyHistoryItem(
                            entry: entry,
                            isExpanded: isExpanded,
                            onTap: () => _toggleExpanded(entry.id),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_outlined,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No matching requests',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term or status filter.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButtonWidget(
            text: 'Clear filters',
            onPressed: () {
              setState(() {
                _searchController.clear();
                _statusFilter = 'All';
              });
            },
            icon: Icons.restart_alt,
          ),
        ],
      ),
    );
  }
}
