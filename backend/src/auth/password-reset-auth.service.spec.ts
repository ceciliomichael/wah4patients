import { ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { MailerService } from '../mailer/mailer.service';
import { SupabaseService } from '../supabase/supabase.service';
import { AuthSettingsService } from './auth-settings.service';
import { AuthSupportService } from './auth-support.service';
import { PasswordHistoryService } from './password-history.service';
import { PasswordResetOtpRepository } from './password-reset-otp.repository';
import { PasswordResetAuthService } from './password-reset-auth.service';

describe('PasswordResetAuthService', () => {
  const createSupportMock = () => {
    return {
      normalizeEmail: jest.fn((email: string) => email.trim().toLowerCase()),
      findProfileIdByEmail: jest.fn(),
      isPasswordStrong: jest.fn(),
      verifyPasswordResetToken: jest.fn(),
    } as unknown as jest.Mocked<AuthSupportService>;
  };

  const buildVerifiedRecord = () => ({
    email: 'juan@example.com',
    codeHash: 'code-hash',
    expiresAt: '2099-01-01T00:00:00.000Z',
    failedAttempts: 0,
    lastSentAt: '2025-01-01T00:00:00.000Z',
    verifiedAt: '2025-01-01T00:01:00.000Z',
    createdAt: '2025-01-01T00:00:00.000Z',
    updatedAt: '2025-01-01T00:00:00.000Z',
  });

  const createService = (overrides: {
    support?: jest.Mocked<AuthSupportService>;
    passwordHistoryService?: jest.Mocked<PasswordHistoryService>;
    passwordResetOtpRepository?: jest.Mocked<PasswordResetOtpRepository>;
    supabaseService?: jest.Mocked<SupabaseService>;
    settings?: Partial<AuthSettingsService>;
  } = {}): PasswordResetAuthService => {
    const support = overrides.support ?? createSupportMock();
    const passwordHistoryService =
      overrides.passwordHistoryService ??
      ({
        assertPasswordNotReused: jest.fn(),
        createPasswordEntry: jest.fn(),
        deletePasswordEntry: jest.fn(),
      } as unknown as jest.Mocked<PasswordHistoryService>);
    const passwordResetOtpRepository =
      overrides.passwordResetOtpRepository ??
      ({
        findByEmail: jest.fn(),
        upsert: jest.fn(),
        incrementFailedAttempts: jest.fn(),
        markVerified: jest.fn(),
        deleteByEmail: jest.fn(),
      } as unknown as jest.Mocked<PasswordResetOtpRepository>);
    const supabaseService =
      overrides.supabaseService ??
      ({
        adminClient: {
          auth: {
            admin: {
              updateUserById: jest.fn(),
            },
          },
        },
      } as unknown as jest.Mocked<SupabaseService>);
    const settings = Object.assign(
      {
        otpResendCooldownSeconds: 45,
        otpTtlMinutes: 10,
        otpMaxAttempts: 5,
        passwordResetTokenSecret: 'password-reset-token-secret',
        passwordResetTokenTtlSeconds: 900,
      },
      overrides.settings ?? {},
    ) as AuthSettingsService;

    return new PasswordResetAuthService(
      new JwtService(),
      ({ sendPasswordResetOtpEmail: jest.fn() } as unknown as MailerService),
      supabaseService,
      passwordResetOtpRepository,
      settings,
      support,
      passwordHistoryService,
    );
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('rejects a reused password before updating the account', async () => {
    const support = createSupportMock();
    const passwordHistoryService = {
      assertPasswordNotReused: jest.fn().mockRejectedValue(
        new ConflictException('You cannot reuse a previous password'),
      ),
      createPasswordEntry: jest.fn(),
      deletePasswordEntry: jest.fn(),
    } as unknown as jest.Mocked<PasswordHistoryService>;
    const passwordResetOtpRepository = {
      findByEmail: jest.fn().mockResolvedValue(buildVerifiedRecord()),
      upsert: jest.fn(),
      incrementFailedAttempts: jest.fn(),
      markVerified: jest.fn(),
      deleteByEmail: jest.fn(),
    } as unknown as jest.Mocked<PasswordResetOtpRepository>;
    const supabaseService = {
      adminClient: {
        auth: {
          admin: {
            updateUserById: jest.fn(),
          },
        },
      },
    } as unknown as jest.Mocked<SupabaseService>;

    support.normalizeEmail.mockReturnValue('juan@example.com');
    support.isPasswordStrong.mockReturnValue(true);
    support.verifyPasswordResetToken.mockResolvedValue({
      sub: 'juan@example.com',
      purpose: 'password-reset',
    } as never);
    support.findProfileIdByEmail.mockResolvedValue('user-1');

    const service = createService({
      support,
      passwordHistoryService,
      passwordResetOtpRepository,
      supabaseService,
    });

    await expect(
      service.completePasswordReset({
        email: 'juan@example.com',
        password: 'Password1!',
        passwordResetToken: 'reset-token',
      } as never),
    ).rejects.toBeInstanceOf(ConflictException);

    expect(
      supabaseService.adminClient.auth.admin.updateUserById,
    ).not.toHaveBeenCalled();
  });

  it('stores the new password in history after a successful reset', async () => {
    const support = createSupportMock();
    const passwordHistoryService = {
      assertPasswordNotReused: jest.fn().mockResolvedValue(undefined),
      createPasswordEntry: jest.fn().mockResolvedValue({
        id: 'history-1',
        user_id: 'user-1',
        password_hash: 'hashed-password',
        created_at: '2025-01-01T00:00:00.000Z',
        updated_at: '2025-01-01T00:00:00.000Z',
      }),
      deletePasswordEntry: jest.fn(),
    } as unknown as jest.Mocked<PasswordHistoryService>;
    const passwordResetOtpRepository = {
      findByEmail: jest.fn().mockResolvedValue(buildVerifiedRecord()),
      upsert: jest.fn(),
      incrementFailedAttempts: jest.fn(),
      markVerified: jest.fn(),
      deleteByEmail: jest.fn(),
    } as unknown as jest.Mocked<PasswordResetOtpRepository>;
    const updateUserById = jest.fn().mockResolvedValue({ error: null });
    const supabaseService = {
      adminClient: {
        auth: {
          admin: {
            updateUserById,
          },
        },
      },
    } as unknown as jest.Mocked<SupabaseService>;

    support.normalizeEmail.mockReturnValue('juan@example.com');
    support.isPasswordStrong.mockReturnValue(true);
    support.verifyPasswordResetToken.mockResolvedValue({
      sub: 'juan@example.com',
      purpose: 'password-reset',
    } as never);
    support.findProfileIdByEmail.mockResolvedValue('user-1');

    const service = createService({
      support,
      passwordHistoryService,
      passwordResetOtpRepository,
      supabaseService,
    });

    await service.completePasswordReset({
      email: 'juan@example.com',
      password: 'Password1!',
      passwordResetToken: 'reset-token',
    } as never);

    expect(passwordHistoryService.assertPasswordNotReused).toHaveBeenCalledWith(
      'user-1',
      'Password1!',
    );
    expect(passwordHistoryService.createPasswordEntry).toHaveBeenCalledWith(
      'user-1',
      'Password1!',
    );
    expect(updateUserById).toHaveBeenCalledWith('user-1', {
      password: 'Password1!',
    });
  });

  it('removes the pending history entry when the auth password update fails', async () => {
    const support = createSupportMock();
    const passwordHistoryService = {
      assertPasswordNotReused: jest.fn().mockResolvedValue(undefined),
      createPasswordEntry: jest.fn().mockResolvedValue({
        id: 'history-1',
        user_id: 'user-1',
        password_hash: 'hashed-password',
        created_at: '2025-01-01T00:00:00.000Z',
        updated_at: '2025-01-01T00:00:00.000Z',
      }),
      deletePasswordEntry: jest.fn().mockResolvedValue(undefined),
    } as unknown as jest.Mocked<PasswordHistoryService>;
    const passwordResetOtpRepository = {
      findByEmail: jest.fn().mockResolvedValue(buildVerifiedRecord()),
      upsert: jest.fn(),
      incrementFailedAttempts: jest.fn(),
      markVerified: jest.fn(),
      deleteByEmail: jest.fn(),
    } as unknown as jest.Mocked<PasswordResetOtpRepository>;
    const updateUserById = jest.fn().mockResolvedValue({
      error: { message: 'Temporary failure' },
    });
    const supabaseService = {
      adminClient: {
        auth: {
          admin: {
            updateUserById,
          },
        },
      },
    } as unknown as jest.Mocked<SupabaseService>;

    support.normalizeEmail.mockReturnValue('juan@example.com');
    support.isPasswordStrong.mockReturnValue(true);
    support.verifyPasswordResetToken.mockResolvedValue({
      sub: 'juan@example.com',
      purpose: 'password-reset',
    } as never);
    support.findProfileIdByEmail.mockResolvedValue('user-1');

    const service = createService({
      support,
      passwordHistoryService,
      passwordResetOtpRepository,
      supabaseService,
    });

    await expect(
      service.completePasswordReset({
        email: 'juan@example.com',
        password: 'Password1!',
        passwordResetToken: 'reset-token',
      } as never),
    ).rejects.toThrow();

    expect(passwordHistoryService.deletePasswordEntry).toHaveBeenCalledWith(
      'history-1',
    );
  });
});
