import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/inputs/bottom_sheet_select_form_field.dart';
import '../../../auth/domain/models/auth_api_models.dart';

class PatientProfileFormWidget extends StatefulWidget {
  const PatientProfileFormWidget({
    super.key,
    required this.initialProfile,
    required this.isSubmitting,
    required this.onSave,
    required this.onReset,
  });

  final UserProfileSummary initialProfile;
  final bool isSubmitting;
  final Future<void> Function(PatientProfileDraft draft) onSave;
  final VoidCallback onReset;

  @override
  State<PatientProfileFormWidget> createState() =>
      _PatientProfileFormWidgetState();
}

class _PatientProfileFormWidgetState extends State<PatientProfileFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _secondNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _communicationLanguageController;
  late final TextEditingController _philHealthIdController;
  late final TextEditingController _philSysIdController;
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _addressLine2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _provinceController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _maritalStatusController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _religionController;
  late final TextEditingController _occupationController;
  late final TextEditingController _genderIdentityController;
  late final TextEditingController _emergencyContactNameController;
  late final TextEditingController _emergencyContactPhoneController;

  String _gender = 'unknown';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _secondNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _birthDateController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _communicationLanguageController = TextEditingController();
    _philHealthIdController = TextEditingController();
    _philSysIdController = TextEditingController();
    _addressLine1Controller = TextEditingController();
    _addressLine2Controller = TextEditingController();
    _cityController = TextEditingController();
    _provinceController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
    _maritalStatusController = TextEditingController();
    _nationalityController = TextEditingController();
    _religionController = TextEditingController();
    _occupationController = TextEditingController();
    _genderIdentityController = TextEditingController();
    _emergencyContactNameController = TextEditingController();
    _emergencyContactPhoneController = TextEditingController();
    _hydrateFromProfile(widget.initialProfile);
  }

  @override
  void didUpdateWidget(covariant PatientProfileFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProfile != widget.initialProfile) {
      setState(() {
        _hydrateFromProfile(widget.initialProfile);
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _phoneNumberController.dispose();
    _communicationLanguageController.dispose();
    _philHealthIdController.dispose();
    _philSysIdController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _maritalStatusController.dispose();
    _nationalityController.dispose();
    _religionController.dispose();
    _occupationController.dispose();
    _genderIdentityController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(UserProfileSummary profile) {
    _firstNameController.text = profile.givenNames.isNotEmpty
        ? profile.givenNames.first
        : '';
    _secondNameController.text = profile.givenNames.length > 1
        ? profile.givenNames[1]
        : '';
    _middleNameController.text = profile.givenNames.length > 2
        ? profile.givenNames[2]
        : '';
    _lastNameController.text = profile.familyName;
    _birthDateController.text = profile.birthDate;
    _gender = profile.gender.isNotEmpty ? profile.gender : 'unknown';
    _phoneNumberController.text = profile.phoneNumber;
    _communicationLanguageController.text = profile.communicationLanguage;
    _philHealthIdController.text = profile.philHealthId;
    _philSysIdController.text = profile.philSysId;
    _addressLine1Controller.text = profile.addressLine1;
    _addressLine2Controller.text = profile.addressLine2;
    _cityController.text = profile.city;
    _provinceController.text = profile.province;
    _postalCodeController.text = profile.postalCode;
    _countryController.text = profile.country;
    _maritalStatusController.text = profile.maritalStatus;
    _nationalityController.text = profile.nationality;
    _religionController.text = profile.religion;
    _occupationController.text = profile.occupation;
    _genderIdentityController.text = profile.genderIdentity;
    _emergencyContactNameController.text = profile.emergencyContactName;
    _emergencyContactPhoneController.text = profile.emergencyContactPhone;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    await widget.onSave(
      PatientProfileDraft(
        firstName: _firstNameController.text.trim(),
        secondName: _secondNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        gender: _gender,
        phoneNumber: _phoneNumberController.text.trim(),
        communicationLanguage: _communicationLanguageController.text.trim(),
        philHealthId: _philHealthIdController.text.trim(),
        philSysId: _philSysIdController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        maritalStatus: _maritalStatusController.text.trim(),
        nationality: _nationalityController.text.trim(),
        religion: _religionController.text.trim(),
        occupation: _occupationController.text.trim(),
        genderIdentity: _genderIdentityController.text.trim(),
        emergencyContactName: _emergencyContactNameController.text.trim(),
        emergencyContactPhone: _emergencyContactPhoneController.text.trim(),
      ),
    );
  }

  void _handleReset() {
    _hydrateFromProfile(widget.initialProfile);
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            title: 'Identity',
            description: 'Name, birth date, gender, and language details.',
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _firstNameController,
              label: 'First name',
              hintText: 'Enter first name',
              icon: Icons.person_outline,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
            second: _ProfileTextField(
              controller: _secondNameController,
              label: 'Second name',
              hintText: 'Enter second name',
              icon: Icons.badge_outlined,
              validator: _optionalNameValidator,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _middleNameController,
              label: 'Middle name',
              hintText: 'Enter middle name',
              icon: Icons.account_circle_outlined,
              validator: _optionalNameValidator,
              textInputAction: TextInputAction.next,
            ),
            second: _ProfileTextField(
              controller: _lastNameController,
              label: 'Last name',
              hintText: 'Enter last name',
              icon: Icons.badge,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _birthDateController,
              label: 'Birth date',
              hintText: 'YYYY-MM-DD',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.datetime,
              validator: _birthDateValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
            second: BottomSheetSelectFormField<String>(
              value: _gender,
              options: const [
                BottomSheetSelectOption(
                  value: 'male',
                  label: 'Male',
                  icon: Icons.male_outlined,
                ),
                BottomSheetSelectOption(
                  value: 'female',
                  label: 'Female',
                  icon: Icons.female_outlined,
                ),
                BottomSheetSelectOption(
                  value: 'other',
                  label: 'Other',
                  icon: Icons.transgender_outlined,
                ),
                BottomSheetSelectOption(
                  value: 'unknown',
                  label: 'Prefer not to say',
                  icon: Icons.help_outline,
                ),
              ],
              onChanged: widget.isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _gender = value ?? 'unknown';
                      });
                    },
              label: 'Gender',
              hintText: 'Select gender',
              icon: Icons.wc_outlined,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Select gender' : null,
              showRequiredIndicator: true,
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _phoneNumberController,
              label: 'Phone number',
              hintText: 'Enter phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
            second: _ProfileTextField(
              controller: _communicationLanguageController,
              label: 'Communication language',
              hintText: 'e.g. English or Filipino',
              icon: Icons.language_outlined,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Identifiers',
            description: 'Store the patient identifiers hospitals can use to match records.',
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _philHealthIdController,
              label: 'PhilHealth ID',
              hintText: 'Enter PhilHealth ID',
              icon: Icons.credit_card_outlined,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
            second: _ProfileTextField(
              controller: _philSysIdController,
              label: 'PhilSys ID',
              hintText: 'Enter PhilSys ID',
              icon: Icons.perm_identity_outlined,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Address',
            description: 'Add the current mailing address used for patient matching.',
          ),
          const SizedBox(height: 16),
          _ProfileTextField(
            controller: _addressLine1Controller,
            label: 'Address line 1',
            hintText: 'Street, building, or lot number',
            icon: Icons.home_outlined,
            validator: _requiredValidator,
            textInputAction: TextInputAction.next,
            showRequiredIndicator: true,
          ),
          const SizedBox(height: 16),
          _ProfileTextField(
            controller: _addressLine2Controller,
            label: 'Address line 2',
            hintText: 'Apartment, unit, or landmark',
            icon: Icons.location_on_outlined,
            validator: _optionalValidator,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _cityController,
              label: 'City / municipality',
              hintText: 'Enter city',
              icon: Icons.location_city_outlined,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
            second: _ProfileTextField(
              controller: _provinceController,
              label: 'Province',
              hintText: 'Enter province',
              icon: Icons.map_outlined,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _postalCodeController,
              label: 'Postal code',
              hintText: 'Enter postal code',
              icon: Icons.local_post_office_outlined,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
            second: _ProfileTextField(
              controller: _countryController,
              label: 'Country',
              hintText: 'Enter country',
              icon: Icons.public_outlined,
              validator: _requiredValidator,
              textInputAction: TextInputAction.next,
              showRequiredIndicator: true,
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            title: 'Optional details',
            description: 'These help later sync and profile matching, but they can be updated anytime.',
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _maritalStatusController,
              label: 'Marital status',
              hintText: 'Enter marital status',
              icon: Icons.favorite_border,
              validator: _optionalValidator,
              textInputAction: TextInputAction.next,
            ),
            second: _ProfileTextField(
              controller: _nationalityController,
              label: 'Nationality',
              hintText: 'Enter nationality',
              icon: Icons.flag_outlined,
              validator: _optionalValidator,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _religionController,
              label: 'Religion',
              hintText: 'Enter religion',
              icon: Icons.church_outlined,
              validator: _optionalValidator,
              textInputAction: TextInputAction.next,
            ),
            second: _ProfileTextField(
              controller: _occupationController,
              label: 'Occupation',
              hintText: 'Enter occupation',
              icon: Icons.work_outline,
              validator: _optionalValidator,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          _buildTwoColumnRow(
            first: _ProfileTextField(
              controller: _genderIdentityController,
              label: 'Gender identity',
              hintText: 'Enter gender identity',
              icon: Icons.person_outline,
              validator: _optionalValidator,
              textInputAction: TextInputAction.next,
            ),
            second: _ProfileTextField(
              controller: _emergencyContactNameController,
              label: 'Emergency contact name',
              hintText: 'Enter contact name',
              icon: Icons.contact_phone_outlined,
              validator: _optionalValidator,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          _ProfileTextField(
            controller: _emergencyContactPhoneController,
            label: 'Emergency contact phone',
            hintText: 'Enter contact phone',
            icon: Icons.phone_callback_outlined,
            keyboardType: TextInputType.phone,
            validator: _optionalValidator,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          if (widget.isSubmitting)
            const LinearProgressIndicator(minHeight: 3),
          const SizedBox(height: 20),
          if (MediaQuery.sizeOf(context).width >= 720)
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    text: 'Save Changes',
                    icon: Icons.save_outlined,
                    isPrimary: true,
                    isLoading: widget.isSubmitting,
                    onPressed: widget.isSubmitting ? null : _handleSave,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    text: 'Reset',
                    icon: Icons.refresh_outlined,
                    isPrimary: false,
                    isLoading: false,
                    onPressed: widget.isSubmitting ? null : _handleReset,
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActionButton(
                  text: 'Save Changes',
                  icon: Icons.save_outlined,
                  isPrimary: true,
                  isLoading: widget.isSubmitting,
                  onPressed: widget.isSubmitting ? null : _handleSave,
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  text: 'Reset',
                  icon: Icons.refresh_outlined,
                  isPrimary: false,
                  isLoading: false,
                  onPressed: widget.isSubmitting ? null : _handleReset,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnRow({
    required Widget first,
    required Widget second,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        if (!isWide) {
          return Column(
            children: [
              first,
              const SizedBox(height: 16),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 16),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.validator,
    required this.textInputAction,
    this.showRequiredIndicator = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final bool showRequiredIndicator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        label: showRequiredIndicator ? _RequiredLabel(label: label) : Text(label),
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.labelLarge.copyWith(
      color: AppColors.textPrimary,
    );
    final indicatorStyle = AppTextStyles.labelSmall.copyWith(
      color: AppColors.danger,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: labelStyle,
        children: [
          TextSpan(text: label),
          const TextSpan(text: ' '),
          TextSpan(text: '*', style: indicatorStyle),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.isLoading,
    required this.onPressed,
  });

  final String text;
  final IconData icon;
  final bool isPrimary;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isPrimary ? AppColors.primary : AppColors.surface,
      foregroundColor: isPrimary ? AppColors.textOnPrimary : AppColors.textPrimary,
      elevation: 0,
      side: isPrimary
          ? BorderSide.none
          : const BorderSide(color: AppColors.border),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.medium,
      ),
    );

    final buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(icon, size: 18),
        const SizedBox(width: 10),
        Text(text),
      ],
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: buttonChild,
    );
  }
}

String? _requiredValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'This field is required';
  }
  return null;
}

String? _optionalValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.length > 120) {
    return 'Value is too long';
  }
  return null;
}

String? _optionalNameValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.length > 100) {
    return 'Name is too long';
  }
  return null;
}

String? _birthDateValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'This field is required';
  }

  final match = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text);
  if (!match) {
    return 'Use YYYY-MM-DD';
  }

  final parsed = DateTime.tryParse('${text}T00:00:00Z');
  if (parsed == null) {
    return 'Enter a valid date';
  }

  return null;
}
