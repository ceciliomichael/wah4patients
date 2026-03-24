import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../models/medication_resupply_models.dart';
import '../widgets/resupply_screen_header.dart';

class MedicationResupplyRequestScreen extends StatefulWidget {
  const MedicationResupplyRequestScreen({super.key});

  @override
  State<MedicationResupplyRequestScreen> createState() =>
      _MedicationResupplyRequestScreenState();
}

class _MedicationResupplyRequestScreenState
    extends State<MedicationResupplyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController(text: '1');
  final _dispenseQuantityController = TextEditingController(text: '30');
  final _notesController = TextEditingController();

  String _selectedMedicineId = mockResupplyPrescriptionOptions.first.id;

  @override
  void dispose() {
    _quantityController.dispose();
    _dispenseQuantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  ResupplyPrescriptionOption get _selectedMedicine =>
      mockResupplyPrescriptionOptions.firstWhere(
        (medicine) => medicine.id == _selectedMedicineId,
      );

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: 'Request Resupply Help',
          messages: const <String>[
            'Choose the medicine you want to refill from the list.',
            'Enter the quantity per dose and the total dispense amount.',
            'Use notes for any details that should accompany the request.',
          ],
          icons: const <IconData>[
            Icons.medication_outlined,
            Icons.numbers_outlined,
            Icons.note_alt_outlined,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedMedicine = _selectedMedicine;
    final quantityPerDose = int.parse(_quantityController.text);
    final dispenseQuantity = int.parse(_dispenseQuantityController.text);
    final notes = _notesController.text.trim();

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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Request ready',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  selectedMedicine.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Dosage', selectedMedicine.dosage),
                const SizedBox(height: 8),
                _buildSummaryRow('Frequency', selectedMedicine.frequency),
                const SizedBox(height: 8),
                _buildSummaryRow('Quantity per dose', '$quantityPerDose'),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Total dispense quantity',
                  '$dispenseQuantity',
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow('Notes', notes),
                ],
                const SizedBox(height: 20),
                PrimaryButtonWidget(
                  text: 'Done',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: Icons.check,
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: isTablet ? 32.0 : 16.0,
            right: isTablet ? 32.0 : 16.0,
            top: 8.0,
            bottom: 24.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResupplyScreenHeader(
                  title: 'Request Resupply',
                  onBackPressed: () => Navigator.of(context).pop(),
                  onHelpPressed: _showHelpDialog,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.extraLarge,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medication_outlined,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Medication Resupply',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pick a medicine, fill in the request, and keep the layout compact.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose medicine',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...mockResupplyPrescriptionOptions.map(
                  (medicine) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: medicine.id == _selectedMedicineId
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : AppColors.surface,
                      borderRadius: AppRadii.large,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedMedicineId = medicine.id;
                          });
                        },
                        borderRadius: AppRadii.large,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.large,
                            border: Border.all(
                              color: medicine.id == _selectedMedicineId
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: AppRadii.medium,
                                ),
                                child: Icon(
                                  medicine.icon,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine.name,
                                      style: AppTextStyles.titleLarge.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${medicine.dosage} · ${medicine.frequency}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (medicine.id == _selectedMedicineId)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.large,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected details',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Dosage', _selectedMedicine.dosage),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Frequency',
                        _selectedMedicine.frequency,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Quantity per dose *',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(hintText: 'Enter quantity'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Total dispense quantity *',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dispenseQuantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Enter total quantity',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Additional notes (optional)',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  style: AppTextStyles.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Add any instructions or details',
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButtonWidget(
                  text: 'Submit Request',
                  onPressed: _submitRequest,
                  icon: Icons.send_outlined,
                ),
                const SizedBox(height: 12),
                SecondaryButtonWidget(
                  text: 'Reset fields',
                  onPressed: () {
                    setState(() {
                      _selectedMedicineId =
                          mockResupplyPrescriptionOptions.first.id;
                      _quantityController.text = '1';
                      _dispenseQuantityController.text = '30';
                      _notesController.clear();
                    });
                  },
                  textColor: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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
