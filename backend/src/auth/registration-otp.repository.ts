import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { RegistrationOtpRecord, RegistrationOtpUpsert } from './auth.types';

interface RegistrationOtpRow {
  email: string;
  code_hash: string;
  expires_at: string;
  failed_attempts: number;
  last_sent_at: string;
  verified_at: string | null;
}

interface RegistrationOtpUpsertRow {
  email: string;
  code_hash: string;
  expires_at: string;
  failed_attempts: number;
  last_sent_at: string;
  verified_at: string | null;
}

@Injectable()
export class RegistrationOtpRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findByEmail(email: string): Promise<RegistrationOtpRecord | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from('registration_otps')
      .select(
        'email, code_hash, expires_at, failed_attempts, last_sent_at, verified_at',
      )
      .eq('email', email)
      .maybeSingle();

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to read OTP registration record',
      );
    }

    const row = data as unknown as RegistrationOtpRow | null;

    if (row === null) {
      return null;
    }

    return this.toRecord(row);
  }

  async upsert(input: RegistrationOtpUpsert): Promise<void> {
    const payload: RegistrationOtpUpsertRow = {
      email: input.email,
      code_hash: input.codeHash,
      expires_at: input.expiresAt,
      failed_attempts: input.failedAttempts,
      last_sent_at: input.lastSentAt,
      verified_at: input.verifiedAt,
    };

    const { error } = await this.supabaseService.adminClient
      .from('registration_otps')
      .upsert(payload, { onConflict: 'email' });

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to store OTP registration record',
      );
    }
  }

  async incrementFailedAttempts(
    email: string,
    failedAttempts: number,
  ): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('registration_otps')
      .update({ failed_attempts: failedAttempts })
      .eq('email', email);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to update OTP attempts');
    }
  }

  async markVerified(email: string, verifiedAt: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('registration_otps')
      .update({ verified_at: verifiedAt, failed_attempts: 0 })
      .eq('email', email);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to update OTP verification status',
      );
    }
  }

  async deleteByEmail(email: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('registration_otps')
      .delete()
      .eq('email', email);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to remove OTP record');
    }
  }

  private toRecord(row: RegistrationOtpRow): RegistrationOtpRecord {
    return {
      email: row.email,
      codeHash: row.code_hash,
      expiresAt: row.expires_at,
      failedAttempts: row.failed_attempts,
      lastSentAt: row.last_sent_at,
      verifiedAt: row.verified_at,
    };
  }
}
