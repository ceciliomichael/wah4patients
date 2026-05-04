import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../health_records/presentation/widgets/health_record_search_filter_bar.dart';
import '../models/medication_resupply_models.dart';
import 'medication_resupply_history_item.dart';
import 'resupply_screen_header.dart';

class MedicationResupplyHistoryScreenTemplate extends StatefulWidget {
  const MedicationResupplyHistoryScreenTemplate({
    super.key,
    required this.content,
    this.isLoading = false,
    this.loadErrorMessage,
    this.onRetry,
  });

  final ResupplyHistoryScreenContent content;
  final bool isLoading;
  final String? loadErrorMessage;
  final VoidCallback? onRetry;

  @override
  State<MedicationResupplyHistoryScreenTemplate> createState() =>
      _MedicationResupplyHistoryScreenTemplateState();
}

class _MedicationResupplyHistoryScreenTemplateState
    extends State<MedicationResupplyHistoryScreenTemplate> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedFilter;
  final Set<String> _expandedEntryIds = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.content.filterOptions.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    return widget.content.entries.where((entry) {
      final matchesFilter =
          _selectedFilter == widget.content.filterOptions.first ||
          entry.status.label == _selectedFilter;
      final haystack = [
        entry.medicationName,
        entry.dosage,
        entry.requestDate,
        entry.status.label,
        entry.note,
      ].join(' ').toLowerCase();
      final matchesSearch = query.isEmpty || haystack.contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: widget.content.helpTitle,
          messages: widget.content.helpMessages,
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    final entries = _filteredEntries;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResupplyScreenHeader(
                title: widget.content.title,
                onBackPressed: () => Navigator.of(context).pop(),
                onHelpPressed: _showHelpDialog,
              ),
              const SizedBox(height: 12),
              HealthRecordSearchFilterBar(
                searchController: _searchController,
                searchHint: widget.content.searchHint,
                selectedFilter: _selectedFilter,
                filterOptions: widget.content.filterOptions,
                onSearchChanged: (_) => setState(() {}),
                onClearSearch: () {
                  setState(() {
                    _searchController.clear();
                  });
                },
                onFilterChanged: (value) {
                  setState(() {
                    _selectedFilter = value ?? widget.content.filterOptions.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildRecordContent(entries)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordContent(List<ResupplyHistoryEntry> entries) {
    if (widget.isLoading && entries.isEmpty) {
      return _buildQuietLoadingState();
    }

    final loadErrorMessage = widget.loadErrorMessage;
    if (loadErrorMessage != null && entries.isEmpty) {
      return _buildInlineErrorState(loadErrorMessage);
    }

    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isExpanded = _expandedEntryIds.contains(entry.id);
            return MedicationResupplyHistoryItem(
              entry: entry,
              isExpanded: isExpanded,
              onTap: () => _toggleExpanded(entry.id),
            );
          },
        ),
        if (widget.isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primary,
              backgroundColor: Colors.transparent,
            ),
          ),
      ],
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
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_outlined,
              color: AppColors.textSecondary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.content.emptyTitle,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            widget.content.emptyMessage,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuietLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
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
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlaceholderBar(widthFactor: 0.52),
                        const SizedBox(height: 8),
                        _buildPlaceholderBar(widthFactor: 0.78),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildPlaceholderBar(widthFactor: 0.45),
              const SizedBox(height: 10),
              _buildPlaceholderBar(widthFactor: 0.68),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderBar({required double widthFactor}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _buildInlineErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.textSecondary,
              size: 42,
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load prescription history',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: PrimaryButtonWidget(
                  text: 'Retry',
                  onPressed: widget.onRetry,
                  icon: Icons.refresh,
                  iconPosition: IconPosition.leading,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
