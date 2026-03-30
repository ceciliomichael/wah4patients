import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UserMpinRecord, UserMpinUpsert } from './auth.types';

interface UserMpinRow {
  user_id: string;
  mpin_hash: string;
  failed_attempts: number;
  locked_until: string | null;
  last_verified_at: string | null;
}

@Injectable()
export class UserMpinRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findByUserId(userId: string): Promise<UserMpinRecord | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from('user_mpins')
      .select(
        'user_id, mpin_hash, failed_attempts, locked_until, last_verified_at',
      )
      .eq('user_id', userId)
      .maybeSingle();

    if (error !== null) {
      throw new InternalServerErrorException('Unable to read MPIN record');
    }

    const row = data as unknown as UserMpinRow | null;
    if (row === null) {
      return null;
    }

    return {
      userId: row.user_id,
      mpinHash: row.mpin_hash,
      failedAttempts: row.failed_attempts,
      lockedUntil: row.locked_until,
      lastVerifiedAt: row.last_verified_at,
    };
  }

  async upsert(input: UserMpinUpsert): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('user_mpins')
      .upsert(
        {
          user_id: input.userId,
          mpin_hash: input.mpinHash,
          failed_attempts: input.failedAttempts,
          locked_until: input.lockedUntil,
          last_verified_at: input.lastVerifiedAt,
        },
        { onConflict: 'user_id' },
      );

    if (error !== null) {
      throw new InternalServerErrorException('Unable to store MPIN record');
    }
  }

  async updateFailureState(
    userId: string,
    failedAttempts: number,
    lockedUntil: string | null,
  ): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('user_mpins')
      .update({
        failed_attempts: failedAttempts,
        locked_until: lockedUntil,
      })
      .eq('user_id', userId);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to update MPIN state');
    }
  }

  async markVerified(userId: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('user_mpins')
      .update({
        failed_attempts: 0,
        locked_until: null,
        last_verified_at: new Date().toISOString(),
      })
      .eq('user_id', userId);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to update MPIN verification',
      );
    }
  }

  async deleteByUserId(userId: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('user_mpins')
      .delete()
      .eq('user_id', userId);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to remove MPIN record');
    }
  }
}
