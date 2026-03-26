import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { Database } from './database.types';

type GenericSupabaseClient = SupabaseClient<Database>;

@Injectable()
export class SupabaseService {
  readonly adminClient: GenericSupabaseClient;
  readonly authClient: GenericSupabaseClient;

  constructor(private readonly configService: ConfigService) {
    const supabaseUrl = this.configService.getOrThrow<string>('SUPABASE_URL');
    const secretKey = this.configService.getOrThrow<string>(
      'SUPABASE_SECRET_KEY',
    );
    const publishableKey = this.configService.getOrThrow<string>(
      'SUPABASE_PUBLISHABLE_KEY',
    );

    this.adminClient = createClient<Database>(supabaseUrl, secretKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false,
      },
    });

    this.authClient = createClient<Database>(supabaseUrl, publishableKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false,
      },
    });
  }
}
