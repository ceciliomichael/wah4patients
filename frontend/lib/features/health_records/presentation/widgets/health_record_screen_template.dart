import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../models/health_record_models.dart';
import 'health_record_list_item.dart';
import 'health_record_search_filter_bar.dart';

class HealthRecordScreenTemplate extends StatefulWidget {
  const HealthRecordScreenTemplate({super.key, required this.content});

  final HealthRecordScreenContent content;

  @override
  State<HealthRecordScreenTemplate> createState() =>
      _HealthRecordScreenTemplateState();
}

class _HealthRecordScreenTemplateState
    extends State<HealthRecordScreenTemplate> {
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

  List<HealthRecordEntry> get _filteredEntries {
    final query = _searchController.text.trim().toLowerCase();

    return widget.content.entries.where((entry) {
      final matchesFilter =
          _selectedFilter == widget.content.filterOptions.first ||
          entry.filterValue == _selectedFilter;
      final haystack = [
        entry.title,
        entry.subtitle,
        entry.summaryLabel,
        entry.summaryValue,
        entry.statusLabel,
        ...entry.details.map((detail) => '${detail.label} ${detail.value}'),
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
            Icons.touch_app_outlined,
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
              AppScreenHeader(
                title: widget.content.title,
                isTablet: isTablet,
                topPadding: 24.0,
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
                    _selectedFilter =
                        value ?? widget.content.filterOptions.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final isExpanded = _expandedEntryIds.contains(
                            entry.id,
                          );
                          return HealthRecordListItem(
                            entry: entry,
                            isExpanded: isExpanded,
                            onTap: () => _toggleExpanded(entry.id),
                          );
                        },
                      ),
              ),
            ],
          ),
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
}
