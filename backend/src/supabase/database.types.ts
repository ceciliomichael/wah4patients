export interface Database {
  public: {
    Tables: {
      registration_otps: {
        Row: {
          email: string;
          code_hash: string;
          expires_at: string;
          failed_attempts: number;
          last_sent_at: string;
          verified_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          email: string;
          code_hash: string;
          expires_at: string;
          failed_attempts?: number;
          last_sent_at?: string;
          verified_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          email?: string;
          code_hash?: string;
          expires_at?: string;
          failed_attempts?: number;
          last_sent_at?: string;
          verified_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      password_reset_otps: {
        Row: {
          email: string;
          code_hash: string;
          expires_at: string;
          failed_attempts: number;
          last_sent_at: string;
          verified_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          email: string;
          code_hash: string;
          expires_at: string;
          failed_attempts?: number;
          last_sent_at?: string;
          verified_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          email?: string;
          code_hash?: string;
          expires_at?: string;
          failed_attempts?: number;
          last_sent_at?: string;
          verified_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      user_totp_factors: {
        Row: {
          user_id: string;
          is_enabled: boolean;
          totp_secret_ciphertext: string | null;
          totp_secret_temp_ciphertext: string | null;
          enabled_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          is_enabled?: boolean;
          totp_secret_ciphertext?: string | null;
          totp_secret_temp_ciphertext?: string | null;
          enabled_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          user_id?: string;
          is_enabled?: boolean;
          totp_secret_ciphertext?: string | null;
          totp_secret_temp_ciphertext?: string | null;
          enabled_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'user_totp_factors_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: true;
            referencedRelation: 'users';
            referencedColumns: ['id'];
          },
        ];
      };
      user_totp_recovery_codes: {
        Row: {
          id: string;
          user_id: string;
          code_hash: string;
          used_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          code_hash: string;
          used_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          user_id?: string;
          code_hash?: string;
          used_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'user_totp_recovery_codes_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: false;
            referencedRelation: 'users';
            referencedColumns: ['id'];
          },
        ];
      };
      user_mpins: {
        Row: {
          user_id: string;
          device_id: string;
          mpin_hash: string;
          failed_attempts: number;
          locked_until: string | null;
          last_verified_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          device_id: string;
          mpin_hash: string;
          failed_attempts?: number;
          locked_until?: string | null;
          last_verified_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          user_id?: string;
          device_id?: string;
          mpin_hash?: string;
          failed_attempts?: number;
          locked_until?: string | null;
          last_verified_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'user_mpins_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: true;
            referencedRelation: 'users';
            referencedColumns: ['id'];
          },
        ];
      };
      profiles: {
        Row: {
          id: string;
          email: string;
          given_names: string[];
          family_name: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          email: string;
          given_names?: string[];
          family_name?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          given_names?: string[];
          family_name?: string;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'profiles_id_fkey';
            columns: ['id'];
            isOneToOne: true;
            referencedRelation: 'users';
            referencedColumns: ['id'];
          },
        ];
      };
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
}
