import { ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { MailerService } from '../mailer/mailer.service';
import { SupabaseService } from '../supabase/supabase.service';
import { AuthSettingsService } from './auth-settings.service';
import { AuthSupportService } from './auth-support.service';
import { PasswordHistoryService } from './password-history.service';
import { ProfileService } from './profile.service';
import { RegistrationOtpRepository } from './registration-otp.repository';
import { RegistrationAuthService } from './registration-auth.service';

describe('RegistrationAuthService', () => {
  const createSupportMock = () => {
    return {
      normalizeEmail: jest.fn((email: string) => email.trim().toLowerCase()),
      findAuthUserIdByEmail: jest.fn(),
      isPasswordStrong: jest.fn(),
      verifyRegistrationToken: jest.fn(),
      isSupabaseDuplicateUserError: jest.fn(),
    } as unknown as jest.Mocked<AuthSupportService>;
  };

  const createService = (overrides: {
    support?: jest.Mocked<AuthSupportService>;
    registrationOtpRepository?: jest.Mocked<RegistrationOtpRepository>;
    mailerService?: jest.Mocked<MailerService>;
    supabaseService?: jest.Mocked<SupabaseService>;
    profileService?: jest.Mocked<ProfileService>;
    passwordHistoryService?: jest.Mocked<PasswordHistoryService>;
    settings?: Partial<AuthSettingsService>;
  } = {}): RegistrationAuthService => {
    const support = overrides.support ?? createSupportMock();
    const registrationOtpRepository =
      overrides.registrationOtpRepository ??
      ({
        findByEmail: jest.fn(),
        upsert: jest.fn(),
        incrementFailedAttempts: jest.fn(),
        markVerified: jest.fn(),
        deleteByEmail: jest.fn(),
      } as unknown as jest.Mocked<RegistrationOtpRepository>);
    const mailerService =
      overrides.mailerService ??
      ({
        sendRegistrationOtpEmail: jest.fn(),
      } as unknown as jest.Mocked<MailerService>);
    const supabaseService =
      overrides.supabaseService ??
      ({
        adminClient: {
          auth: {
            admin: {
              createUser: jest.fn(),
              deleteUser: jest.fn(),
            },
          },
        },
      } as unknown as jest.Mocked<SupabaseService>);
    const profileService =
      overrides.profileService ??
      ({
        saveRegistrationProfile: jest.fn(),
      } as unknown as jest.Mocked<ProfileService>);
    const passwordHistoryService =
      overrides.passwordHistoryService ??
      ({
        createPasswordEntry: jest.fn(),
      } as unknown as jest.Mocked<PasswordHistoryService>);
    const settings = Object.assign(
      {
        otpResendCooldownSeconds: 45,
        otpTtlMinutes: 10,
        otpMaxAttempts: 5,
        registrationTokenSecret: 'registration-token-secret',
        registrationTokenTtlSeconds: 900,
      },
      overrides.settings ?? {},
    ) as AuthSettingsService;

    return new RegistrationAuthService(
      new JwtService(),
      mailerService,
      supabaseService,
      registrationOtpRepository,
      profileService,
      settings,
      support,
      passwordHistoryService,
    );
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('blocks registration when the email is already tied to another account', async () => {
    const support = createSupportMock();
    const registrationOtpRepository = {
      findByEmail: jest.fn(),
      upsert: jest.fn(),
      incrementFailedAttempts: jest.fn(),
      markVerified: jest.fn(),
      deleteByEmail: jest.fn(),
    } as unknown as jest.Mocked<RegistrationOtpRepository>;
    const mailerService = {
      sendRegistrationOtpEmail: jest.fn(),
    } as unknown as jest.Mocked<MailerService>;
    const supabaseService = {
      adminClient: {
        auth: {
          admin: {
            createUser: jest.fn(),
            deleteUser: jest.fn(),
          },
        },
      },
    } as unknown as jest.Mocked<SupabaseService>;
    const profileService = {
      saveRegistrationProfile: jest.fn(),
    } as unknown as jest.Mocked<ProfileService>;
    const passwordHistoryService = {
      createPasswordEntry: jest.fn(),
    } as unknown as jest.Mocked<PasswordHistoryService>;

    support.normalizeEmail.mockReturnValue('juan@example.com');
    support.findAuthUserIdByEmail.mockResolvedValue('user-1');

    const service = createService({
      support,
      registrationOtpRepository,
      mailerService,
      supabaseService,
      profileService,
      passwordHistoryService,
    });

    await expect(
      service.requestRegistrationOtp({ email: 'Juan@Example.com' } as never),
    ).rejects.toBeInstanceOf(ConflictException);

    expect(registrationOtpRepository.findByEmail).not.toHaveBeenCalled();
    expect(mailerService.sendRegistrationOtpEmail).not.toHaveBeenCalled();
  });

  it('records the initial password after successful registration', async () => {
    const support = createSupportMock();
    const registrationOtpRepository = {
      findByEmail: jest.fn(),
      upsert: jest.fn(),
      incrementFailedAttempts: jest.fn(),
      markVerified: jest.fn(),
      deleteByEmail: jest.fn(),
    } as unknown as jest.Mocked<RegistrationOtpRepository>;
    const mailerService = {
      sendRegistrationOtpEmail: jest.fn(),
    } as unknown as jest.Mocked<MailerService>;
    const supabaseService = {
      adminClient: {
        auth: {
          admin: {
            createUser: jest.fn().mockResolvedValue({
              data: {
                user: {
                  id: 'user-1',
                },
              },
              error: null,
            }),
            deleteUser: jest.fn(),
          },
        },
      },
    } as unknown as jest.Mocked<SupabaseService>;
    const profileService = {
      saveRegistrationProfile: jest.fn().mockResolvedValue({
        givenNames: ['Juan'],
        familyName: 'Dela Cruz',
        displayName: 'Juan Dela Cruz',
        birthDate: '',
        gender: '',
        phoneNumber: '',
        communicationLanguage: '',
        philHealthId: '',
        philSysId: '',
        addressLine1: '',
        addressLine2: '',
        city: '',
        province: '',
        postalCode: '',
        country: '',
        maritalStatus: '',
        nationality: '',
        religion: '',
        occupation: '',
        genderIdentity: '',
        emergencyContactName: '',
        emergencyContactPhone: '',
        isSyncLocked: false,
        isComplete: false,
        missingFields: [],
      }),
    } as unknown as jest.Mocked<ProfileService>;
    const passwordHistoryService = {
      createPasswordEntry: jest.fn().mockResolvedValue({
        id: 'history-1',
        user_id: 'user-1',
        password_hash: 'hashed-password',
        created_at: '2025-01-01T00:00:00.000Z',
        updated_at: '2025-01-01T00:00:00.000Z',
      }),
    } as unknown as jest.Mocked<PasswordHistoryService>;
    const settings = Object.assign(
      {
        otpResendCooldownSeconds: 45,
        otpTtlMinutes: 10,
        otpMaxAttempts: 5,
        registrationTokenSecret: 'registration-token-secret',
        registrationTokenTtlSeconds: 900,
      },
    ) as AuthSettingsService;

    support.normalizeEmail.mockReturnValue('juan@example.com');
    support.isPasswordStrong.mockReturnValue(true);
    support.verifyRegistrationToken.mockResolvedValue({
      sub: 'juan@example.com',
      purpose: 'registration',
    } as never);
    support.isSupabaseDuplicateUserError.mockReturnValue(false);
    registrationOtpRepository.findByEmail.mockResolvedValue({
      email: 'juan@example.com',
      codeHash: 'code-hash',
      expiresAt: '2099-01-01T00:00:00.000Z',
      failedAttempts: 0,
      lastSentAt: '2025-01-01T00:00:00.000Z',
      verifiedAt: '2025-01-01T00:01:00.000Z',
      createdAt: '2025-01-01T00:00:00.000Z',
      updatedAt: '2025-01-01T00:00:00.000Z',
    } as never);

    const service = new RegistrationAuthService(
      new JwtService(),
      mailerService,
      supabaseService,
      registrationOtpRepository,
      profileService,
      settings,
      support,
      passwordHistoryService,
    );

    await service.completeRegistration({
      email: 'juan@example.com',
      password: 'Password1!',
      registrationToken: 'registration-token',
    } as never);

    expect(passwordHistoryService.createPasswordEntry).toHaveBeenCalledWith(
      'user-1',
      'Password1!',
    );
  });
});
