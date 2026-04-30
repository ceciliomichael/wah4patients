# WAH4P Implementation Checklist

This checklist is meant to track the data and persistence work needed for the app’s screens.

Legend:
- `[ ]` = not started
- `[x]` = done

---

## 1) Auth, Session, and Security Foundation

### Registration and login
- [ ] Persist registration OTP state
- [ ] Persist password reset OTP state
- [ ] Persist login session tokens securely
- [ ] Persist profile snapshot inside secure session storage
- [ ] Support session refresh and expiry handling

### Profile creation and updates
- [ ] Create and update patient profile records
- [ ] Store given names and family name in the profile record
- [ ] Keep profile display name derived from stored name fields
- [ ] Support profile hydration into the app session after login

### TOTP / MPIN / device security
- [ ] Store TOTP enabled state
- [ ] Store TOTP secret securely
- [ ] Store TOTP recovery codes
- [ ] Store MPIN hash and lockout state
- [ ] Store MPIN device registration records
- [ ] Store local MPIN device ID securely
- [ ] Store local MPIN enabled flag securely
- [ ] Support security verification tokens as short-lived values only

### Onboarding and startup state
- [ ] Store onboarding completion flag securely
- [ ] Make splash routing depend on auth + onboarding state only
- [ ] Keep onboarding screens static and non-persistent

---

## 2) Profile Screen and Personal Information

- [ ] Persist personal information edits to the `profiles` record
- [ ] Keep name inputs normalized before saving
- [ ] Keep email read-only in profile display unless account policy changes
- [ ] Support initials / avatar display from profile data
- [ ] Add future profile fields only if needed by product rules
  - [ ] date of birth
  - [ ] sex / gender identity
  - [ ] phone number
  - [ ] address
  - [ ] emergency contact
  - [ ] preferred language
  - [ ] profile photo

---

## 3) Patient Record Linking

- [ ] Store patient identifier values per facility
- [ ] Store facility selection for linkage
- [ ] Support pending / verified / rejected / revoked linkage status
- [ ] Store verification metadata when available
- [ ] Prevent raw external credentials from being stored here
- [ ] Allow multiple facility linkages if product requirements allow it

---

## 4) Personal Records

### BMI
- [ ] Store height measurement
- [ ] Store weight measurement
- [ ] Compute BMI from stored measurements where possible
- [ ] Allow optional manual BMI snapshot only if required
- [ ] Store notes when present
- [ ] Keep measurement source and units explicit

### Blood pressure
- [ ] Store systolic pressure
- [ ] Store diastolic pressure
- [ ] Store pulse rate when available
- [ ] Store measurement position and method metadata
- [ ] Store notes and timestamps

### Temperature
- [ ] Store temperature value
- [ ] Store temperature unit
- [ ] Store measurement method metadata
- [ ] Store notes and timestamps

### Medicine intake
- [ ] Store medication or prescription reference
- [ ] Store scheduled intake time
- [ ] Store actual intake time
- [ ] Store adherence status
- [ ] Store quantity and notes when needed

---

## 5) Health Records / EHR

### Medical history
- [ ] Store diagnoses and condition history
- [ ] Store procedures and surgeries
- [ ] Store care notes and outcomes
- [ ] Store source facility and provider information
- [ ] Support structured coding if available later

### Immunization records
- [ ] Store vaccine name
- [ ] Store dose number
- [ ] Store administered date
- [ ] Store performer / facility data
- [ ] Store lot number, route, and site if available
- [ ] Store notes or remarks

### Medical consultations
- [ ] Store consultation type
- [ ] Store provider information
- [ ] Store encounter date and status
- [ ] Store facility or telehealth platform information
- [ ] Store reason for visit and visit summary
- [ ] Store follow-up information

### Laboratory results
- [ ] Store test name and category
- [ ] Store performer or lab center
- [ ] Store collected and reported timestamps
- [ ] Store plain-language result summary
- [ ] Store structured result values if needed
- [ ] Store attachments for PDFs or scan images

---

## 6) Appointments

- [ ] Store appointment draft state while booking
- [ ] Store final appointment request or appointment record on submit
- [ ] Store appointment type and mode
- [ ] Store scheduled date and time
- [ ] Store provider information
- [ ] Store facility or platform information
- [ ] Store reason, notes, and confirmation state
- [ ] Support calendar event generation from appointment data

---

## 7) Medication Resupply

### Request form
- [ ] Store selected prescription or medicine reference
- [ ] Store requested quantity
- [ ] Store dispense quantity
- [ ] Store dosage and frequency snapshots
- [ ] Store optional notes
- [ ] Store draft vs submitted status

### History
- [ ] Store resupply request header records
- [ ] Store per-item request details separately
- [ ] Store status changes over time
- [ ] Store reviewer notes and approval timestamps

### Prescription viewer
- [ ] Store prescription metadata
- [ ] Store prescription attachments when available
- [ ] Keep viewer data read-only

---

## 8) Dashboard

- [ ] Drive dashboard service cards from static navigation config
- [ ] Drive dashboard health cards from latest server data or aggregates
- [ ] Drive dashboard calendar tab from appointments / calendar events
- [ ] Drive dashboard alerts tab from notifications / reminders
- [ ] Avoid duplicating raw clinical data in dashboard-only tables
- [ ] Keep daily tips as static content or CMS-driven content

---

## 9) Notifications and Calendar

### Notifications
- [ ] Store notification title and body
- [ ] Store notification type
- [ ] Store read state
- [ ] Store deep-link target when relevant
- [ ] Store source entity reference when relevant

### Calendar
- [ ] Store calendar event start and end timestamps
- [ ] Store source entity references
- [ ] Store display status and reminder state
- [ ] Build calendar entries from appointments and reminders

---

## 10) Static or Derived Screens

These screens should not get their own persistence unless requirements change.

- [ ] Splash routing logic should stay derived
- [ ] Onboarding pages should stay static
- [ ] Help modals should stay static
- [ ] About Us should stay static
- [ ] About App should stay static
- [ ] Privacy Statement should stay static unless consent tracking is added
- [ ] Dashboard service cards should stay static config
- [ ] Hub/menu screens should stay navigation-only

---

## 11) Backend and API Layer

- [ ] Validate all incoming request payloads
- [ ] Normalize names, timestamps, and identifiers at the boundary
- [ ] Enforce patient ownership on every record query and mutation
- [ ] Return read models tailored to the UI screens
- [ ] Keep frontend drafts separate from backend source-of-truth records
- [ ] Keep attachments in object storage, not inside table rows

---

## 12) Data Quality and Safety

- [ ] Use UUIDs for new record IDs
- [ ] Use UTC timestamps everywhere
- [ ] Use soft delete where audit history matters
- [ ] Use enums for status fields
- [ ] Keep raw measurement values separate from derived values
- [ ] Avoid nested blobs when a child table is clearer
- [ ] Add indexes for common lookups: `profile_id`, `facility_id`, `status`, `created_at`

---

## 13) Foundation Checks Before Release

- [ ] Confirm the canonical database model for patient-owned records
- [ ] Confirm which screens are server-backed vs local-only vs static
- [ ] Confirm the source of truth for patient identity (`profiles` + `auth.users`)
- [ ] Confirm the storage strategy for attachments and uploaded documents
- [ ] Confirm audit fields and timestamp conventions for all tables
- [ ] Confirm enum values for workflow statuses across the app

---

## 14) Verification Before Release

- [ ] Check every screen against the data-structure plan
- [ ] Check that no screen depends on undeclared data
- [ ] Check that local storage is only used for session/device/onboarding data
- [ ] Check that static screens remain unpersisted
- [ ] Check that record summaries are derived from canonical data
- [ ] Check that all new tables have clear ownership and lifecycle rules
- [ ] Check that the schema can support future syncing, auditing, and reporting

---

## 15) Suggested Build Order

- [ ] Auth/session/security foundation
- [ ] Profile and personal information
- [ ] Patient record linking
- [ ] Personal records
- [ ] Health records / EHR
- [ ] Appointments
- [ ] Medication resupply
- [ ] Dashboard
- [ ] Notifications and calendar
- [ ] Static or derived screens
- [ ] Backend and API layer
- [ ] Data quality and safety
- [ ] Final verification pass
