import 'package:flutter/material.dart';

import '../../../../../core/constants/app_border_radii.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../domain/medicine_status.dart';
import 'medicine_status_dropdown.dart';

class MedicineIntakeFilterBar extends StatelessWidget {
  const MedicineIntakeFilterBar({
    super.key,
    required this.searchController,
    required this.onQueryChanged,
    required this.onClearSearch,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearSearch;
  final MedicineStatus? selectedStatus;
  final ValueChanged<MedicineStatus?> onStatusChanged;

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
        onChanged: onQueryChanged,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search medicines',
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
        MedicineStatusDropdown(value: selectedStatus, onChanged: onStatusChanged),
      ],
    );
  }
}
