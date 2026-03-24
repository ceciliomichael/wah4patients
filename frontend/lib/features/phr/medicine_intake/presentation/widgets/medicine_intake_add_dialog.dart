import 'package:flutter/material.dart';

import '../../../../../core/constants/app_border_radii.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../domain/medicine_status.dart';
import '../models/medicine_intake_models.dart';

class MedicineIntakeAddDialog extends StatefulWidget {
  const MedicineIntakeAddDialog({super.key});

  @override
  State<MedicineIntakeAddDialog> createState() => _MedicineIntakeAddDialogState();
}

class _MedicineIntakeAddDialogState extends State<MedicineIntakeAddDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _scheduleController = TextEditingController();
  final TextEditingController _nextDoseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  MedicineStatus _status = MedicineStatus.active;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _scheduleController.dispose();
    _nextDoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final dosage = _dosageController.text.trim();
    final schedule = _scheduleController.text.trim();
    final nextDose = _nextDoseController.text.trim();
    final notes = _notesController.text.trim();

    if (name.isEmpty || dosage.isEmpty || schedule.isEmpty || nextDose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill out name, dosage, schedule, and next dose.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      MedicineIntakeDraft(
        name: name,
        dosage: dosage,
        schedule: schedule,
        nextDose: nextDose,
        notes: notes.isEmpty
            ? 'Keep this medicine on the same schedule every day.'
            : notes,
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.extraLarge),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Medicine',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildField(
              controller: _nameController,
              label: 'Medicine name',
              hintText: 'e.g. Amlodipine',
              icon: Icons.medication_outlined,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _dosageController,
              label: 'Dosage',
              hintText: 'e.g. 5 mg tablet',
              icon: Icons.scale_outlined,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _scheduleController,
              label: 'Schedule',
              hintText: 'e.g. Once daily after breakfast',
              icon: Icons.schedule_outlined,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _nextDoseController,
              label: 'Next dose',
              hintText: 'e.g. Today, 8:00 PM',
              icon: Icons.alarm_outlined,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _notesController,
              label: 'Notes',
              hintText: 'Optional notes for this medicine',
              icon: Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MedicineStatus>(
              initialValue: _status,
              items: MedicineStatus.values
                  .map(
                    (status) => DropdownMenuItem<MedicineStatus>(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _status = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SecondaryButtonWidget(
                    text: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                    textColor: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButtonWidget(text: 'Save', onPressed: _save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}
