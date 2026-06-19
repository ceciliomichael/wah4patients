# WAH4P Backend (NestJS)

Secure NestJS API for WAH for Patients registration and login flow, backed by Supabase and Resend.

## Features

- Global API-key guard (`x-api-key`) for all non-public routes

- OTP registration flow via Resend email delivery
- Account creation and login through Supabase Auth
- WAH4PC interoperability proxy for provider discovery and sync-readiness checks
- SQL bootstrap script for OTP + profile tables (`../sqls/001_auth_setup.sql`)
- SQL bootstrap script for Personal Records tables (`../sqls/006_personal_records_setup.sql`)
- SQL bootstrap script for Appointment History tables (`../sqls/009_appointment_history_setup.sql`)
- SQL bootstrap script for patient identifier matching (`../sqls/010_patient_identifiers_setup.sql`)

## Setup

1. Install dependencies:

```bash
npm install
```

2. Copy env template and fill secrets:

```bash
cp .env.example .env
```

3. Run SQL bootstrap in your Supabase SQL editor:

```text
../sqls/001_auth_setup.sql
../sqls/006_personal_records_setup.sql
../sqls/009_appointment_history_setup.sql
../sqls/010_patient_identifiers_setup.sql
```

4. Configure the WAH4PC gateway env vars:

```text
WAH4PC_GATEWAY_URL=https://wah4pc.echosphere.cfd
WAH4PC_API_KEY=...
WAH4PC_PROVIDER_ID=...
WAH4PC_GATEWAY_AUTH_KEY=...
```

5. Start backend:

```bash
npm run start:dev
```

Base URL: `http://localhost:3000/api/v1`

## Auth Endpoints

All endpoints below require `x-api-key` header except `/health`.

- `GET /api/v1/health`
- `POST /api/v1/auth/register/request-otp`
- `POST /api/v1/auth/register/resend-otp`
- `POST /api/v1/auth/register/verify-otp`
- `POST /api/v1/auth/register/complete`
- `POST /api/v1/auth/login`

## Interoperability Endpoints

- `GET /api/v1/interoperability/providers`
- `POST /api/v1/interoperability/sync/prepare`
- `POST /fhir/process-query`
- `POST /fhir/receive-results`
- `POST /fhir/receive-push`

## Testing and Build

```bash
npm run build
npm run test
npm run test:e2e
```
