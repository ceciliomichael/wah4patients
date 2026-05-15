# for-fixing

Source reviewed: `APC TESTING - WAH4P.csv`

This document turns the tester comments in the CSV into a fix map for **wah4patients**. I kept the focus on rows with actual notes, failures, or suggestions; pass-only rows are not repeated here.

## Fix-status checklist

### Fixed already
- [x] UAT-01 — Splash / branding text added to the startup experience
- [x] UAT-09 — Name field design now explains the optional second / middle name fields
- [x] UAT-11 — Password rules now include a special character requirement
- [x] UAT-11 — Password mismatch now shows a visible inline warning
- [x] UAT-26 — Birth date now uses a date picker and displays as `MM/DD/YYYY`
- [x] UAT-26 — Birth date field is labeled as optional
- [x] Dashboard profile-completion prompt now dismisses properly instead of repeating

### Not fixed yet
- [ ] UAT-08 — Save login credentials / fingerprint convenience flow
- [ ] UAT-11 — Registration form state persistence, MPIN reset, and verification timing changes
- [ ] UAT-12 — Login / MPIN state transition issues
- [ ] UAT-13 — Forgot MPIN / OTP simplification
- [ ] UAT-14 — Block old password reuse on reset
- [ ] UAT-21 — Dashboard caching behavior
- [ ] UAT-22 — BP range indicator and setup prompt behavior
- [ ] UAT-24 — Calendar landscape scrolling / readability
- [ ] UAT-27 — Save confirmation / sticky actions / edit affordance cleanup
- [ ] UAT-28 — Required-field handling and name remapping
- [ ] UAT-30 to UAT-35 — BMI / BP / temperature record polish and history UX

### Not fixed yet — interoperability / sync
- [ ] UAT-15 — Verification / sync code flow validation
- [ ] UAT-16 to UAT-20 — Patient record linking flow

## 1) Launch, splash, and branding

### UAT-01
**Comment(s):** rename the app properly for branding; the splash screen does not show the expected logo/app name.

**What needs to be fixed:**
- Update splash branding copy and visuals.
- Ensure the app name/logo are shown consistently during first launch.

**Likely area:**
- `frontend/lib/features/splash/presentation/splash_screen.dart`
- App branding assets/config in `frontend/` (launcher/app metadata)

## 2) Authentication and registration

### UAT-08
**Comment(s):** add a way to save login credentials or use fingerprint; allow continuing registration with the same email.

**What needs to be fixed:**
- Add a reusable sign-in convenience flow if it is part of the product scope.
- Review whether the registration flow should allow reusing the same email and how duplicate-account handling should work.

**Likely area:**
- `frontend/lib/features/auth/presentation/screens/login_screen.dart`
- `frontend/lib/features/auth/presentation/screens/mpin_login_screen.dart`
- `frontend/lib/features/auth/presentation/screens/email_registration_screen.dart`
- `frontend/lib/features/auth/presentation/screens/registration_screen.dart`

### UAT-09
**Comment(s):** first and second name should be combined or clearly explained; second name is confusing and may be optional.

**What needs to be fixed:**
- Clarify the name-field design.
- Either merge the name inputs or make the second-name rule and optionality obvious.

**Likely area:**
- `frontend/lib/features/auth/presentation/screens/registration_personal_details_screen.dart`

### UAT-11
**Comment(s):** privacy statement is empty; password rules should include special characters; no clear indicator when passwords do not match; extend verification code time; registration data should persist when going back; MPIN setup should support reset; validation is too subtle; if MPIN confirmation is wrong, the flow should return to MPIN setup; back navigation should preserve email/password/name.

**What needs to be fixed:**
- Populate the privacy statement content.
- Strengthen password validation rules and surface them clearly.
- Show a visible mismatch state when password/MPIN confirmation does not match.
- Preserve registration form state when navigating backward.
- Add or improve MPIN reset handling.
- Make error messaging more visible than a low-signal snackbar-only pattern.
- Adjust the MPIN confirmation failure path so it returns to the setup step.

**Likely area:**
- `frontend/lib/features/legal/presentation/privacy_statement_screen.dart`
- `frontend/lib/features/auth/presentation/screens/password_registration_screen.dart`
- `frontend/lib/features/auth/presentation/screens/email_verification_screen.dart`
- `frontend/lib/features/auth/presentation/screens/mpin_setup_screen.dart`
- `frontend/lib/features/auth/presentation/screens/mpin_confirm_screen.dart`
- `frontend/lib/features/auth/presentation/screens/forgot_password_screen.dart`
- `frontend/lib/features/auth/presentation/screens/registration_personal_details_screen.dart`

### UAT-12
**Comment(s):** login could not proceed in one test; first-login MPIN handling may be redundant; subsequent logins should use MPIN.

**What needs to be fixed:**
- Investigate the login success path and the state transition after valid credentials.
- Review the rule for when MPIN is required versus optional.
- Confirm that the flow can proceed using a different email/device state without getting stuck.

**Likely area:**
- `frontend/lib/features/auth/presentation/screens/login_screen.dart`
- `frontend/lib/features/auth/presentation/screens/mpin_login_screen.dart`
- `frontend/lib/features/auth/presentation/screens/mpin_setup_screen.dart`

### UAT-13
**Comment(s):** add reset MPIN; OTP error messages are too complicated; MPIN reset could allow password-based verification instead of only OTP; forgot-MPIN support is requested.

**What needs to be fixed:**
- Add a dedicated MPIN reset path or clearly integrate it into password recovery.
- Simplify OTP/verification error messaging.
- Decide whether MPIN reset should support password entry, email, or another recovery method.

**Likely area:**
- `frontend/lib/features/auth/presentation/screens/forgot_password_screen.dart`
- `frontend/lib/features/auth/presentation/screens/mpin_login_screen.dart`
- `frontend/lib/features/auth/presentation/screens/mpin_setup_screen.dart`

### UAT-14
**Comment(s):** the old password was accepted when creating a new password.

**What needs to be fixed:**
- Block password reuse during reset if reuse is not allowed.
- Ensure reset-password validation checks the new value against the old value.

**Likely area:**
- `frontend/lib/features/auth/presentation/screens/forgot_password_screen.dart`
- Any password validation helper used by the reset flow

### UAT-15
**Comment(s):** verification/sync code screen should be checked if it is included in the build.

**What needs to be fixed:**
- Validate the verification-code flow end to end.
- Confirm that the step exists only where intended and that it advances correctly.

**Likely area:**
- `frontend/lib/features/auth/presentation/screens/email_verification_screen.dart`
- `frontend/lib/features/auth/presentation/screens/security_verification_screen.dart`
- `frontend/lib/features/auth/presentation/screens/totp_challenge_screen.dart`

### Cross-cutting registration note from the CSV
**Comment(s):** reduce duplicate account creation by capturing patient email/phone at intake and using it for account creation or OTP/link delivery.

**What needs to be fixed:**
- Decide whether account creation should be linked to a hospital/RHU/clinic intake process.
- If adopted, add a pre-registration contact capture and account-linking flow.

**Likely area:**
- Registration/auth backend and frontend flows
- `frontend/lib/features/auth/...`
- `backend/src/...` account creation endpoints, if the flow is implemented

## 3) Patient record linking / sync records

### UAT-16 to UAT-20
**Comment(s):** all patient record linking steps failed.

**What needs to be fixed:**
- The linking wizard needs a complete end-to-end pass.
- Verify the intro screen copy, identifier entry, provider/facility selection, success/pending completion state, and invalid-identifier validation.
- Confirm that the flow is wired to backend data instead of stopping at UI placeholders.

**Likely area:**
- `frontend/lib/features/interoperability/presentation/screens/sync_records_wizard_screen.dart`
- `frontend/lib/features/interoperability/presentation/widgets/sync_identifier_step.dart`
- `frontend/lib/features/interoperability/presentation/widgets/sync_provider_step.dart`
- `frontend/lib/features/interoperability/presentation/widgets/sync_request_review_step.dart`
- `frontend/lib/features/interoperability/data/interoperability_api_client.dart`
- `frontend/lib/features/interoperability/domain/interoperability_models.dart`

## 4) Dashboard, navigation, and calendar

### UAT-21
**Comment(s):** dashboard caching data needs review.

**What needs to be fixed:**
- Review dashboard state caching and refresh behavior.
- Make sure stale data is not shown after navigation or login changes.

**Likely area:**
- `frontend/lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- Dashboard data layer under `frontend/lib/features/dashboard/data/`

### UAT-22
**Comment(s):** BP range indicator is incorrect; the setup prompt keeps popping up and should become a user-controlled completion action instead.

**What needs to be fixed:**
- Correct the blood-pressure range classification shown on the dashboard.
- Replace repeated setup popups with a calmer completion CTA or persistent action.

**Likely area:**
- `frontend/lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- `frontend/lib/features/phr/blood_pressure/presentation/screen/blood_pressure_screen.dart`
- Any shared BP classification helper in `frontend/lib/features/phr/blood_pressure/`

### UAT-24
**Comment(s):** the calendar cannot scroll down in landscape; accessibility/zoom or larger text would help.

**What needs to be fixed:**
- Fix landscape scrolling in the calendar view.
- Improve readability for users who need larger text or zoom.

**Likely area:**
- `frontend/lib/features/calendar/presentation/screens/calendar_screen.dart`
- `frontend/lib/features/calendar/presentation/widgets/views/week_view_widget.dart`
- `frontend/lib/features/calendar/presentation/widgets/views/month_view_widget.dart`
- `frontend/lib/features/calendar/presentation/widgets/views/day_view_widget.dart`

## 5) Profile and personal information

### UAT-26
**Comment(s):** birth date should use MM/DD/YYYY; the calendar/date picker is missing or not obvious; the screen saves even when birth date is blank; optional fields should be marked.

**What needs to be fixed:**
- Use a proper date picker or masked date input for birth date.
- Block saves when a required birth date is missing.
- Show an optional indicator if the field is not required.
- Normalize the displayed format to MM/DD/YYYY.

**Likely area:**
- `frontend/lib/features/profile/presentation/screens/personal_information_screen.dart`
- Shared date-input helpers under `frontend/lib/features/profile/presentation/widgets/`

### UAT-27
**Comment(s):** birth date input should be strict; save confirmation should appear when leaving/backing out; the save control should stay visible; show a summary of edited fields; make the edit action clearer; the input should not accept random symbols.

**What needs to be fixed:**
- Tighten birth-date validation and sanitization.
- Add a persistent save action or sticky footer.
- Add a confirmation/summary before discarding or saving edits.
- Improve the edit affordance so users can tell what is editable.

**Likely area:**
- `frontend/lib/features/profile/presentation/screens/personal_information_screen.dart`
- `frontend/lib/features/profile/presentation/widgets/`

### UAT-28
**Comment(s):** required fields are not clearly marked; first name can be blank while other name parts are shifted into it; the UI should redirect to the missing field; deleted required values should not silently reset to the original values.

**What needs to be fixed:**
- Mark required fields clearly.
- Prevent silent field remapping between first/middle/last name.
- Keep validation errors on screen and direct the user to the missing field.
- Do not auto-restore deleted required values as if the save succeeded.

**Likely area:**
- `frontend/lib/features/profile/presentation/screens/personal_information_screen.dart`
- Shared form validation logic in the profile feature

## 6) Personal health record screens

### UAT-30 — BMI
**Comment(s):** age should auto-compute from the patient’s birth date; editing should be available.

**What needs to be fixed:**
- Derive age from the stored birth date instead of requiring manual entry.
- Add edit support where the BMI screen currently behaves as read-only.

**Likely area:**
- `frontend/lib/features/phr/body_mass_index/presentation/screen/body_mass_index_screen.dart`
- `frontend/lib/features/phr/body_mass_index/presentation/utils/body_mass_index_calculations.dart`
- `frontend/lib/features/phr/body_mass_index/presentation/widgets/body_mass_index_age_picker.dart`

### UAT-31 — BMI history and recording
**Comment(s):** BMI changes do not reflect immediately on the dashboard; history entries need timestamps; edit/delete actions are missing; save confirmation is missing; input values should be limited; the flow should confirm the record before saving; unit handling may need a converter or a simpler metric set.

**What needs to be fixed:**
- Refresh dashboard/patient state after BMI save.
- Add timestamps to BMI history entries.
- Support edit/delete if that is in scope for the record model.
- Add clear success feedback and a confirmation/summary step.
- Validate height/weight input bounds.
- Review whether unit conversion is required.

**Likely area:**
- `frontend/lib/features/phr/body_mass_index/presentation/screen/body_mass_index_screen.dart`
- `frontend/lib/features/phr/body_mass_index/presentation/widgets/body_mass_index_add_record_form.dart`
- `frontend/lib/features/phr/body_mass_index/presentation/widgets/body_mass_index_result_dialog.dart`
- `frontend/lib/features/dashboard/presentation/screens/dashboard_screen.dart`
- Backend BMI record persistence in `backend/src/personal-records/`

### UAT-33 — Blood pressure
**Comment(s):** BP ranges are incorrect for values like 130/80 and 120/80; records need timestamps; edit/delete actions are missing; save confirmation is missing; value limits are needed; duplicate save taps should be prevented; history should be sorted oldest to newest or vice versa consistently; labels should include time; users want a review/summary before saving.

**What needs to be fixed:**
- Correct BP classification thresholds.
- Add timestamps and clear time labels in history.
- Prevent duplicate submissions from repeated taps.
- Add input validation bounds.
- Add edit/delete if supported by the product scope.
- Standardize history sorting and record summaries.

**Likely area:**
- `frontend/lib/features/phr/blood_pressure/presentation/screen/blood_pressure_screen.dart`
- Shared BP classification helper under `frontend/lib/features/phr/blood_pressure/`
- Backend BP record persistence in `backend/src/personal-records/`

### UAT-34 / UAT-35 — Temperature
**Comment(s):** confirmations with summaries are wanted; timestamps are needed; edit/delete are missing; value limits are needed; save should not be triggerable repeatedly; history sorting should be fixed; users asked about removing Fahrenheit or simplifying the unit model.

**What needs to be fixed:**
- Add timestamps and clear history ordering.
- Prevent duplicate save taps.
- Add validation for acceptable ranges.
- Add success/confirmation messaging.
- Decide whether Fahrenheit should stay or be converted away.

**Likely area:**
- `frontend/lib/features/phr/temperature/presentation/screen/temperature_screen.dart`
- Backend temperature record persistence in `backend/src/personal-records/`

## 7) Health records, appointments, and resupply

The CSV did not capture concrete issue comments for the following UAT groups, so they should be treated as **test coverage only** unless new defect notes are added later:
- `UAT-37` medicine intake
- `UAT-38` to `UAT-45` health records screens
- `UAT-46` to `UAT-52` medication resupply flow
- `UAT-53` to `UAT-57` appointment booking
- `UAT-58` to `UAT-60` about/support/legal screens, except for the privacy-statement content issue already noted above

## 8) Recommended fix order

1. **Authentication and profile validation**
   - UAT-11, UAT-12, UAT-13, UAT-14, UAT-26, UAT-27, UAT-28
2. **Patient record linking / interoperability**
   - UAT-16 to UAT-20
3. **Clinical record entry quality**
   - UAT-30, UAT-31, UAT-33, UAT-34/UAT-35
4. **Dashboard and calendar usability**
   - UAT-21, UAT-22, UAT-24
5. **Branding and splash cleanup**
   - UAT-01

## 9) Notes

- Most issues are frontend Flutter concerns, but BMI/BP/temperature persistence and validation may also need backend support in `backend/src/personal-records/`.
- Several comments are suggestions rather than hard failures; they are still useful as product backlog items, but they should be prioritized separately from blocking defects.
- The privacy statement issue is important because it appears in both the UAT comments and the legal screen path.
