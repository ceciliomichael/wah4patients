import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UserMpinDeviceRecord, UserMpinDeviceUpsert } from './auth.types';

interface UserMpinDeviceRow {
  user_id: string;
  device_id: string;
  registered_at: string;
}

@Injectable()
export class UserMpinDeviceRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findByUserId(userId: string): Promise<UserMpinDeviceRecord | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from('user_mpin_devices')
      .select('user_id, device_id, registered_at')
      .eq('user_id', userId)
      .maybeSingle();

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to read MPIN device record',
      );
    }

    const row = data as unknown as UserMpinDeviceRow | null;
    if (row === null) {
      return null;
    }

    return {
      userId: row.user_id,
      deviceId: row.device_id,
      registeredAt: row.registered_at,
    };
  }

  async upsert(input: UserMpinDeviceUpsert): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('user_mpin_devices')
      .upsert(
        {
          user_id: input.userId,
          device_id: input.deviceId,
          registered_at: input.registeredAt ?? new Date().toISOString(),
        },
        { onConflict: 'user_id' },
      );

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to store MPIN device record',
      );
    }
  }

  async deleteByUserId(userId: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('user_mpin_devices')
      .delete()
      .eq('user_id', userId);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to remove MPIN device record',
      );
    }
  }
}
