import { ConflictException } from '@nestjs/common';
import { compare, hash } from 'bcryptjs';
import { PasswordHistoryRepository } from './password-history.repository';
import { PasswordHistoryService } from './password-history.service';

jest.mock('bcryptjs', () => ({
  compare: jest.fn(),
  hash: jest.fn(),
}));

describe('PasswordHistoryService', () => {
  const mockedHash = hash as jest.MockedFunction<typeof hash>;
  const mockedCompare = compare as jest.MockedFunction<typeof compare>;

  const createRepositoryMock = () => {
    return {
      findRecentByUserId: jest.fn(),
      insert: jest.fn(),
      deleteById: jest.fn(),
      pruneToLatest: jest.fn(),
    } as unknown as jest.Mocked<PasswordHistoryRepository>;
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('rejects a password that matches recent password history', async () => {
    const repository = createRepositoryMock();
    const service = new PasswordHistoryService(repository);

    repository.findRecentByUserId.mockResolvedValue([
      {
        id: 'history-1',
        user_id: 'user-1',
        password_hash: 'stored-hash',
        created_at: '2025-01-01T00:00:00.000Z',
        updated_at: '2025-01-01T00:00:00.000Z',
      },
    ]);
    mockedCompare.mockResolvedValue(true);

    await expect(
      service.assertPasswordNotReused('user-1', 'Password1!'),
    ).rejects.toBeInstanceOf(ConflictException);

    expect(repository.insert).not.toHaveBeenCalled();
  });

  it('stores a password history entry and prunes older rows', async () => {
    const repository = createRepositoryMock();
    const service = new PasswordHistoryService(repository);

    mockedHash.mockResolvedValue('hashed-password');
    mockedCompare.mockResolvedValue(false);
    repository.insert.mockResolvedValue({
      id: 'history-1',
      user_id: 'user-1',
      password_hash: 'hashed-password',
      created_at: '2025-01-01T00:00:00.000Z',
      updated_at: '2025-01-01T00:00:00.000Z',
    });
    repository.pruneToLatest.mockResolvedValue();

    const result = await service.createPasswordEntry('user-1', 'Password1!');

    expect(mockedHash).toHaveBeenCalledWith('Password1!', 12);
    expect(repository.insert).toHaveBeenCalledWith({
      userId: 'user-1',
      passwordHash: 'hashed-password',
    });
    expect(repository.pruneToLatest).toHaveBeenCalledWith('user-1', 5);
    expect(result.id).toBe('history-1');
  });
});
