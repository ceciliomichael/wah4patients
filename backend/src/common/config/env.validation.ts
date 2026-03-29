import Joi from "joi";

export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid("development", "test", "production")
    .default("development"),
  PORT: Joi.number().integer().min(1).max(65535).default(3000),
  FRONTEND_ORIGIN: Joi.string().trim().required(),
  BACKEND_API_KEY: Joi.string().trim().min(24).required(),
  SUPABASE_URL: Joi.string().uri().required(),
  SUPABASE_PUBLISHABLE_KEY: Joi.string().trim().min(20),
  SUPABASE_SECRET_KEY: Joi.string().trim().min(20),
  RESEND_API_KEY: Joi.string().trim().pattern(/^re_/).required(),
  RESEND_FROM_EMAIL: Joi.string()
    .email({ tlds: { allow: false } })
    .required(),
  OTP_TTL_MINUTES: Joi.number().integer().min(5).max(30).default(10),
  OTP_RESEND_COOLDOWN_SECONDS: Joi.number()
    .integer()
    .min(15)
    .max(180)
    .default(45),
  OTP_MAX_ATTEMPTS: Joi.number().integer().min(3).max(10).default(5),
  OTP_HASH_SECRET: Joi.string().trim().min(32).required(),
  REGISTRATION_TOKEN_SECRET: Joi.string().trim().min(32).required(),
  REGISTRATION_TOKEN_TTL_SECONDS: Joi.number()
    .integer()
    .min(300)
    .max(3600)
    .default(900),
  PASSWORD_RESET_TOKEN_SECRET: Joi.string().trim().min(32).required(),
  PASSWORD_RESET_TOKEN_TTL_SECONDS: Joi.number()
    .integer()
    .min(300)
    .max(3600)
    .default(900),
  MFA_CHALLENGE_TOKEN_SECRET: Joi.string().trim().min(32).required(),
  MFA_CHALLENGE_TOKEN_TTL_SECONDS: Joi.number()
    .integer()
    .min(60)
    .max(600)
    .default(180),
  TOTP_ISSUER: Joi.string().trim().min(2).max(64).default("WAH4P"),
  TOTP_RECOVERY_CODES_COUNT: Joi.number().integer().min(6).max(20).default(8),
  TOTP_SECRET_ENCRYPTION_KEY: Joi.string().trim().min(32).required(),
});
