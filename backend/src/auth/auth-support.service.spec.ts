import { JwtService } from '@nestjs/jwt';
import { AuthSettingsService } from './auth-settings.service';
import { AuthSupportService } from './auth-support.service';
import { SupabaseService } from '../supabase/supabase.service';

describe('AuthSupportService auth user lookup', () => {
  const createService = (listUsersMock: jest.Mock) => {
    const supabaseService = {
      adminClient: {
        auth: {
          admin: {
            listUsers: listUsersMock,
          },
        },
      },
    } as unknown as jest.Mocked<SupabaseService>;

    const settings = {
      otpHashSecret: 'otp-hash-secret',
      registrationTokenSecret: 'registration-token-secret',
      passwordResetTokenSecret: 'password-reset-token-secret',
      mfaChallengeTokenSecret: 'mfa-challenge-token-secret',
      securityVerificationTokenSecret: 'security-verification-token-secret',
      totpSecretEncryptionKey: 'totp-secret-encryption-key',
    } as AuthSettingsService;

    return new AuthSupportService(settings, new JwtService(), supabaseService);
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('finds an auth user by email across paginated results', async () => {
    const firstPageUsers = Array.from({ length: 100 }, (_, index) => ({
      id: `user-${index + 1}`,
      email: `user-${index + 1}@example.com`,
    }));
    const listUsersMock = jest
      .fn()
      .mockResolvedValueOnce({
        data: {
          users: firstPageUsers,
        },
        error: null,
      })
      .mockResolvedValueOnce({
        data: {
          users: [{ id: 'user-2', email: 'juan@example.com' }],
        },
        error: null,
      });

    const service = createService(listUsersMock);

    await expect(service.findAuthUserIdByEmail('Juan@Example.com')).resolves.toBe(
      'user-2',
    );
    expect(listUsersMock).toHaveBeenCalledTimes(2);
  });

  it('returns null when no auth user matches the email', async () => {
    const listUsersMock = jest.fn().mockResolvedValue({
      data: {
        users: [{ id: 'user-1', email: 'someone@example.com' }],
      },
      error: null,
    });

    const service = createService(listUsersMock);

    await expect(service.findAuthUserIdByEmail('missing@example.com')).resolves.toBeNull();
  });
});
