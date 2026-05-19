import { JwtService } from '@nestjs/jwt';
import { AuthSettingsService } from './auth-settings.service';
import { AuthSupportService } from './auth-support.service';
import { SupabaseService } from '../supabase/supabase.service';

describe('AuthSupportService auth user lookup', () => {
  const createService = (
    listUsersMock: jest.Mock,
    getUserMock: jest.Mock = jest.fn().mockResolvedValue({
      data: { user: null },
      error: null,
    }),
    decodeMock: jest.Mock = jest.fn(),
  ) => {
    const supabaseService = {
      authClient: {
        auth: {
          getUser: getUserMock,
        },
      },
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

    const jwtService = {
      decode: decodeMock,
    } as unknown as JwtService;

    return new AuthSupportService(settings, jwtService, supabaseService);
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

  it('falls back to the signed JWT payload when Supabase rejects an expired access token', async () => {
    const getUserMock = jest.fn().mockResolvedValue({
      data: { user: null },
      error: { message: 'JWT expired' },
    });
    const decodeMock = jest.fn().mockReturnValue({
      sub: 'user-123',
      email: 'patient@example.com',
    });

    const service = createService(jest.fn(), getUserMock, decodeMock);

    await expect(
      service.getAuthenticatedUserFromAccessToken('expired-token'),
    ).resolves.toEqual({
      id: 'user-123',
      email: 'patient@example.com',
    });
    expect(getUserMock).toHaveBeenCalledWith('expired-token');
    expect(decodeMock).toHaveBeenCalledWith('expired-token');
  });
});
