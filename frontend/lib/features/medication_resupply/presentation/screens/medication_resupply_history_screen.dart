import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../models/medication_resupply_models.dart';
import '../widgets/resupply_screen_header.dart';

class MedicationResupplyHistoryScreen extends StatefulWidget {
  const MedicationResupplyHistoryScreen({super.key});

  @override
  State<MedicationResupplyHistoryScreen> createState() =>
      _MedicationResupplyHistoryScreenState();
}

class _MedicationResupplyHistoryScreenState
    extends State<MedicationResupplyHistoryScreen> {
  final _searchController = TextEditingController();

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
            'Tap any row to view the details of a recorded request.',
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

  void _showDetailsDialog(ResupplyHistoryEntry entry) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.extraLarge,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: entry.status.tint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(entry.status.icon, color: entry.status.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.medicationName,
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Dosage', entry.dosage),
                const SizedBox(height: 8),
                _buildDetailRow('Requested on', entry.requestDate),
                const SizedBox(height: 8),
                _buildDetailRow('Status', entry.status.label),
                const SizedBox(height: 8),
                _buildDetailRow('Note', entry.note),
                const SizedBox(height: 20),
                PrimaryButtonWidget(
                  text: 'Close',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: Icons.close,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final filteredEntries = _filteredEntries;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ResupplyScreenHeader(
              title: 'Prescription History',
              onBackPressed: () => Navigator.of(context).pop(),
              onHelpPressed: _showHelpDialog,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32.0 : 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.large,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search prescriptions',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.large,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _statusFilter,
                        borderRadius: AppRadii.large,
                        icon: const Icon(
                          Icons.filter_list,
                          color: AppColors.primary,
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        items:
                            const <String>[
                              'All',
                              'Pending',
                              'Approved',
                              'Rejected',
                              'Cancelled',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value == 'All' ? 'All status' : value,
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _statusFilter = value ?? 'All';
                          });
                        },
                      ),
                    ),
                  ),
                ],
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
                        itemCount: filteredEntries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = filteredEntries[index];
                          return Material(
                            color: AppColors.surface,
                            borderRadius: AppRadii.large,
                            child: InkWell(
                              onTap: () => _showDetailsDialog(entry),
                              borderRadius: AppRadii.large,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: AppRadii.large,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: entry.status.tint,
                                        borderRadius: AppRadii.medium,
                                      ),
                                      child: Icon(
                                        entry.status.icon,
                                        color: entry.status.color,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            entry.medicationName,
                                            style: AppTextStyles.titleLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.dosage,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              _StatusChip(entry.status),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  entry.requestDate,
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final ResupplyRequestStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.tint,
        borderRadius: AppRadii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.color, size: 14),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: AppTextStyles.labelMedium.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
