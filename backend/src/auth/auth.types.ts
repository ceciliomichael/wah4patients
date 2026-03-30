export interface RegistrationOtpRecord {
  email: string;
  codeHash: string;
  expiresAt: string;
  failedAttempts: number;
  lastSentAt: string;
  verifiedAt: string | null;
}

export interface RegistrationOtpUpsert {
  email: string;
  codeHash: string;
  expiresAt: string;
  failedAttempts: number;
  lastSentAt: string;
  verifiedAt: string | null;
}

export interface PasswordResetOtpRecord {
  email: string;
  codeHash: string;
  expiresAt: string;
  failedAttempts: number;
  lastSentAt: string;
  verifiedAt: string | null;
}

export interface PasswordResetOtpUpsert {
  email: string;
  codeHash: string;
  expiresAt: string;
  failedAttempts: number;
  lastSentAt: string;
  verifiedAt: string | null;
}

export interface RegistrationTokenPayload {
  sub: string;
  purpose: "registration";
  iat: number;
  exp: number;
}

export interface PasswordResetTokenPayload {
  sub: string;
  purpose: "password-reset";
  iat: number;
  exp: number;
}

export interface MfaChallengeTokenPayload {
  sub: string;
  purpose: "mfa-challenge";
  email: string;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: string;
  iat: number;
  exp: number;
}

export interface UserTotpFactorRecord {
  userId: string;
  isEnabled: boolean;
  totpSecretCiphertext: string | null;
  totpSecretTempCiphertext: string | null;
  enabledAt: string | null;
}

export interface UserTotpFactorUpsert {
  userId: string;
  isEnabled?: boolean;
  totpSecretCiphertext?: string | null;
  totpSecretTempCiphertext?: string | null;
  enabledAt?: string | null;
}

export interface UserTotpRecoveryCodeRecord {
  id: string;
  userId: string;
  codeHash: string;
  usedAt: string | null;
}

export interface UserMpinRecord {
  userId: string;
  deviceId: string;
  mpinHash: string;
  failedAttempts: number;
  lockedUntil: string | null;
  lastVerifiedAt: string | null;
}

export interface UserMpinUpsert {
  userId: string;
  deviceId: string;
  mpinHash: string;
  failedAttempts: number;
  lockedUntil: string | null;
  lastVerifiedAt: string | null;
}

export interface RequestOtpResponse {
  message: string;
  cooldownSeconds: number;
}

export interface VerifyOtpResponse {
  message: string;
  registrationToken: string;
  expiresInSeconds: number;
}

export interface RequestPasswordResetOtpResponse {
  message: string;
  cooldownSeconds: number;
}

export interface VerifyPasswordResetOtpResponse {
  message: string;
  passwordResetToken: string;
  expiresInSeconds: number;
}

export interface CompletePasswordResetResponse {
  message: string;
}

export interface CompleteRegistrationResponse {
  message: string;
  userId: string;
  email: string;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: string;
  user: {
    id: string;
    email: string;
  };
}

export interface LoginMfaRequiredResponse {
  mfaRequired: true;
  mfaChallengeToken: string;
  expiresInSeconds: number;
  user: {
    id: string;
    email: string;
  };
}

export type LoginResultResponse = LoginResponse | LoginMfaRequiredResponse;

export interface TotpSetupStartResponse {
  otpauthUrl: string;
  manualEntryKey: string;
}

export interface TotpSetupVerifyResponse {
  message: string;
  recoveryCodes: string[];
}

export interface SetMpinResponse {
  message: string;
}

export interface VerifyMpinResponse {
  message: string;
  remainingAttempts: number;
  lockedUntil: string | null;
}
