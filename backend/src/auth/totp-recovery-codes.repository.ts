import { Injectable, InternalServerErrorException } from "@nestjs/common";
import { SupabaseService } from "../supabase/supabase.service";

@Injectable()
export class TotpRecoveryCodesRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async consumeCodeHash(userId: string, codeHash: string): Promise<boolean> {
    const { data, error } = await this.supabaseService.adminClient
      .from("user_totp_recovery_codes")
      .update({ used_at: new Date().toISOString() })
      .eq("user_id", userId)
      .eq("code_hash", codeHash)
      .is("used_at", null)
      .select("id")
      .limit(1);

    if (error !== null) {
      throw new InternalServerErrorException("Unable to verify backup code");
    }

    return Array.isArray(data) && data.length > 0;
  }

  async clearAll(userId: string): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from("user_totp_recovery_codes")
      .delete()
      .eq("user_id", userId);

    if (error !== null) {
      throw new InternalServerErrorException("Unable to clear TOTP recovery codes");
    }
  }

  async replaceCodes(userId: string, codeHashes: string[]): Promise<void> {
    await this.clearAll(userId);

    if (codeHashes.length === 0) {
      return;
    }

    const { error } = await this.supabaseService.adminClient
      .from("user_totp_recovery_codes")
      .insert(
        codeHashes.map((codeHash) => ({
          user_id: userId,
          code_hash: codeHash,
        })),
      );

    if (error !== null) {
      throw new InternalServerErrorException("Unable to store TOTP recovery codes");
    }
  }
}
