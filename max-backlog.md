# Max Backlog: PH Core Patient Profile + WAH4PC Sync Integration

## Goal
Enable the app to sync patient records with external hospitals/providers through the WAH4PC Gateway by completing PH Core-ready patient profiles, mapping internal app data to PH Core/FHIR resources, selecting target providers, submitting gateway requests, receiving callbacks, and routing returned records into the correct app screens.

---

## Epic 1: PH Core Patient Identity and Profile Completion

### Feature 1.1: Patient profile data model

#### US-001 — Extend patient profile fields for PH Core readiness
**Story points:** 8

As a patient, I want my profile to contain the information needed for hospital record sync.

**Tasks**
- Extend backend patient profile storage beyond name-only data.
- Add sync-required fields: full name, birth date, gender, contact info, and supported identifiers.
- Add optional PH Core fields: address, emergency contact, language/communication, and demographic details.
- Update profile DTOs and validation rules.
- Preserve backward compatibility with existing signup/profile behavior.

#### US-002 — Update Personal Information screen for profile completion
**Story points:** 8

As a patient, I want to complete my sync profile from Settings > Personal Information.

**Tasks**
- Add form fields for birth date, gender, contact info, identifiers, and address.
- Mark fields required for sync separately from optional fields.
- Add clear validation messages.
- Save profile updates through the backend.
- Keep signup lightweight and avoid forcing all PH Core fields during account creation.

#### US-003 — Add profile completion and sync readiness status
**Story points:** 5

As a patient, I want to know whether my profile is ready for sync.

**Tasks**
- Add backend service to calculate profile completeness.
- Return missing required fields.
- Add frontend profile-completion banner/status.
- Block sync actions when required fields are missing.
- Add tests for complete and incomplete profile states.

### Feature 1.2: PH Core Patient mapping

#### US-004 — Build PH Core Patient mapper
**Story points:** 5

As the system, I want to convert the internal patient profile into a PH Core `Patient` resource.

**Tasks**
- Map internal fields to `Patient.identifier`, `Patient.name`, `Patient.gender`, `Patient.birthDate`, `Patient.telecom`, `Patient.address`, and `Patient.active`.
- Include PH Core profile URL in `meta.profile`.
- Normalize patient names and identifiers.
- Validate required Patient fields before sync.
- Add unit tests using `resources/examples/ph-core/Patient-patient-single-example.json` as reference.

#### US-005 — Support patient identifiers for provider matching
**Story points:** 5

As the system, I want to send reliable identifiers so hospitals can match the patient.

**Tasks**
- Support PhilHealth ID, MRN, and other FHIR identifier systems.
- Validate identifier system/value pairs.
- Prevent hardcoded assumptions about PhilHealth-only matching.
- Allow multiple identifiers per patient.
- Document supported identifier systems.

---

## Epic 2: Provider Discovery and Sync Preparation

### Feature 2.1: Provider discovery

#### US-006 — Fetch registered providers from WAH4PC Gateway
**Story points:** 5

As a patient, I want to see available hospitals/providers for record sync.

**Tasks**
- Add backend client call for `GET /api/v1/providers`.
- Expose provider list through backend API.
- Ensure internal gateway fields are not exposed to the frontend.
- Add error handling for unavailable gateway/provider list.
- Add tests with mocked provider responses.

#### US-007 — Add target provider selection to sync flow
**Story points:** 5

As a patient, I want to choose the hospital/provider where my records should be synced from.

**Tasks**
- Add provider selection UI.
- Store selected `targetId` for sync request submission.
- Display provider name, facility code, type, and location.
- Validate that selected provider is active.
- Handle empty provider list state.

### Feature 2.2: Requester provider setup

#### US-008 — Configure requester provider identity
**Story points:** 3

As the backend, I need a configured requester provider ID for outbound gateway requests.

**Tasks**
- Add `WAH4PC_PROVIDER_ID` env validation.
- Use requester ID in gateway request payloads.
- Document difference between `requesterId`, `senderId`, and `targetId`.
- Add startup validation for missing provider ID.

#### US-009 — Prepare sync request eligibility checks
**Story points:** 5

As the system, I want to validate readiness before submitting any gateway request.

**Tasks**
- Check profile completion.
- Check selected target provider.
- Check requester provider configuration.
- Check patient identifiers.
- Return actionable validation errors to the frontend.

---

## Epic 3: PH Core Request Builder for App Data

### Feature 3.1: Health record resource mapping

#### US-010 — Map Medical History to PH Core resources
**Story points:** 8

As the system, I want to map medical history records to PH Core `Condition` and/or `Procedure` resources.

**Tasks**
- Define subtype rules for diagnosis/history vs procedure/surgery.
- Create `Condition` mapper.
- Create `Procedure` mapper where applicable.
- Map patient reference, status, code/text, dates, notes, and encounter references where available.
- Add unit tests using PH Core examples.

#### US-011 — Map Immunization Records to PH Core Immunization
**Story points:** 5

As the system, I want to map immunization records to PH Core `Immunization` resources.

**Tasks**
- Create `Immunization` mapper.
- Map vaccine code/text, status, occurrence date, patient, performer, location, lot number, and notes where available.
- Validate required fields.
- Add tests using the immunization PH Core example.

#### US-012 — Map Consultation History to PH Core Encounter
**Story points:** 5

As the system, I want to map consultation history to PH Core `Encounter` resources.

**Tasks**
- Create `Encounter` mapper.
- Map consultation type, status, class, subject, participant, period, provider, reason, and diagnosis references.
- Support onsite and teleconsultation classifications.
- Add mapper tests.

#### US-013 — Map Laboratory Results to PH Core Observation
**Story points:** 8

As the system, I want to map laboratory results to PH Core `Observation` resources.

**Tasks**
- Create `Observation` mapper.
- Map result name/code, value, unit, interpretation, effective date, performer, and patient reference.
- Support grouped lab panels as `Bundle` when needed.
- Validate required observation fields.
- Add mapper tests.

### Feature 3.2: Appointment and medication workflow mapping

#### US-014 — Prepare onsite and teleconsultation data for Encounter mapping
**Story points:** 8

As the system, I want appointment booking data to support PH Core encounter workflows.

**Tasks**
- Define backend DTOs for onsite consultation bookings.
- Define backend DTOs for teleconsultation bookings.
- Map booking mode, date/time, provider, facility/platform, reason, and notes.
- Prepare appointment records for `Encounter` generation.
- Replace mock-only frontend assumptions with API-backed contracts.

#### US-015 — Prepare resupply and prescription history for MedicationRequest mapping
**Story points:** 8

As the system, I want medication resupply and prescription history to support PH Core medication workflows.

**Tasks**
- Define backend DTOs for medication resupply requests.
- Map medication name, dosage, frequency, quantity, notes, and status.
- Create `MedicationRequest` mapper.
- Identify future need for `Medication`, `MedicationDispense`, or related resources.
- Add tests for medication request mapping.

---

## Epic 4: WAH4PC Gateway Client and Outbound Requests

### Feature 4.1: Gateway client

#### US-016 — Build WAH4PC gateway client service
**Story points:** 8

As the backend, I want a dedicated gateway client so WAH4PC communication is isolated and testable.

**Tasks**
- Create gateway integration module/service.
- Support gateway base URL config.
- Add request helpers with typed inputs/outputs.
- Add safe timeout handling.
- Add mocked client tests.

#### US-017 — Submit FHIR request to gateway
**Story points:** 8

As the backend, I want to submit PH Core/FHIR requests to the gateway.

**Tasks**
- Support `POST /api/v1/fhir/request/{resourceType}`.
- Include `requesterId`, `targetId`, `patientIdentifiers`, reason, and notes.
- Add `X-API-Key` header.
- Add `Idempotency-Key` header.
- Handle gateway response and return transaction metadata.

#### US-018 — Support FHIR push to gateway when needed
**Story points:** 5

As the backend, I want to push unsolicited resources when the workflow requires it.

**Tasks**
- Support `POST /api/v1/fhir/push/{resourceType}`.
- Include `senderId`, `targetId`, resource, reason, and notes.
- Validate URL resource type matches payload resource type.
- Handle successful immediate completion.
- Add tests for push behavior.

### Feature 4.2: Reliability and error handling

#### US-019 — Add idempotency handling
**Story points:** 3

As the system, I want safe retries for gateway POST requests.

**Tasks**
- Generate UUID v4 idempotency keys.
- Persist keys with transaction records.
- Reuse the same key on retries.
- Handle `409 Conflict` and `429 Too Many Requests` correctly.

#### US-020 — Add gateway error handling and retry policy
**Story points:** 5

As the backend, I want predictable behavior when gateway calls fail.

**Tasks**
- Handle 400, 401, 403, 404, 409, 429, 500, and 502 responses.
- Return safe user-facing errors.
- Log transaction ID, provider ID, resource type, and status.
- Add retry guidance for retryable failures.
- Avoid retrying non-retryable validation/auth errors.

---

## Epic 5: Provider Webhooks and Inbound Gateway Processing

### Feature 5.1: Required provider endpoints

#### US-021 — Implement practitioner directory endpoint
**Story points:** 5

As the gateway, I need to fetch our active practitioner list.

**Tasks**
- Implement `/api/fhir/practitioners`.
- Validate `X-Gateway-Auth`.
- Return `{ code, display, active }` records.
- Support active/inactive practitioners.
- Add auth and response shape tests.

#### US-022 — Implement process-query webhook
**Story points:** 8

As a target provider system, we need to receive gateway requests from other providers.

**Tasks**
- Implement `/fhir/process-query`.
- Validate `X-Gateway-Auth`.
- Validate transactionId, requesterId, identifiers, resourceType, gatewayReturnUrl, reason, and notes.
- Acknowledge with 200 OK quickly.
- Defer processing to a service/queue boundary.
- Send `SUCCESS`, `REJECTED`, or `ERROR` back to `gatewayReturnUrl`.

#### US-023 — Implement receive-results webhook
**Story points:** 8

As a requester provider system, we need to receive requested records from the gateway.

**Tasks**
- Implement `/fhir/receive-results`.
- Validate `X-Gateway-Auth`.
- Verify transaction ID exists and belongs to this provider.
- Handle `SUCCESS` and `ERROR` statuses.
- Parse `Bundle.entry[]` safely for success payloads.
- Store received payload and update transaction state.

#### US-024 — Implement receive-push webhook
**Story points:** 5

As a provider system, we need to receive unsolicited pushed resources.

**Tasks**
- Implement `/fhir/receive-push`.
- Validate `X-Gateway-Auth`.
- Validate senderId, resourceType, resource, reason, and notes.
- Store inbound resource and transaction metadata.
- Return 200 OK after accepted receipt.

### Feature 5.2: Security and async processing

#### US-025 — Secure all gateway-originated endpoints
**Story points:** 5

As the system, I want to reject unauthorized webhook calls.

**Tasks**
- Validate `X-Gateway-Auth` on all gateway webhooks.
- Add rate limiting to webhook endpoints.
- Reject malformed payloads with safe responses.
- Avoid exposing secrets or raw sensitive identifiers in logs.
- Add negative auth tests.

#### US-026 — Add async processing boundary
**Story points:** 5

As the backend, I want webhook responses to be fast and processing to be reliable.

**Tasks**
- Keep webhook acknowledgement under gateway timeout expectations.
- Add service boundary for deferred processing.
- Prepare queue-ready interfaces for future Redis/RabbitMQ adoption.
- Track processing errors.
- Add tests for acknowledgement vs processing behavior.

---

## Epic 6: Transaction Tracking and Record Routing

### Feature 6.1: Transaction lifecycle

#### US-027 — Create sync transaction storage
**Story points:** 5

As the system, I want every gateway request and callback to be traceable.

**Tasks**
- Create transaction schema/table.
- Store requesterId, targetId, resourceType, patient profile ID, idempotency key, gateway transaction ID, status, metadata, and timestamps.
- Add repository/service methods.
- Add indexes for patient, provider, resource type, and status.
- Add migration tests or verification steps.

#### US-028 — Add sync status API
**Story points:** 5

As a patient, I want to see the status of my sync requests.

**Tasks**
- Add backend endpoint for patient sync history/status.
- Return pending, completed, rejected, failed, and retryable states.
- Include safe summary fields only.
- Add frontend API client method.
- Add tests for access control.

### Feature 6.2: Received record routing

#### US-029 — Route received FHIR resources into app sections
**Story points:** 8

As the system, I want returned records to appear in the correct app screens.

**Tasks**
- Route `Condition`/`Procedure` to Medical History.
- Route `Immunization` to Immunization Records.
- Route `Encounter` to Consultation History.
- Route `Observation` to Laboratory Results.
- Route medication resources to prescription/resupply history where applicable.
- Preserve raw FHIR payloads for audit/debugging.

#### US-030 — Add frontend sync status display
**Story points:** 5

As a patient, I want feedback when sync is pending, successful, or failed.

**Tasks**
- Add sync status display to health records/profile flow.
- Show selected provider and latest transaction state.
- Show actionable errors for incomplete profile or failed gateway calls.
- Add empty/loading/error states.
- Add UI tests where practical.

---

## Epic 7: Environment, Deployment, and Documentation

### Feature 7.1: Environment setup

#### US-031 — Add WAH4PC backend environment validation
**Story points:** 3

As an operator, I want missing gateway config to fail safely.

**Tasks**
- Add `WAH4PC_GATEWAY_BASE_URL`.
- Add `WAH4PC_API_KEY`.
- Add `WAH4PC_PROVIDER_ID`.
- Add `WAH4PC_GATEWAY_AUTH_KEY`.
- Add `PUBLIC_BASE_URL`.
- Add optional `WAH4PC_PRACTITIONER_LIST_ENDPOINT`.
- Extend env validation and tests.

#### US-032 — Document provider registration requirements
**Story points:** 3

As an implementer, I want clear setup instructions for WAH4PC provider registration.

**Tasks**
- Document public HTTPS base URL requirement.
- Document provider ID, API key, and gateway auth key.
- Document practitioner list endpoint.
- Document requester/target provider ID usage.
- Document local/staging/production setup differences.

### Feature 7.2: Mapping and rollout documentation

#### US-033 — Document PH Core field mappings
**Story points:** 3

As a developer, I want clear app-field to PH Core-resource mappings.

**Tasks**
- Document Patient mapping.
- Document health record mapping.
- Document appointment mapping.
- Document medication/resupply mapping.
- Document known schema gaps and assumptions.

#### US-034 — Prepare staged rollout plan
**Story points:** 3

As the team, we want to release sync safely in phases.

**Tasks**
- Phase 1: patient profile completion.
- Phase 2: provider discovery and sync readiness.
- Phase 3: PH Core mappers and gateway client.
- Phase 4: webhooks and transaction tracking.
- Phase 5: end-to-end record routing into app screens.

---

## Environment Requirements

### Frontend
- `BACKEND_BASE_URL`
- `BACKEND_API_KEY`

### Backend Existing
- `NODE_ENV`
- `PORT`
- `FRONTEND_ORIGIN`
- `BACKEND_API_KEY`
- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `SUPABASE_SECRET_KEY`
- Auth/security secrets already required by the backend

### Backend New for WAH4PC
- `WAH4PC_GATEWAY_BASE_URL`
- `WAH4PC_API_KEY`
- `WAH4PC_PROVIDER_ID`
- `WAH4PC_GATEWAY_AUTH_KEY`
- `PUBLIC_BASE_URL`
- Optional: `WAH4PC_PRACTITIONER_LIST_ENDPOINT`

---

## Resource Mapping Summary

| App area | PH Core/FHIR resource |
| --- | --- |
| Personal Information / Patient Profile | `Patient` |
| Medical History | `Condition`, `Procedure` |
| Immunization Records | `Immunization` |
| Consultation History | `Encounter` |
| Laboratory Results | `Observation`, optional `Bundle` |
| Onsite Consultation | `Encounter` |
| Teleconsultation | `Encounter` |
| Request Resupply | `MedicationRequest` |
| Prescription History | `MedicationRequest`, possible future `Medication`/`MedicationDispense` |

---

## Story Point Summary

| Epic | User Stories | Points |
| --- | ---: | ---: |
| Epic 1: PH Core Patient Identity and Profile Completion | 5 | 31 |
| Epic 2: Provider Discovery and Sync Preparation | 4 | 18 |
| Epic 3: PH Core Request Builder for App Data | 6 | 42 |
| Epic 4: WAH4PC Gateway Client and Outbound Requests | 5 | 29 |
| Epic 5: Provider Webhooks and Inbound Gateway Processing | 6 | 36 |
| Epic 6: Transaction Tracking and Record Routing | 4 | 23 |
| Epic 7: Environment, Deployment, and Documentation | 4 | 12 |
| **Total** | **34** | **191** |

---

## Rollout Notes
- Keep signup lightweight; do not require every PH Core field during account creation.
- Require profile completion before record sync.
- Keep WAH4PC integration inside the existing backend, but isolate it in dedicated modules/services.
- Preserve raw FHIR payloads for debugging/audit while exposing only safe summaries to patients.
- Treat gateway callbacks as asynchronous and validate all gateway-originated requests with `X-Gateway-Auth`.
