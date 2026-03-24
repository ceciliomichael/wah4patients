import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/auth_validators.dart';

class PasswordRequirementsList extends StatelessWidget {
  const PasswordRequirementsList({
    super.key,
    required this.password,
    required this.isVisible,
  });

  final String password;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final requirements = buildPasswordRequirements(password);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isVisible
          ? Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: requirements
                    .map(
                      (requirement) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: requirement.isMet
                                    ? AppColors.secondary
                                    : AppColors.border,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                requirement.isMet ? Icons.check : Icons.circle,
                                size: 12,
                                color: requirement.isMet
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                requirement.description,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: requirement.isMet
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: requirement.isMet
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
