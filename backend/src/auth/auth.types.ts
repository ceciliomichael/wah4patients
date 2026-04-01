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
  purpose: 'registration';
  iat: number;
  exp: number;
}

export interface PatientProfileResponse {
  givenNames: string[];
  familyName: string;
  displayName: string;
}

export interface PasswordResetTokenPayload {
  sub: string;
  purpose: 'password-reset';
  iat: number;
  exp: number;
}

export interface MfaChallengeTokenPayload {
  sub: string;
  purpose: 'mfa-challenge';
  email: string;
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: string;
  iat: number;
  exp: number;
}

export interface SecurityVerificationTokenPayload {
  sub: string;
  purpose: 'security-verification';
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
  mpinHash: string;
  failedAttempts: number;
  lockedUntil: string | null;
  lastVerifiedAt: string | null;
}

export interface UserMpinUpsert {
  userId: string;
  mpinHash: string;
  failedAttempts: number;
  lockedUntil: string | null;
  lastVerifiedAt: string | null;
}

export interface UserMpinDeviceRecord {
  userId: string;
  deviceId: string;
  registeredAt: string;
}

export interface UserMpinDeviceUpsert {
  userId: string;
  deviceId: string;
  registeredAt?: string | null;
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

export interface SecuritySettingsStatusResponse {
  isTotpEnabled: boolean;
  isMpinConfigured: boolean;
  isMpinDeviceRegistered: boolean;
}

export interface VerifySecurityActionResponse {
  message: string;
  securityVerificationToken: string;
  expiresInSeconds: number;
}

export interface CompletePasswordResetResponse {
  message: string;
}

export interface CompleteRegistrationResponse {
  message: string;
  userId: string;
  email: string;
  profile: PatientProfileResponse;
}

export interface LoginResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: string;
  user: {
    id: string;
    email: string;
    profile: PatientProfileResponse;
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

export interface RefreshSessionResponse extends LoginResponse {}

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

export interface RegisterMpinDeviceResponse {
  message: string;
}

export interface UnregisterMpinDeviceResponse {
  message: string;
}

export interface VerifyMpinResponse {
  message: string;
  remainingAttempts: number;
  lockedUntil: string | null;
}
