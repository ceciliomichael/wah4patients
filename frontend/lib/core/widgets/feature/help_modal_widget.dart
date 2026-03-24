import 'package:flutter/material.dart';

import '../../constants/app_border_radii.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../ui/buttons/secondary_button_widget.dart';

class HelpModalWidget extends StatelessWidget {
  const HelpModalWidget({
    super.key,
    required this.title,
    required this.messages,
    required this.icons,
    required this.onClose,
  });

  final String title;
  final List<String> messages;
  final List<IconData> icons;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.extraLarge),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List<Widget>.generate(messages.length, (index) {
              final icon = index < icons.length
                  ? icons[index]
                  : Icons.info_outline;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: AppColors.secondary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        messages[index],
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: SecondaryButtonWidget(
                text: 'Close',
                onPressed: onClose,
                textColor: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
