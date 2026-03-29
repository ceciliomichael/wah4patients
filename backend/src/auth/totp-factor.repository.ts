import { Injectable, InternalServerErrorException } from "@nestjs/common";
import { SupabaseService } from "../supabase/supabase.service";
import { UserTotpFactorRecord } from "./auth.types";

interface UserTotpFactorRow {
  user_id: string;
  is_enabled: boolean;
  totp_secret_ciphertext: string | null;
  totp_secret_temp_ciphertext: string | null;
  enabled_at: string | null;
}

@Injectable()
export class TotpFactorRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findByUserId(userId: string): Promise<UserTotpFactorRecord | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from("user_totp_factors")
      .select(
        "user_id, is_enabled, totp_secret_ciphertext, totp_secret_temp_ciphertext, enabled_at",
      )
      .eq("user_id", userId)
      .maybeSingle();

    if (error !== null) {
      throw new InternalServerErrorException("Unable to read TOTP factor record");
    }

    const row = data as unknown as UserTotpFactorRow | null;
    if (row === null) {
      return null;
    }

    return {
      userId: row.user_id,
      isEnabled: row.is_enabled,
      totpSecretCiphertext: row.totp_secret_ciphertext,
      totpSecretTempCiphertext: row.totp_secret_temp_ciphertext,
      enabledAt: row.enabled_at,
    };
  }

  async upsertTempSecret(userId: string, tempSecret: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from("user_totp_factors")
      .upsert(
        {
          user_id: userId,
          is_enabled: false,
          totp_secret_temp_ciphertext: tempSecret,
        },
        { onConflict: "user_id" },
      );

    if (error !== null) {
      throw new InternalServerErrorException("Unable to persist TOTP setup secret");
    }
  }

  async enableWithActiveSecret(userId: string, activeSecret: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from("user_totp_factors")
      .upsert(
        {
          user_id: userId,
          is_enabled: true,
          totp_secret_ciphertext: activeSecret,
          totp_secret_temp_ciphertext: null,
          enabled_at: new Date().toISOString(),
        },
        { onConflict: "user_id" },
      );

    if (error !== null) {
      throw new InternalServerErrorException("Unable to enable TOTP factor");
    }
  }

  async disable(userId: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from("user_totp_factors")
      .upsert(
        {
          user_id: userId,
          is_enabled: false,
          totp_secret_ciphertext: null,
          totp_secret_temp_ciphertext: null,
          enabled_at: null,
        },
        { onConflict: "user_id" },
      );

    if (error !== null) {
      throw new InternalServerErrorException("Unable to disable TOTP factor");
    }
  }
}
