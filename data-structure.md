# WAH4P Data Structure Plan

## Purpose

This document defines how the app should store data for each feature screen. It separates:

1. **What already exists in the codebase**
2. **What should be persisted for the full product**
3. **What can stay local or derived**

The goal is to keep the schema complete, normalized, and easy to extend without duplicating the same patient data across screens.

## Storage Layers

### 1) Server database
Use Postgres/Supabase as the source of truth for all patient-facing clinical and account data.

### 2) Secure device storage
Use encrypted local storage for device-scoped values that should not live in the shared database.

Current local keys already used in the app:

- `auth.session` — authenticated session payload
- `app.onboarding.completed` — onboarding completion flag
- `auth.mpin.device_id` — device binding identifier
- `auth.mpin.enabled` — local MPIN availability flag

### 3) Derived UI state
Use app state, cached API responses, or computed aggregates for dashboard summaries, filters, and charts.

### 4) File/object storage
Use object storage for attachments such as PDFs, lab result scans, vaccine cards, prescription images, and profile photos.

---

## Design Rules For The Schema

- Use **UUID primary keys** for all patient-owned records.
- Store timestamps in **UTC**.
- Keep a single canonical record per concept whenever possible.
- Separate **raw measurements** from **derived values**.
- Prefer **one-to-many** relations over repeating nested blobs.
- Use **soft delete** for patient-facing records that may need audit retention.
- Use explicit **status enums** for workflow states.
- Include `created_at`, `updated_at`, and when relevant `deleted_at`, `created_by`, and `updated_by`.
- Store clinical notes and attachments separately from core structured fields.

---

## Current Database Foundations In The Repo

These are already represented in the backend and should remain the base of the auth/security layer:

| Table / Store | Purpose |
| --- | --- |
| `auth.users` | Supabase-managed authenticated users |
| `profiles` | Patient display/profile name data |
| `registration_otps` | Registration email OTP state |
| `password_reset_otps` | Password reset OTP state |
| `user_totp_factors` | TOTP 2FA configuration |
| `user_totp_recovery_codes` | Backup/recovery codes for 2FA |
| `user_mpins` | Account MPIN state |
| `user_mpin_devices` | Device registration for MPIN |
| secure local session | Access/refresh token and profile snapshot |
| secure local onboarding flag | Whether onboarding has been completed |
| secure local MPIN flags | Device ID and whether MPIN is enabled locally |

---

## Canonical Core Entities

These are the recommended shared entities that most feature screens should build on.

| Entity | Purpose | Core fields |
| --- | --- | --- |
| `profiles` | Patient identity and display name | `id`, `email`, `given_names[]`, `family_name`, optional demographic fields |
| `patient_identifiers` | Links a patient to facility-specific or government IDs | `id`, `profile_id`, `facility_id`, `identifier_type`, `identifier_value`, `verified_at` |
| `facilities` | Clinics, hospitals, labs, and partner sites | `id`, `code`, `name`, `type`, `address`, `contact_info` |
| `observations` | Numeric and time-based measurements | `id`, `profile_id`, `type`, `value`, `unit`, `measured_at`, `source` |
| `clinical_documents` | Uploaded/attached clinical files | `id`, `profile_id`, `document_type`, `file_url`, `mime_type`, `issued_at` |
| `encounters` | Visits, consultations, and clinical interactions | `id`, `profile_id`, `facility_id`, `mode`, `provider_name`, `encounter_at`, `status` |
| `diagnostic_results` | Lab, imaging, and cardiology results | `id`, `encounter_id`, `category`, `title`, `conclusion`, `reported_at` |
| `immunizations` | Vaccine history | `id`, `profile_id`, `vaccine_name`, `dose_number`, `administered_at`, `facility_id` |
| `medications` | Medication master list | `id`, `name`, `strength`, `form`, `route` |
| `prescriptions` | Active or historical prescriptions | `id`, `profile_id`, `medication_id`, `dosage`, `frequency`, `start_date`, `end_date`, `status` |
| `medication_adherence` | Medicine intake / adherence log | `id`, `profile_id`, `prescription_id`, `taken_at`, `scheduled_at`, `status`, `note` |
| `appointment_requests` / `appointments` | Booking workflow and confirmed visits | `id`, `profile_id`, `type`, `mode`, `scheduled_at`, `location_or_platform`, `provider_name`, `status` |
| `resupply_requests` | Medication refill workflow | `id`, `profile_id`, `status`, `requested_at`, `submitted_at`, `approved_at`, `note` |
| `resupply_request_items` | Medicines included in a refill request | `id`, `resupply_request_id`, `prescription_id`, `quantity`, `dispense_quantity` |
| `notifications` | In-app alerts and reminders | `id`, `profile_id`, `type`, `title`, `body`, `read_at`, `created_at` |
| `calendar_events` | Appointments and reminders shown in calendar views | `id`, `profile_id`, `source_type`, `source_id`, `starts_at`, `ends_at`, `status` |
| `consents` | Privacy/legal acknowledgements | `id`, `profile_id`, `consent_type`, `version`, `accepted_at` |

---

## Screen-To-Data Mapping

### 1) Splash and onboarding

| Screen / Route | What to store | Suggested storage |
| --- | --- | --- |
| `SplashScreen` | No user data. It only routes based on auth/onboarding state. | Derived from local store and auth session |
| `OnboardingScreen1-4` | No clinical data. The pages themselves are static content. | Static content in app code |
| `OnboardingCompleteScreen` | Completion flag and completion timestamp. | Secure local storage (`app.onboarding.completed`) |

**Notes**
- Onboarding should not create server records by itself.
- The only persistence needed is the completion flag used during startup.

---

### 2) Authentication and account setup

This includes registration, email verification, login, forgot/reset password, TOTP, MPIN, and security verification screens.

| Screen / Route | What to store | Suggested tables / stores |
| --- | --- | --- |
| Registration email flow | Email address, OTP issuance, verification status | `registration_otps`, auth service tokens |
| Registration personal details | Name fields to create the patient profile | `profiles` |
| Password registration | Account password in auth provider, registration token tracking | `auth.users`, registration token flow |
| Login | Access/refresh token session, profile snapshot, current user | secure local session, `profiles` |
| Forgot/reset password | Reset OTP state, reset token state | `password_reset_otps` |
| TOTP setup | Secret, enabled state, recovery codes | `user_totp_factors`, `user_totp_recovery_codes` |
| MPIN setup / confirm | MPIN hash, device registration, lockout state | `user_mpins`, `user_mpin_devices`, secure local MPIN flags |
| Security verification | Short-lived security verification token | token payload only; no long-term storage |
| Logout / sign out | Session invalidation and optional local cleanup | clear secure session + local MPIN flags |

**Recommended auth profile shape**

```text
profiles
- id (uuid, same as auth.users.id)
- email
- given_names[]
- family_name
- phone_number?           (future)
- date_of_birth?          (future)
- sex_at_birth?           (future)
- address?                (future)
- avatar_url?             (future)
- created_at
- updated_at
```

**Notes**
- The current implementation only needs name data to support the profile screen and greeting logic.
- Future demographic fields can be added without changing the profile identity model.

---

### 3) Profile screen and personal information

| Screen / Route | What to store | Suggested tables |
| --- | --- | --- |
| Profile | Display name, email, auth state, sign-out state | `profiles`, auth session |
| Personal Information | Editable name fields and future demographic fields | `profiles` |
| Privacy Statement | Legal acknowledgement only if acceptance is tracked | `consents` |
| About Us / About App | No user-specific data | none |

**Profile screen fields to support now**
- given name parts
- family name
- email address
- optional avatar/initials display

**Future profile fields worth supporting**
- date of birth
- sex / gender identity if needed by care workflows
- phone number
- address / municipality / province
- emergency contact
- preferred language
- profile photo
- preferred notification channels

---

### 4) Dashboard

The dashboard should be mostly **derived data**, not a separate source of truth.

| Dashboard element | Source data |
| --- | --- |
| Service cards | Static navigation config |
| Health metric cards | `observations` or aggregated vital records |
| Daily tip | Static content or CMS config |
| Calendar tab | `appointments` and `calendar_events` |
| Alerts tab | `notifications` and workflow reminders |

**Notes**
- Do not duplicate raw clinical records just to render the dashboard.
- Build dashboard cards from read-only summaries, rollups, and latest records.

---

### 5) Personal Records

This screen group covers self-tracked patient measurements.

#### 5.1 BMI

| What to store | Suggested data |
| --- | --- |
| Height | `observations` record, unit in cm or m |
| Weight | `observations` record, unit in kg |
| BMI value | Derived from weight and height, or stored as a computed snapshot |
| Notes | Optional free text |

**Best practice**
- Store **height and weight** as the source values.
- Compute BMI for display and reporting.
- If BMI is entered manually, store both the manual value and the source measurements when available.

#### 5.2 Blood pressure

| What to store | Suggested data |
| --- | --- |
| Systolic / diastolic | Numeric reading pair |
| Pulse rate | Optional numeric field |
| Measurement position | Sitting, standing, lying, etc. |
| Cuff / method | Optional metadata |
| Notes | Optional free text |
| Measured at | Timestamp |

#### 5.3 Temperature

| What to store | Suggested data |
| --- | --- |
| Temperature value | Numeric field |
| Unit | Celsius / Fahrenheit |
| Measurement method | Oral, axillary, tympanic, etc. |
| Notes | Optional free text |
| Measured at | Timestamp |

#### 5.4 Medicine intake

| What to store | Suggested data |
| --- | --- |
| Medication reference | Link to `prescriptions` or `medications` |
| Scheduled dose time | Planned intake time |
| Actual intake time | When the dose was taken |
| Status | Taken / missed / delayed / skipped |
| Quantity | Dose amount if relevant |
| Notes | Side effects or comments |

**Recommended tables**
- `observations` for generic physical measurements
- `medication_adherence` for intake tracking
- optionally separate specialized tables for blood pressure and temperature if reporting becomes complex

---

### 6) Health Records / EHR

This group represents provider-issued or provider-reviewed records.

#### 6.1 Medical History

| What to store | Suggested data |
| --- | --- |
| Diagnoses / conditions | Diagnosis name, code, onset date, status |
| Procedures / surgeries | Procedure name, date, outcome |
| Care notes | Short free-text summary |
| Facility | Source facility |
| Provider | Treating clinician |

**Suggested table**: `medical_history_entries` or `conditions`

#### 6.2 Immunization Records

| What to store | Suggested data |
| --- | --- |
| Vaccine name | Standard vaccine name |
| Dose number | Dose within the series |
| Administered date | Timestamp |
| Performer | Nurse / facility / provider |
| Lot number | Optional but recommended |
| Site / route | Injection site or administration route |
| Notes | Optional |

**Suggested table**: `immunizations`

#### 6.3 Medical Consultations

| What to store | Suggested data |
| --- | --- |
| Consultation type | Onsite / teleconsultation / follow-up |
| Encounter date | Timestamp |
| Provider | Clinician name or ID |
| Facility/platform | Clinic name or telehealth platform |
| Reason for visit | Chief complaint / purpose |
| Summary | Visit summary / plan |
| Follow-up | Optional next steps |

**Suggested table**: `encounters`

#### 6.4 Laboratory Results

| What to store | Suggested data |
| --- | --- |
| Test name | CBC, ECG, x-ray, etc. |
| Category | Laboratory / radiology / cardiology / etc. |
| Performer | Lab or imaging center |
| Collected / reported date | Timestamps |
| Result summary | Plain-language conclusion |
| Structured values | Optional result components |
| Attachment | PDF/image if available |

**Suggested tables**: `diagnostic_results`, `clinical_documents`

**Notes**
- Keep the result summary separate from the attachment.
- If result components are needed later, add a child table like `diagnostic_result_values`.

---

### 7) Appointments

| Screen / Route | What to store | Suggested tables |
| --- | --- | --- |
| Onsite consultation | Consultation type, date/time, facility, provider, reason, notes | `appointments` or `encounters` |
| Teleconsultation | Same as above, plus platform and virtual meeting info | `appointments` |
| Calendar screen | Read model of upcoming appointments and reminders | `calendar_events` |

**Recommended appointment shape**

```text
appointments
- id
- profile_id
- appointment_type
- mode                (onsite | teleconsultation)
- scheduled_at
- duration_minutes?
- facility_id?        (onsite)
- platform?           (teleconsultation)
- provider_name?
- reason
- notes?
- status              (draft | requested | confirmed | completed | cancelled | no_show)
- created_at
- updated_at
```

**Notes**
- The booking screen can keep local draft state while the user is stepping through the wizard.
- Persist only when the booking is submitted.

---

### 8) Medication Resupply

| Screen / Route | What to store | Suggested tables |
| --- | --- | --- |
| Medication resupply hub | Navigation only | none |
| Request form | Requested medicines, quantities, notes, selected prescription | `resupply_requests`, `resupply_request_items` |
| Prescription history | Historical request list and current status | `resupply_requests` |
| Prescription viewer | Prescription attachment and metadata | `prescriptions`, `clinical_documents` |

**Recommended resupply request shape**

```text
resupply_requests
- id
- profile_id
- status              (draft | submitted | pending | approved | rejected | cancelled | fulfilled)
- requested_at
- submitted_at
- reviewed_at?
- approved_at?
- note?
- facility_id?
- created_at
- updated_at
```

```text
resupply_request_items
- id
- resupply_request_id
- prescription_id?
- medication_id
- quantity_requested
- dispense_quantity
- dosage_snapshot
- frequency_snapshot
```

**Notes**
- The current UI uses mock data, but the final schema should keep the request header and individual items separate.
- Store a snapshot of dosage/frequency at request time so history remains accurate even if the prescription changes later.

---

### 9) Patient record linking

This flow is used to connect the app account to an existing patient record at a facility.

| Screen / Route | What to store | Suggested tables |
| --- | --- | --- |
| Intro screen | No persistence | none |
| Patient identifier screen | Patient ID, record number, or other identifier | `patient_identifiers` |
| Facility selection screen | Facility chosen for linkage | `facilities`, `patient_identifiers` |

**Recommended linkage shape**

```text
patient_identifiers
- id
- profile_id
- facility_id
- identifier_type      (MRN, patient_id, PhilHealth, etc.)
- identifier_value
- verified_at?
- verified_by?
- status               (pending | verified | rejected | revoked)
- created_at
- updated_at
```

**Notes**
- If a patient can be linked to multiple facilities, keep one row per facility linkage.
- Never store raw external system credentials in this table.

---

### 10) Notifications and calendar

| Screen / Route | What to store | Suggested tables |
| --- | --- | --- |
| Notifications screen | Notification items, read state, deep-link target | `notifications` |
| Calendar screen | Event start/end, source entity, display status | `calendar_events` |

**Recommended notification shape**

```text
notifications
- id
- profile_id
- type                (appointment | resupply | result_ready | reminder | system)
- title
- body
- deep_link_route?
- source_type?
- source_id?
- read_at?
- created_at
```

---

## Feature Screens That Do Not Need Dedicated Persistence

These can stay static or derived unless future product requirements change.

| Screen | Storage approach |
| --- | --- |
| About Us | Static content |
| About App | Static app metadata |
| Privacy Statement | Static legal content, plus optional consent tracking |
| Splash | Derived from auth/onboarding state |
| Help modals | Static UI content |
| Dashboard service cards | Static navigation config |
| Onboarding page text/images | Static content |

---

## Recommended API / Model Boundaries

### Backend responsibilities
- Own the source-of-truth records
- Validate and normalize payloads
- Enforce user ownership and facility access
- Return read models tailored to each screen

### Frontend responsibilities
- Capture draft input
- Validate basic UX rules before submission
- Render summaries and derived values
- Keep only session/onboarding/device flags locally

### Shared rules
- Use the same naming and enum values across frontend, backend, and database layers.
- Convert API payloads into typed models at the boundary.
- Never rely on ad hoc JSON blobs when a record has clear structure.

---

## Suggested Implementation Order

1. **Auth and profile foundation**
   - login/session storage
   - profile data
   - onboarding completion flag
   - security state (TOTP, MPIN, device binding)

2. **Patient record linking**
   - facility lookup
   - identifier capture
   - verification status

3. **Personal records**
   - vitals and self-tracking records
   - adherence entries

4. **Health records**
   - consultations
   - lab results
   - immunizations
   - medical history

5. **Appointments and resupply**
   - booking requests
   - refill requests
   - history and status tracking

6. **Notifications and calendar**
   - reminder generation
   - read/unread state
   - event feed

---

## Open Questions To Resolve Before Implementation

- Which external patient identifier should be treated as primary when linking a record?
- Will the app support multiple facilities per patient from day one?
- Should consultation booking create a draft first, or only persist after final confirmation?
- Do lab results need structured analyte values, or is a document-plus-summary model enough for the first release?
- Should personal records be synced from devices, manually entered, or both?
- Are notifications generated only by the backend, or can the client create local reminders too?

---

## Bottom Line

The app should use a **small auth/profile core** plus a **clinical record model built around encounters, observations, documents, medications, and workflow tables**.

That gives us one stable structure for:

- personal records
- health records
- appointments
- medication resupply
- patient record linking
- dashboard summaries
- security and account state

It also keeps static screens and UI-only flows out of the database, which avoids unnecessary schema noise.
