import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { PatientProfileResponse } from './auth.types';

interface ProfileRow {
  id: string;
  email: string;
  given_names: string[];
  family_name: string;
  created_at: string;
  updated_at: string;
}

export interface ProfileUpsertInput {
  id: string;
  email: string;
  givenNames: string[];
  familyName: string;
}

@Injectable()
export class ProfileRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findByUserId(userId: string): Promise<ProfileRow | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from('profiles')
      .select('id, email, given_names, family_name, created_at, updated_at')
      .eq('id', userId)
      .maybeSingle();

    if (error !== null) {
      throw new InternalServerErrorException('Unable to read profile record');
    }

    return (data as ProfileRow | null) ?? null;
  }

  async upsert(input: ProfileUpsertInput): Promise<ProfileRow> {
    const payload = {
      id: input.id,
      email: input.email,
      given_names: input.givenNames,
      family_name: input.familyName,
    };

    const { data, error } = await this.supabaseService.adminClient
      .from('profiles')
      .upsert(payload, { onConflict: 'id' })
      .select('id, email, given_names, family_name, created_at, updated_at')
      .single();

    if (error !== null || data === null) {
      throw new InternalServerErrorException('Unable to save profile record');
    }

    return data as ProfileRow;
  }

  toResponse(row: ProfileRow): PatientProfileResponse {
    return {
      givenNames: row.given_names,
      familyName: row.family_name,
      displayName: this.buildDisplayName(row.given_names, row.family_name),
    };
  }

  private buildDisplayName(givenNames: string[], familyName: string): string {
    const nameParts = givenNames
      .map((part) => part.trim())
      .filter((part) => part.length > 0);
    const trimmedFamilyName = familyName.trim();

    if (nameParts.length === 0 && trimmedFamilyName.length === 0) {
      return '';
    }

    const displayNameParts = [...nameParts];
    if (trimmedFamilyName.length > 0) {
      displayNameParts.push(trimmedFamilyName);
    }

    return displayNameParts.join(' ');
  }
}
