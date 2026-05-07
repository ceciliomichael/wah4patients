# Backlog: PH Core Patient Profile + WAH4PC Sync Integration

## Epic 1: Patient Profile and App Data Readiness

### Feature 1.1: PH Core patient profile completion

#### US-001 — Complete patient profile for sync eligibility
**Story points:** 8

As a patient, I want to complete my profile in Settings so my identity can be used to sync records with hospitals.

**Tasks**
- Extend profile fields beyond name-only data.
- Capture sync-required fields: full name, birth date, gender, contact info, and at least one supported identifier when available.
- Support optional PH Core fields: address, emergency contact, communication/language, and demographic details.
- Save patient profile data in the backend.
- Validate whether the profile is complete enough for sync.

#### US-002 — Show profile completion and sync readiness
**Story points:** 5

As a patient, I want to know if my profile is ready for record sync.

**Tasks**
- Add backend profile-completion status logic.
- Show profile completion status in Settings/Profile.
- Display missing required fields.
- Block sync actions when required fields are missing.

#### US-003 — Build PH Core Patient mapper
**Story points:** 5

As the system, I want to convert the app patient profile into a PH Core `Patient` resource.

**Tasks**
- Map internal profile fields to PH Core `Patient`.
- Include PH Core profile metadata.
- Map identifiers, name, gender, birthDate, telecom, address, and active status.
- Validate required Patient fields before sync.
- Add mapper tests.

### Feature 1.2: App screen data contracts for PH Core mapping

#### US-004 — Prepare health record screens for PH Core mapping
**Story points:** 8

As the system, I want health record data to map cleanly to PH Core resources.

**Tasks**
- Map Medical History to `Condition` and/or `Procedure`.
- Map Immunization Records to `Immunization`.
- Map Consultation History to `Encounter`.
- Map Laboratory Results to `Observation` or `Bundle`.
- Document missing internal fields needed for PH Core compliance.

#### US-005 — Prepare appointment and medication screens for PH Core mapping
**Story points:** 8

As the system, I want onsite consultation, teleconsultation, request resupply, and prescription history to be backend-ready.

**Tasks**
- Define backend DTOs for onsite consultation and teleconsultation.
- Prepare appointment data for `Encounter` mapping.
- Define backend DTOs for medication resupply requests.
- Prepare medication/resupply data for `MedicationRequest` mapping.
- Replace mock-only assumptions with API-ready models.

---

## Epic 2: WAH4PC Gateway Sync Integration

### Feature 2.1: Provider selection and outbound gateway requests

#### US-006 — Add provider discovery and target selection
**Story points:** 5

As a patient, I want to select the hospital/provider where my records should be synced from.

**Tasks**
- Add backend gateway call for provider discovery using `GET /api/v1/providers`.
- Expose provider list to the frontend.
- Add frontend target provider selection.
- Store selected `targetId` for sync requests.
- Use configured `requesterId` for our provider identity.

#### US-007 — Build PH Core request builder
**Story points:** 13

As the backend, I want to build PH Core-compliant payloads from internal app data before calling WAH4PC.

**Tasks**
- Create a dedicated request-builder module.
- Build resource-specific mappers for `Patient`, `Condition`, `Procedure`, `Immunization`, `Encounter`, `Observation`, and `MedicationRequest`.
- Include patient identifiers for provider matching.
- Validate required fields before gateway submission.
- Add unit tests for each mapper.

#### US-008 — Build WAH4PC gateway client
**Story points:** 8

As the backend, I want to submit sync requests to the WAH4PC Gateway securely and reliably.

**Tasks**
- Add gateway client service.
- Support `POST /api/v1/fhir/request/{resourceType}`.
- Support `POST /api/v1/fhir/push/{resourceType}` if needed.
- Add `X-API-Key` and `Idempotency-Key` headers.
- Handle 400, 401, 403, 404, 409, 429, 500, and 502 responses.
- Add mocked gateway client tests.

### Feature 2.2: Webhooks, transactions, and sync results

#### US-009 — Implement required provider webhook endpoints
**Story points:** 13

As a provider system, we need to receive gateway callbacks and process inbound FHIR data.

**Tasks**
- Implement `/api/fhir/practitioners`.
- Implement `/fhir/process-query`.
- Implement `/fhir/receive-results`.
- Implement `/fhir/receive-push`.
- Validate `X-Gateway-Auth` on all gateway-originated requests.
- Acknowledge webhooks quickly and process asynchronously.

#### US-010 — Track sync transactions and store received results
**Story points:** 13

As the system, I want to track sync requests and route received records into the correct app sections.

**Tasks**
- Create transaction storage for requesterId, targetId, resourceType, patient ID, idempotency key, status, and timestamps.
- Store gateway transaction IDs and callback results.
- Route `Condition`/`Procedure` to Medical History.
- Route `Immunization` to Immunization Records.
- Route `Encounter` to Consultation History.
- Route `Observation` to Laboratory Results.
- Route medication resources to prescription/resupply history where applicable.
- Preserve raw FHIR payloads for audit/debugging.

---

## Environment Requirements

### Frontend
- `BACKEND_BASE_URL`
- `BACKEND_API_KEY`

### Backend
- Existing backend auth and Supabase environment variables.
- `WAH4PC_GATEWAY_BASE_URL`
- `WAH4PC_API_KEY`
- `WAH4PC_PROVIDER_ID`
- `WAH4PC_GATEWAY_AUTH_KEY`
- `PUBLIC_BASE_URL`
- Optional: `WAH4PC_PRACTITIONER_LIST_ENDPOINT`

## Story Point Summary

| Epic | User Stories | Points |
| --- | ---: | ---: |
| Epic 1: Patient Profile and App Data Readiness | 5 | 34 |
| Epic 2: WAH4PC Gateway Sync Integration | 5 | 52 |
| **Total** | **10** | **86** |
