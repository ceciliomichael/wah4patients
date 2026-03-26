# WAH4P Backend (NestJS)

Secure NestJS API for WAH for Patients registration and login flow, backed by Supabase and Resend.

## Features

- Global API-key guard (`x-api-key`) for all non-public routes
- Rate limiting with `@nestjs/throttler`
- OTP registration flow via Resend email delivery
- Account creation and login through Supabase Auth
- SQL bootstrap script for OTP + profile tables (`../sqls/001_auth_setup.sql`)

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
```

4. Start backend:

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

## Testing and Build

```bash
npm run build
npm run test
npm run test:e2e
```
