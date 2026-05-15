import { ConflictException, Injectable, Logger } from '@nestjs/common';
import { compare, hash } from 'bcryptjs';
import {
  PasswordHistoryRepository,
  type PasswordHistoryRow,
} from './password-history.repository';

const PASSWORD_HISTORY_LIMIT = 5;
const PASSWORD_HISTORY_BCRYPT_ROUNDS = 12;
const PASSWORD_HISTORY_SCAN_LIMIT = 20;

@Injectable()
export class PasswordHistoryService {
  private readonly logger = new Logger(PasswordHistoryService.name);

  constructor(
    private readonly passwordHistoryRepository: PasswordHistoryRepository,
  ) {}

  async assertPasswordNotReused(
    userId: string,
    password: string,
  ): Promise<void> {
    const recentHistory = await this.passwordHistoryRepository.findRecentByUserId(
      userId,
      PASSWORD_HISTORY_SCAN_LIMIT,
    );

    for (const entry of recentHistory) {
      if (await compare(password, entry.password_hash)) {
        throw new ConflictException(
          'You cannot reuse a previous password',
        );
      }
    }
  }

  async createPasswordEntry(
    userId: string,
    password: string,
  ): Promise<PasswordHistoryRow> {
    const passwordHash = await hash(password, PASSWORD_HISTORY_BCRYPT_ROUNDS);
    const entry = await this.passwordHistoryRepository.insert({
      userId,
      passwordHash,
    });

    try {
      await this.passwordHistoryRepository.pruneToLatest(
        userId,
        PASSWORD_HISTORY_LIMIT,
      );
    } catch (error) {
      this.logger.warn('Unable to prune password history after insert', {
        userId,
        message: error instanceof Error ? error.message : 'Unknown error',
      });
    }

    return entry;
  }

  async deletePasswordEntry(id: string): Promise<void> {
    await this.passwordHistoryRepository.deleteById(id);
  }
}
