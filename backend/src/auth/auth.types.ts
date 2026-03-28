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
