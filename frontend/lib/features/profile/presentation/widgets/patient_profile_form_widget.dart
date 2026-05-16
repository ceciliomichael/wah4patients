import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/inputs/bottom_sheet_select_form_field.dart';
import '../../../auth/domain/models/auth_api_models.dart';
import '../../domain/marital_status_formatter.dart';

class PatientProfileFormWidget extends StatefulWidget {
  const PatientProfileFormWidget({
    super.key,
    required this.initialProfile,
    required this.isSubmitting,
    this.isReadOnly = false,
    this.identifiersSectionKey,
    required this.onSave,
    required this.onReset,
  });

  final UserProfileSummary initialProfile;
  final bool isSubmitting;
  final bool isReadOnly;
  final GlobalKey? identifiersSectionKey;
  final Future<void> Function(PatientProfileDraft draft) onSave;
  final VoidCallback onReset;

  @override
  State<PatientProfileFormWidget> createState() =>
      _PatientProfileFormWidgetState();
}

class _PatientProfileFormWidgetState extends State<PatientProfileFormWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
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
  late final TextEditingController _regionController;
  late final TextEditingController _barangayController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _maritalStatusController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _religionController;
  late final TextEditingController _occupationController;
  late final TextEditingController _genderIdentityController;
  bool _indigenousPeople = false;
  late final TextEditingController _indigenousGroupController;
  late final TextEditingController _raceController;
  late final TextEditingController _educationalAttainmentController;
  late final TextEditingController _sexAtBirthController;
  late final TextEditingController _pwdIdNumberController;
  late final TextEditingController _pwdDisabilityTypeController;
  late final TextEditingController _pwdIdExpirationDateController;
  late final TextEditingController _pwdIssuingLguController;
  late final TextEditingController _emergencyContactNameController;
  late final TextEditingController _emergencyContactPhoneController;

  String _gender = 'unknown';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
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
    _regionController = TextEditingController();
    _barangayController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
    _maritalStatusController = TextEditingController();
    _nationalityController = TextEditingController();
    _religionController = TextEditingController();
    _occupationController = TextEditingController();
    _genderIdentityController = TextEditingController();
    _indigenousGroupController = TextEditingController();
    _raceController = TextEditingController();
    _educationalAttainmentController = TextEditingController();
    _sexAtBirthController = TextEditingController();
    _pwdIdNumberController = TextEditingController();
    _pwdDisabilityTypeController = TextEditingController();
    _pwdIdExpirationDateController = TextEditingController();
    _pwdIssuingLguController = TextEditingController();
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
    _regionController.dispose();
    _barangayController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _maritalStatusController.dispose();
    _nationalityController.dispose();
    _religionController.dispose();
    _occupationController.dispose();
    _genderIdentityController.dispose();
    _indigenousGroupController.dispose();
    _raceController.dispose();
    _educationalAttainmentController.dispose();
    _sexAtBirthController.dispose();
    _pwdIdNumberController.dispose();
    _pwdDisabilityTypeController.dispose();
    _pwdIdExpirationDateController.dispose();
    _pwdIssuingLguController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(UserProfileSummary profile) {
    _firstNameController.text = profile.givenNames.isNotEmpty
        ? profile.givenNames.first
        : '';
    _middleNameController.text = profile.givenNames.length > 1
        ? profile.givenNames[1]
        : '';
    _lastNameController.text = profile.familyName;
    _birthDateController.text = _formatBirthDateForDisplay(profile.birthDate);
    _gender = profile.gender.isNotEmpty ? profile.gender : 'unknown';
    _phoneNumberController.text = profile.phoneNumber;
    _communicationLanguageController.text = profile.communicationLanguage;
    _philHealthIdController.text = profile.philHealthId;
    _philSysIdController.text = profile.philSysId;
    _addressLine1Controller.text = profile.addressLine1;
    _addressLine2Controller.text = profile.addressLine2;
    _cityController.text = profile.city;
    _provinceController.text = profile.province;
    _regionController.text = profile.region;
    _barangayController.text = profile.barangay;
    _postalCodeController.text = profile.postalCode;
    _countryController.text = profile.country;
    _maritalStatusController.text = displayMaritalStatusLabel(
      profile.maritalStatus,
    );
    _nationalityController.text = profile.nationality;
    _religionController.text = profile.religion;
    _occupationController.text = profile.occupation;
    _genderIdentityController.text = profile.genderIdentity;
    _indigenousPeople = profile.indigenousPeople;
    _indigenousGroupController.text = profile.indigenousPeople
        ? profile.indigenousGroup
        : '';
    _raceController.text = profile.race;
    _educationalAttainmentController.text = profile.educationalAttainment;
    _sexAtBirthController.text = profile.sexAtBirth;
    _pwdIdNumberController.text = profile.pwdIdNumber;
    _pwdDisabilityTypeController.text = profile.pwdDisabilityType;
    _pwdIdExpirationDateController.text = profile.pwdIdExpirationDate;
    _pwdIssuingLguController.text = profile.pwdIssuingLgu;
    _emergencyContactNameController.text = profile.emergencyContactName;
    _emergencyContactPhoneController.text = profile.emergencyContactPhone;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (!_hasAtLeastOneIdentifier()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide PhilHealth ID or PhilSys ID to save.'),
        ),
      );
      return;
    }

    await widget.onSave(
      PatientProfileDraft(
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        birthDate: _formatBirthDateForApi(_birthDateController.text.trim()),
        gender: _gender,
        phoneNumber: _phoneNumberController.text.trim(),
        communicationLanguage: _communicationLanguageController.text.trim(),
        philHealthId: _philHealthIdController.text.trim(),
        philSysId: _philSysIdController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        region: _regionController.text.trim(),
        barangay: _barangayController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        country: _countryController.text.trim(),
        maritalStatus: normalizeMaritalStatusValue(
          _maritalStatusController.text.trim(),
        ),
        nationality: _nationalityController.text.trim(),
        religion: _religionController.text.trim(),
        occupation: _occupationController.text.trim(),
        genderIdentity: _genderIdentityController.text.trim(),
        indigenousPeople: _indigenousPeople,
        indigenousGroup: _indigenousPeople
            ? _indigenousGroupController.text.trim()
            : '',
        race: _raceController.text.trim(),
        educationalAttainment: _educationalAttainmentController.text.trim(),
        sexAtBirth: _sexAtBirthController.text.trim(),
        pwdIdNumber: _pwdIdNumberController.text.trim(),
        pwdDisabilityType: _pwdDisabilityTypeController.text.trim(),
        pwdIdExpirationDate: _pwdIdExpirationDateController.text.trim(),
        pwdIssuingLgu: _pwdIssuingLguController.text.trim(),
        emergencyContactName: _emergencyContactNameController.text.trim(),
        emergencyContactPhone: _emergencyContactPhoneController.text.trim(),
      ),
    );
  }

  bool _hasAtLeastOneIdentifier() {
    return _philHealthIdController.text.trim().isNotEmpty ||
        _philSysIdController.text.trim().isNotEmpty;
  }

  void _handleReset() {
    _hydrateFromProfile(widget.initialProfile);
    widget.onReset();
  }

  Future<void> _pickBirthDate() async {
    if (widget.isReadOnly) {
      return;
    }

    final currentValue = _parseBirthDate(_birthDateController.text.trim());
    final now = DateTime.now();
    final initialDate =
        currentValue ?? DateTime(now.year - 18, now.month, now.day);
    final firstDate = DateTime(now.year - 120, 1, 1);
    final lastDate = DateTime(now.year, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : initialDate.isAfter(lastDate)
          ? lastDate
          : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _birthDateController.text = _formatBirthDate(selectedDate);
    });
  }

  Widget _buildDemographicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Demographics',
          description:
              'Use the yes/no field below, and add the group only when applicable.',
        ),
        const SizedBox(height: 16),
        BottomSheetSelectFormField<bool>(
          value: _indigenousPeople,
          options: const [
            BottomSheetSelectOption<bool>(
              value: false,
              label: 'No',
              icon: Icons.close_rounded,
            ),
            BottomSheetSelectOption<bool>(
              value: true,
              label: 'Yes',
              icon: Icons.check_rounded,
            ),
          ],
          onChanged: widget.isSubmitting
              ? null
              : (value) {
                  final nextValue = value ?? false;
                  setState(() {
                    _indigenousPeople = nextValue;
                    if (!nextValue) {
                      _indigenousGroupController.clear();
                    }
                  });
                },
          label: 'Indigenous people member *',
          hintText: 'Select yes or no',
          icon: Icons.groups_outlined,
          helperText:
              'Select Yes if the patient belongs to an Indigenous community.',
        ),
        if (_indigenousPeople) ...[
          const SizedBox(height: 16),
          _ProfileTextField(
            controller: _indigenousGroupController,
            label: 'Indigenous group',
            hintText: 'Enter indigenous group',
            icon: Icons.groups_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Background',
          description:
              'Helpful background details that improve matching and continuity.',
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _maritalStatusController,
            label: 'Marital status (Optional)',
            hintText: 'Enter marital status',
            icon: Icons.favorite_border,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _nationalityController,
            label: 'Nationality',
            hintText: 'Enter nationality',
            icon: Icons.flag_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _religionController,
            label: 'Religion',
            hintText: 'Enter religion',
            icon: Icons.church_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _occupationController,
            label: 'Occupation',
            hintText: 'Enter occupation',
            icon: Icons.work_outline,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(
          title: 'Identity and support',
          description:
              'Identity and accessibility details that can help the care team understand the patient better.',
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _genderIdentityController,
            label: 'Gender identity',
            hintText: 'Enter gender identity',
            icon: Icons.person_outline,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _raceController,
            label: 'Race',
            hintText: 'Enter race',
            icon: Icons.diversity_3_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _educationalAttainmentController,
            label: 'Educational attainment',
            hintText: 'Enter educational attainment',
            icon: Icons.school_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _sexAtBirthController,
            label: 'Sex assigned at birth',
            hintText: 'Enter sex assigned at birth',
            icon: Icons.badge_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(
          title: 'Support contacts',
          description:
              'Optional contact and disability details for more informed follow-up.',
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _pwdIdNumberController,
            label: 'PWD ID number',
            hintText: 'Enter PWD ID number',
            icon: Icons.credit_card_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
          ),
          second: _ProfileTextField(
            controller: _pwdDisabilityTypeController,
            label: 'PWD disability type',
            hintText: 'Enter disability type',
            icon: Icons.accessibility_new_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _pwdIdExpirationDateController,
            label: 'PWD ID expiration date',
            hintText: 'YYYY-MM-DD',
            icon: Icons.event_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
          ),
          second: _ProfileTextField(
            controller: _pwdIssuingLguController,
            label: 'PWD issuing LGU',
            hintText: 'Enter issuing LGU',
            icon: Icons.location_city_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: 16),
        _ProfileTextField(
          controller: _emergencyContactNameController,
          label: 'Emergency contact name',
          hintText: 'Enter contact name',
          icon: Icons.contact_phone_outlined,
          validator: null,
          textInputAction: TextInputAction.next,
          inputFormatters: _nameInputFormatters(),
        ),
        const SizedBox(height: 16),
        _ProfileTextField(
          controller: _emergencyContactPhoneController,
          label: 'Emergency contact phone (Optional)',
          hintText: 'Enter contact phone',
          icon: Icons.phone_callback_outlined,
          keyboardType: TextInputType.phone,
          validator: null,
          textInputAction: TextInputAction.done,
          inputFormatters: _phoneInputFormatters(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: widget.isReadOnly
          ? _buildLockedProfileView()
          : _buildEditableProfileView(context),
    );
  }

  Widget _buildEditableProfileView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Identity',
          description:
              'Fields marked with * are recommended for profile completeness.',
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _firstNameController,
            label: 'First name *',
            hintText: 'Enter first/given name',
            icon: Icons.person_outline,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _middleNameController,
            label: 'Middle name (Optional)',
            hintText: 'Enter middle name',
            icon: Icons.account_circle_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 16),
        _ProfileTextField(
          controller: _lastNameController,
          label: 'Last name *',
          hintText: 'Enter last name',
          icon: Icons.badge,
          validator: null,
          textInputAction: TextInputAction.next,
          inputFormatters: _nameInputFormatters(),
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _birthDateController,
            label: 'Birth date *',
            hintText: 'MM/DD/YYYY',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.datetime,
            validator: null,
            textInputAction: TextInputAction.next,
            readOnly: true,
            onTap: _pickBirthDate,
            suffixIcon: IconButton(
              onPressed: widget.isSubmitting ? null : _pickBirthDate,
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.textSecondary,
              ),
            ),
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
            label: 'Gender *',
            hintText: 'Select gender',
            icon: Icons.wc_outlined,
            validator: null,
          ),
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _phoneNumberController,
            label: 'Phone number *',
            hintText: 'Enter phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _phoneInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _communicationLanguageController,
            label: 'Communication language *',
            hintText: 'e.g. English or Filipino',
            icon: Icons.language_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          key: widget.identifiersSectionKey,
          title: 'Identifiers',
          description:
              'Required to save: add at least one identifier (PhilHealth ID or PhilSys ID).',
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _philHealthIdController,
            label: 'PhilHealth ID',
            hintText: 'Enter PhilHealth ID',
            icon: Icons.credit_card_outlined,
            validator: _optionalPhilHealthIdValidator,
            textInputAction: TextInputAction.next,
            inputFormatters: _identifierInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _philSysIdController,
            label: 'PhilSys ID',
            hintText: 'Enter PhilSys ID',
            icon: Icons.perm_identity_outlined,
            validator: _optionalPhilSysIdValidator,
            textInputAction: TextInputAction.next,
            inputFormatters: _identifierInputFormatters(),
          ),
        ),
        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Address',
          description:
              'Add the current mailing address used for patient matching.',
        ),
        const SizedBox(height: 16),
        _ProfileTextField(
          controller: _addressLine1Controller,
          label: 'Address line 1 *',
          hintText: 'Street, building, or lot number',
          icon: Icons.home_outlined,
          validator: null,
          textInputAction: TextInputAction.next,
          inputFormatters: _addressInputFormatters(),
        ),
        const SizedBox(height: 16),
        _ProfileTextField(
          controller: _addressLine2Controller,
          label: 'Address line 2 (Optional)',
          hintText: 'Apartment, unit, or landmark',
          icon: Icons.location_on_outlined,
          validator: null,
          textInputAction: TextInputAction.next,
          inputFormatters: _addressInputFormatters(),
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _cityController,
            label: 'City / municipality *',
            hintText: 'Enter city',
            icon: Icons.location_city_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _provinceController,
            label: 'Province *',
            hintText: 'Enter province',
            icon: Icons.map_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _postalCodeController,
            label: 'Postal code *',
            hintText: 'Enter postal code',
            icon: Icons.local_post_office_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          second: _ProfileTextField(
            controller: _countryController,
            label: 'Country *',
            hintText: 'Enter country',
            icon: Icons.public_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 16),
        _buildTwoColumnRow(
          first: _ProfileTextField(
            controller: _regionController,
            label: 'Region (Optional)',
            hintText: 'Enter region',
            icon: Icons.public_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
          second: _ProfileTextField(
            controller: _barangayController,
            label: 'Barangay (Optional)',
            hintText: 'Enter barangay',
            icon: Icons.place_outlined,
            validator: null,
            textInputAction: TextInputAction.next,
            inputFormatters: _nameInputFormatters(),
          ),
        ),
        const SizedBox(height: 24),
        _buildDemographicsSection(),
        const SizedBox(height: 20),
        _buildOptionalDetailsSection(),
        const SizedBox(height: 24),
        if (widget.isSubmitting) const LinearProgressIndicator(minHeight: 3),
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
    );
  }

  Widget _buildLockedProfileView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_buildLockedIdentitySection() != null)
          _buildLockedIdentitySection()!,
        if (_buildLockedIdentifiersSection() != null) ...[
          const SizedBox(height: 20),
          _buildLockedIdentifiersSection()!,
        ],
        if (_buildLockedAddressSection() != null) ...[
          const SizedBox(height: 20),
          _buildLockedAddressSection()!,
        ],
        if (_buildLockedDemographicsSection() != null) ...[
          const SizedBox(height: 20),
          _buildLockedDemographicsSection()!,
        ],
        if (_buildLockedBackgroundSection() != null) ...[
          const SizedBox(height: 20),
          _buildLockedBackgroundSection()!,
        ],
        if (_buildLockedIdentityAndSupportSection() != null) ...[
          const SizedBox(height: 20),
          _buildLockedIdentityAndSupportSection()!,
        ],
        if (_buildLockedSupportContactsSection() != null) ...[
          const SizedBox(height: 20),
          _buildLockedSupportContactsSection()!,
        ],
      ],
    );
  }

  Widget? _buildLockedIdentitySection() {
    return _buildLockedSection(
      title: 'Identity',
      description:
          'Fields marked with * are recommended for profile completeness.',
      rows: [
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _firstNameController.text,
            label: 'First name *',
            hintText: 'Enter first/given name',
            icon: Icons.person_outline,
          ),
          second: _readOnlyProfileField(
            value: _middleNameController.text,
            label: 'Middle name (Optional)',
            hintText: 'Enter middle name',
            icon: Icons.account_circle_outlined,
          ),
        ),
        _readOnlyProfileField(
          value: _lastNameController.text,
          label: 'Last name *',
          hintText: 'Enter last name',
          icon: Icons.badge,
        ),
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _birthDateController.text,
            label: 'Birth date *',
            hintText: 'MM/DD/YYYY',
            icon: Icons.cake_outlined,
          ),
          second: _readOnlyProfileField(
            value: _displayGenderValue(_gender),
            label: 'Gender *',
            hintText: 'Select gender',
            icon: Icons.wc_outlined,
          ),
        ),
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _phoneNumberController.text,
            label: 'Phone number *',
            hintText: 'Enter phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          second: _readOnlyProfileField(
            value: _communicationLanguageController.text,
            label: 'Communication language *',
            hintText: 'e.g. English or Filipino',
            icon: Icons.language_outlined,
          ),
        ),
      ],
    );
  }

  Widget? _buildLockedIdentifiersSection() {
    return _buildLockedSection(
      title: 'Identifiers',
      description:
          'Required to save: add at least one identifier (PhilHealth ID or PhilSys ID).',
      rows: [
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _philHealthIdController.text,
            label: 'PhilHealth ID',
            hintText: 'Enter PhilHealth ID',
            icon: Icons.credit_card_outlined,
          ),
          second: _readOnlyProfileField(
            value: _philSysIdController.text,
            label: 'PhilSys ID',
            hintText: 'Enter PhilSys ID',
            icon: Icons.perm_identity_outlined,
          ),
        ),
      ],
    );
  }

  Widget? _buildLockedAddressSection() {
    return _buildLockedSection(
      title: 'Address',
      description: 'Add the current mailing address used for patient matching.',
      rows: [
        _readOnlyProfileField(
          value: _addressLine1Controller.text,
          label: 'Address line 1 *',
          hintText: 'Street, building, or lot number',
          icon: Icons.home_outlined,
        ),
        _readOnlyProfileField(
          value: _addressLine2Controller.text,
          label: 'Address line 2 (Optional)',
          hintText: 'Apartment, unit, or landmark',
          icon: Icons.location_on_outlined,
        ),
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _cityController.text,
            label: 'City / municipality *',
            hintText: 'Enter city',
            icon: Icons.location_city_outlined,
          ),
          second: _readOnlyProfileField(
            value: _provinceController.text,
            label: 'Province *',
            hintText: 'Enter province',
            icon: Icons.map_outlined,
          ),
        ),
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _postalCodeController.text,
            label: 'Postal code *',
            hintText: 'Enter postal code',
            icon: Icons.local_post_office_outlined,
          ),
          second: _readOnlyProfileField(
            value: _countryController.text,
            label: 'Country *',
            hintText: 'Enter country',
            icon: Icons.public_outlined,
          ),
        ),
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _regionController.text,
            label: 'Region (Optional)',
            hintText: 'Enter region',
            icon: Icons.public_outlined,
          ),
          second: _readOnlyProfileField(
            value: _barangayController.text,
            label: 'Barangay (Optional)',
            hintText: 'Enter barangay',
            icon: Icons.place_outlined,
          ),
        ),
      ],
    );
  }

  Widget? _buildLockedDemographicsSection() {
    return _buildLockedSection(
      title: 'Demographics',
      description:
          'Use the yes/no field below, and add the group only when applicable.',
      rows: [
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _displayIndigenousValue(_indigenousPeople),
            label: 'Indigenous people member *',
            hintText: 'Select yes or no',
            icon: Icons.groups_outlined,
          ),
          second: _readOnlyProfileField(
            value: _indigenousPeople ? _indigenousGroupController.text : '',
            label: 'Indigenous group',
            hintText: 'Enter indigenous group',
            icon: Icons.groups_outlined,
          ),
        ),
      ],
    );
  }

  Widget? _buildLockedBackgroundSection() {
    return _buildLockedSection(
      title: 'Background',
      description:
          'Helpful background details that improve matching and continuity.',
      rows: [
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _maritalStatusController.text,
            label: 'Marital status (Optional)',
            hintText: 'Enter marital status',
            icon: Icons.favorite_border,
          ),
          second: _readOnlyProfileField(
            value: _nationalityController.text,
            label: 'Nationality',
            hintText: 'Enter nationality',
            icon: Icons.flag_outlined,
          ),
        ),
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _religionController.text,
            label: 'Religion',
            hintText: 'Enter religion',
            icon: Icons.church_outlined,
          ),
          second: _readOnlyProfileField(
            value: _occupationController.text,
            label: 'Occupation',
            hintText: 'Enter occupation',
            icon: Icons.work_outline,
          ),
        ),
      ],
    );
  }

  Widget? _buildLockedIdentityAndSupportSection() {
    return _buildLockedSection(
      title: 'Identity and support',
      description:
          'Identity and accessibility details that can help the care team understand the patient better.',
      rows: [
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _genderIdentityController.text,
            label: 'Gender identity',
            hintText: 'Enter gender identity',
            icon: Icons.person_outline,
          ),
          second: _readOnlyProfileField(
            value: _raceController.text,
            label: 'Race',
            hintText: 'Enter race',
            icon: Icons.diversity_3_outlined,
          ),
        ),
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _educationalAttainmentController.text,
            label: 'Educational attainment',
            hintText: 'Enter educational attainment',
            icon: Icons.school_outlined,
          ),
          second: _readOnlyProfileField(
            value: _sexAtBirthController.text,
            label: 'Sex assigned at birth',
            hintText: 'Enter sex assigned at birth',
            icon: Icons.badge_outlined,
          ),
        ),
      ],
    );
  }

  Widget? _buildLockedSupportContactsSection() {
    return _buildLockedSection(
      title: 'Support contacts',
      description:
          'Optional contact and disability details for more informed follow-up.',
      rows: [
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _pwdIdNumberController.text,
            label: 'PWD ID number',
            hintText: 'Enter PWD ID number',
            icon: Icons.credit_card_outlined,
          ),
          second: _readOnlyProfileField(
            value: _pwdDisabilityTypeController.text,
            label: 'PWD disability type',
            hintText: 'Enter disability type',
            icon: Icons.accessibility_new_outlined,
          ),
        ),
        _buildOptionalTwoColumnRow(
          first: _readOnlyProfileField(
            value: _pwdIdExpirationDateController.text,
            label: 'PWD ID expiration date',
            hintText: 'YYYY-MM-DD',
            icon: Icons.event_outlined,
          ),
          second: _readOnlyProfileField(
            value: _pwdIssuingLguController.text,
            label: 'PWD issuing LGU',
            hintText: 'Enter issuing LGU',
            icon: Icons.location_city_outlined,
          ),
        ),
        _readOnlyProfileField(
          value: _emergencyContactNameController.text,
          label: 'Emergency contact name',
          hintText: 'Enter contact name',
          icon: Icons.contact_phone_outlined,
        ),
        _readOnlyProfileField(
          value: _emergencyContactPhoneController.text,
          label: 'Emergency contact phone (Optional)',
          hintText: 'Enter contact phone',
          icon: Icons.phone_callback_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget? _buildLockedSection({
    required String title,
    required String description,
    required List<Widget?> rows,
  }) {
    final visibleRows = rows.whereType<Widget>().toList(growable: false);
    if (visibleRows.isEmpty) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: title, description: description),
        const SizedBox(height: 16),
        for (var index = 0; index < visibleRows.length; index++) ...[
          if (index > 0) const SizedBox(height: 16),
          visibleRows[index],
        ],
      ],
    );
  }

  Widget? _buildOptionalTwoColumnRow({
    required Widget? first,
    required Widget? second,
  }) {
    final visibleWidgets = <Widget>[
      if (first != null) first,
      if (second != null) second,
    ];
    if (visibleWidgets.isEmpty) {
      return null;
    }

    if (visibleWidgets.length == 1) {
      return visibleWidgets.single;
    }

    return _buildTwoColumnRow(
      first: visibleWidgets[0],
      second: visibleWidgets[1],
    );
  }

  Widget? _readOnlyProfileField({
    required String value,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return _ReadOnlyProfileField(
      value: trimmed,
      label: label,
      hintText: hintText,
      icon: icon,
      keyboardType: keyboardType,
    );
  }

  String _displayGenderValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'unknown') {
      return '';
    }

    return trimmed;
  }

  String _displayIndigenousValue(bool value) {
    return value ? 'Yes' : 'No';
  }

  Widget _buildTwoColumnRow({required Widget first, required Widget second}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        if (!isWide) {
          return Column(children: [first, const SizedBox(height: 16), second]);
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

class _LockedField {
  const _LockedField(this.label, this.value);

  final String label;
  final String value;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    super.key,
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

class _ReadOnlyProfileField extends StatefulWidget {
  const _ReadOnlyProfileField({
    super.key,
    required this.value,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType,
  });

  final String value;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  State<_ReadOnlyProfileField> createState() => _ReadOnlyProfileFieldState();
}

class _ReadOnlyProfileFieldState extends State<_ReadOnlyProfileField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(
      skipTraversal: true,
      canRequestFocus: false,
      debugLabel: 'locked_profile_field',
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TextFormField(
        initialValue: widget.value,
        readOnly: true,
        enableInteractiveSelection: false,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          label: Text(widget.label),
          hintText: widget.hintText,
          prefixIcon: Icon(widget.icon, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.validator,
    required this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        label: Text(label),
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffixIcon,
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
      foregroundColor: isPrimary
          ? AppColors.textOnPrimary
          : AppColors.textPrimary,
      elevation: 0,
      side: isPrimary
          ? BorderSide.none
          : const BorderSide(color: AppColors.border),
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: AppRadii.medium),
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

String? _optionalTextValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  if (text.length > 120) {
    return 'Value is too long';
  }
  if (!_textOnlyPattern.hasMatch(text)) {
    return 'Use letters and basic punctuation only';
  }
  return null;
}

String? _optionalPhoneValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  if (!_phonePattern.hasMatch(text)) {
    return 'Enter a valid phone number';
  }
  return null;
}

String? _optionalPostalCodeValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  if (!_postalCodePattern.hasMatch(text)) {
    return 'Use a 4-digit postal code';
  }
  return null;
}

String? _optionalBirthDateValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }

  final parsedDate = _parseBirthDate(text);
  if (parsedDate == null) {
    return 'Use MM/DD/YYYY';
  }

  return null;
}

String? _optionalSelectValidator(String? value) {
  return null;
}

String? _requiredTextValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'This field is required';
  }
  return _optionalTextValidator(text);
}

String? _requiredPhoneValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'This field is required';
  }
  return _optionalPhoneValidator(text);
}

String? _requiredPostalCodeValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'This field is required';
  }
  return _optionalPostalCodeValidator(text);
}

String? _requiredBirthDateValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'This field is required';
  }
  return _optionalBirthDateValidator(text);
}

String? _requiredSelectValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return 'This field is required';
  }
  return null;
}

String? _optionalPhilHealthIdValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  if (!_philHealthPattern.hasMatch(text)) {
    return 'Use a valid PhilHealth ID';
  }
  return null;
}

String? _optionalPhilSysIdValidator(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  if (!_philSysPattern.hasMatch(text)) {
    return 'Use a valid PhilSys ID';
  }
  return null;
}

final RegExp _textOnlyPattern = RegExp(r"^[A-Za-zÀ-ÿ][A-Za-zÀ-ÿ' .,\-/()]*$");
final RegExp _phonePattern = RegExp(r'^\+?[0-9][0-9\s()-]{6,29}$');
final RegExp _postalCodePattern = RegExp(r'^\d{4}$');
final RegExp _philHealthPattern = RegExp(r'^\d{2}-?\d{9}-?\d$');
final RegExp _philSysPattern = RegExp(r'^\d{4}-?\d{7}-?\d$');

List<TextInputFormatter> _nameInputFormatters() {
  return <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÿ' .\-]")),
  ];
}

List<TextInputFormatter> _phoneInputFormatters() {
  return <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-()\s]')),
  ];
}

List<TextInputFormatter> _identifierInputFormatters() {
  return <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
  ];
}

List<TextInputFormatter> _addressInputFormatters() {
  return <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÿ0-9' .,\-/#()]")),
  ];
}

String _formatBirthDate(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '$month/$day/${dateTime.year}';
}

String _formatBirthDateForDisplay(String rawValue) {
  final dateTime = _parseBirthDate(rawValue);
  if (dateTime == null) {
    return rawValue.trim();
  }

  return _formatBirthDate(dateTime);
}

String _formatBirthDateForApi(String rawValue) {
  final dateTime = _parseBirthDate(rawValue);
  if (dateTime == null) {
    return rawValue.trim();
  }

  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day';
}

DateTime? _parseBirthDate(String rawValue) {
  final text = rawValue.trim();
  if (text.isEmpty) {
    return null;
  }

  final mmDdYyyy = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
  if (mmDdYyyy != null) {
    final month = int.tryParse(mmDdYyyy.group(1) ?? '');
    final day = int.tryParse(mmDdYyyy.group(2) ?? '');
    final year = int.tryParse(mmDdYyyy.group(3) ?? '');
    if (month == null || day == null || year == null) {
      return null;
    }

    return DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}T00:00:00Z',
    );
  }

  return DateTime.tryParse('${text}T00:00:00Z');
}
