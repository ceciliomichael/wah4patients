## 2FA (TOTP) Implementation Guide

This project implements Google Authenticator-compatible 2FA as a **second factor on top of password login**, not as a replacement for registration and password-reset OTP flows.

Google Authenticator uses RFC 6238 TOTP, so there is no Google SDK requirement.

## Scope and Existing Auth Flows

- Keep existing email OTP registration flow unchanged.
- Keep existing email OTP password reset flow unchanged.
- Add a TOTP challenge only after successful email/password login when user has 2FA enabled.

## Security Rules (Non-Negotiable)

1. **Verify TOTP only on backend** (NestJS). Never trust client-side code validation.
2. Never persist active TOTP secret in Flutter local storage.
3. Store recovery codes as one-way hashes only.
4. Use short-lived login challenge token before final JWT/session issuance.
5. Add brute-force protection and attempt limits for setup verify and login challenge verify.
6. Use a +/-1 time-step drift window (30 second step) when validating codes.

## Backend Dependencies (Node/NestJS)

Use a server-side TOTP library in backend (example: `otplib`).

Recommended install in `backend`:

```bash
npm install otplib
```

TOTP secrets are encrypted in backend before database storage using Node crypto AES-256-GCM and `TOTP_SECRET_ENCRYPTION_KEY`.

## Flutter Dependencies

Flutter only needs QR rendering for setup UI.

```yaml
dependencies:
  flutter:
    sdk: flutter
  qr_flutter: ^4.1.0
```

Do not add client-side `otp` verification as authoritative auth logic.

## Data Model (Implemented via SQL migration)

See migration: `sqls/003_totp_2fa_setup.sql`

Tables:

- `public.user_totp_factors`
  - One row per user
  - Stores enabled state + active secret + temporary setup secret
- `public.user_totp_recovery_codes`
  - Multiple rows per user
  - Stores hashed one-time backup codes

This separation avoids exposing sensitive 2FA material through existing profile queries.

## Required Backend Environment Variables

Add these values in `backend/.env`:

- `MFA_CHALLENGE_TOKEN_SECRET`
- `MFA_CHALLENGE_TOKEN_TTL_SECONDS`
- `TOTP_ISSUER`
- `TOTP_RECOVERY_CODES_COUNT`
- `TOTP_SECRET_ENCRYPTION_KEY`

See `backend/.env.example` for exact descriptions.

## API Design

### 1) Start 2FA setup (authenticated)

`POST /auth/2fa/setup/start`

Behavior:

- Generate new temporary Base32 secret (20 random bytes minimum).
- Persist to `user_totp_factors.totp_secret_temp_ciphertext`.
- Build otpauth URI:

`otpauth://totp/{Issuer}:{Account}?secret={Secret}&issuer={Issuer}&algorithm=SHA1&digits=6&period=30`

- Return:
  - `otpauthUrl`
  - `manualEntryKey` (same secret for manual typing)

### 2) Verify setup and enable 2FA (authenticated)

`POST /auth/2fa/setup/verify`

Request:

```json
{
  "code": "123456"
}
```

Behavior:

- Validate code against temporary secret with allowed drift window.
- On success:
  - promote temp secret to active (`totp_secret_ciphertext`)
  - clear temp secret
  - set enabled=true and `enabled_at`
  - generate backup codes
  - save only hashes in `user_totp_recovery_codes`
- Return plaintext backup codes **once** in response.

### 3) Login step 1 (existing endpoint with conditional response)

`POST /auth/login`

Behavior:

- If email/password invalid: reject as today.
- If valid and 2FA disabled: return normal login response.
- If valid and 2FA enabled:
  - do not issue final auth token yet
  - return `mfaRequired=true` and short-lived `mfaChallengeToken`.

### 4) Login step 2 verify TOTP

`POST /auth/2fa/challenge/verify`

Request:

```json
{
  "mfaChallengeToken": "...",
  "code": "123456"
}
```

Behavior:

- Validate challenge token and code against active secret.
- If valid, issue normal auth tokens/session.

### 5) Optional backup code login fallback

`POST /auth/2fa/challenge/verify-backup-code`

Behavior:

- Hash incoming code and compare to unused stored hashes.
- Mark matching code `used_at` in a transaction.
- Issue normal auth tokens/session.

### 6) Disable 2FA (authenticated)

`POST /auth/2fa/disable`

Require:

- Password re-check + valid TOTP (or valid backup code).

Behavior:

- Clear active/temp secrets.
- Set enabled=false.
- Invalidate/clear recovery codes.

## Flutter UX Integration

### Sign-up opt-in flow (implemented)

1. In registration step 3 (password screen), user can check:
  - "Set up Google Authenticator right after sign in"
2. After account creation, app routes user to sign in with this intent.
3. After successful first sign-in, app opens TOTP setup flow immediately.

### Setup screen

1. Call `POST /auth/2fa/setup/start`.
2. Render QR with `QrImageView(data: otpauthUrl)`.
3. Use existing segmented field (`OtpCodeField`) for 6-digit entry.
4. Submit to `POST /auth/2fa/setup/verify`.
5. Show backup codes once with explicit "save now" warning.

### Security settings screen (implemented)

1. Profile contains a Security section.
2. Security screen provides:
  - Start 2FA setup
  - Disable 2FA (requires current password and current authenticator code)

### Login challenge screen

1. Submit email/password to existing login endpoint.
2. If `mfaRequired=true`, route to TOTP challenge screen.
3. Submit 6-digit code + `mfaChallengeToken`.
4. Continue login bootstrap only after challenge verification succeeds.

### Session behavior

- Frontend uses in-memory auth session state for authenticated 2FA setup/disable requests.
- Sign out clears this session state.

## Validation and Error Handling

- Reject non-6-digit code format early in DTO validation.
- Return generic auth failure messages (avoid leaking whether password or code failed).
- Add per-endpoint throttling for setup verify and challenge verify.
- Track failed attempts and surface lockout message when threshold reached.

## Time and Clock Drift

- TOTP period: 30 seconds.
- Validation window: current step plus/minus one step.
- If repeated failures occur, return hint to check device time sync.

## Recovery Codes

- Generate high-entropy backup codes (for example 8 to 10 codes).
- Show only once at creation/regeneration.
- Hash before persistence.
- One-time use per code.
- Provide endpoint to regenerate codes (requires strong re-auth).

## Testing Checklist

### Backend tests

- Setup start creates temp secret and returns valid otpauth URI.
- Setup verify enables factor only with valid code.
- Login returns `mfaRequired` for 2FA-enabled users.
- Challenge verify issues tokens only with valid code/challenge.
- Backup code success consumes code once; second use fails.
- Rate limits and failed-attempt behavior work as expected.

### Flutter tests

- Setup screen renders QR and handles code submission errors.
- Login challenge route appears only when `mfaRequired=true`.
- Successful challenge continues login path.

## Summary

This implementation keeps current OTP features intact and adds production-grade TOTP as a second factor at login, including sign-up opt-in setup, profile security management, secure secret handling, backup codes, and clear migration-backed data boundaries.