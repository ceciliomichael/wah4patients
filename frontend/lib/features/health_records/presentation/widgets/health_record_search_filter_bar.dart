import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'health_record_filter_dropdown.dart';

class HealthRecordSearchFilterBar extends StatelessWidget {
  const HealthRecordSearchFilterBar({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
  });

  final TextEditingController searchController;
  final String searchHint;
  final String selectedFilter;
  final List<String> filterOptions;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final hasText = searchController.text.isNotEmpty;

    final searchBar = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: searchHint,
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: hasText
              ? IconButton(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );

    return Row(
      children: [
        Expanded(child: searchBar),
        const SizedBox(width: 12),
        HealthRecordFilterDropdown(
          value: selectedFilter,
          options: filterOptions,
          onChanged: (value) => onFilterChanged(value),
        ),
      ],
    );
  }
}
