import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

export interface PasswordHistoryRow {
  id: string;
  user_id: string;
  password_hash: string;
  created_at: string;
  updated_at: string;
}

export interface PasswordHistoryInsertInput {
  userId: string;
  passwordHash: string;
}

@Injectable()
export class PasswordHistoryRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findRecentByUserId(
    userId: string,
    limit: number,
  ): Promise<PasswordHistoryRow[]> {
    const { data, error } = await this.supabaseService.adminClient
      .from('password_history_records')
      .select('id, user_id, password_hash, created_at, updated_at')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to read password history');
    }

    return (data as PasswordHistoryRow[] | null) ?? [];
  }

  async insert(input: PasswordHistoryInsertInput): Promise<PasswordHistoryRow> {
    const { data, error } = await this.supabaseService.adminClient
      .from('password_history_records')
      .insert({
        user_id: input.userId,
        password_hash: input.passwordHash,
      })
      .select('id, user_id, password_hash, created_at, updated_at')
      .single();

    if (error !== null || data === null) {
      throw new InternalServerErrorException('Unable to store password history');
    }

    return data as PasswordHistoryRow;
  }

  async deleteById(id: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('password_history_records')
      .delete()
      .eq('id', id);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to remove password history');
    }
  }

  async pruneToLatest(userId: string, keepLatestCount: number): Promise<void> {
    const rows = await this.findRecentByUserId(userId, keepLatestCount + 100);
    const idsToDelete = rows.slice(keepLatestCount).map((row) => row.id);

    if (idsToDelete.length === 0) {
      return;
    }

    const { error } = await this.supabaseService.adminClient
      .from('password_history_records')
      .delete()
      .in('id', idsToDelete);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to prune password history');
    }
  }
}
