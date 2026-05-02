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
          mpin_hash: string;
          failed_attempts: number;
          locked_until: string | null;
          last_verified_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          mpin_hash: string;
          failed_attempts?: number;
          locked_until?: string | null;
          last_verified_at?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          user_id?: string;
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
      user_mpin_devices: {
        Row: {
          user_id: string;
          device_id: string;
          registered_at: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          user_id: string;
          device_id: string;
          registered_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          user_id?: string;
          device_id?: string;
          registered_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'user_mpin_devices_user_id_fkey';
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
      bmi_records: {
        Row: {
          id: string;
          profile_id: string;
          weight_kg: number;
          height_cm: number;
          bmi_value: number;
          manual_bmi_value: number | null;
          bmi_source: 'computed' | 'manual';
          measurement_system: 'metric' | 'imperial';
          notes: string | null;
          recorded_at: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          profile_id: string;
          weight_kg: number;
          height_cm: number;
          bmi_value: number;
          manual_bmi_value?: number | null;
          bmi_source?: 'computed' | 'manual';
          measurement_system: 'metric' | 'imperial';
          notes?: string | null;
          recorded_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          profile_id?: string;
          weight_kg?: number;
          height_cm?: number;
          bmi_value?: number;
          manual_bmi_value?: number | null;
          bmi_source?: 'computed' | 'manual';
          measurement_system?: 'metric' | 'imperial';
          notes?: string | null;
          recorded_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'bmi_records_profile_id_fkey';
            columns: ['profile_id'];
            isOneToOne: false;
            referencedRelation: 'users';
            referencedColumns: ['id'];
          },
        ];
      };
      blood_pressure_records: {
        Row: {
          id: string;
          profile_id: string;
          systolic_mm_hg: number;
          diastolic_mm_hg: number;
          pulse_rate: number | null;
          measurement_position:
            | 'sitting'
            | 'standing'
            | 'lying'
            | 'other'
            | null;
          measurement_method: string | null;
          notes: string | null;
          recorded_at: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          profile_id: string;
          systolic_mm_hg: number;
          diastolic_mm_hg: number;
          pulse_rate?: number | null;
          measurement_position?:
            | 'sitting'
            | 'standing'
            | 'lying'
            | 'other'
            | null;
          measurement_method?: string | null;
          notes?: string | null;
          recorded_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          profile_id?: string;
          systolic_mm_hg?: number;
          diastolic_mm_hg?: number;
          pulse_rate?: number | null;
          measurement_position?:
            | 'sitting'
            | 'standing'
            | 'lying'
            | 'other'
            | null;
          measurement_method?: string | null;
          notes?: string | null;
          recorded_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'blood_pressure_records_profile_id_fkey';
            columns: ['profile_id'];
            isOneToOne: false;
            referencedRelation: 'users';
            referencedColumns: ['id'];
          },
        ];
      };
      temperature_records: {
        Row: {
          id: string;
          profile_id: string;
          temperature_value: number;
          temperature_unit: 'celsius' | 'fahrenheit';
          normalized_celsius: number;
          measurement_method: string | null;
          notes: string | null;
          recorded_at: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          profile_id: string;
          temperature_value: number;
          temperature_unit: 'celsius' | 'fahrenheit';
          normalized_celsius: number;
          measurement_method?: string | null;
          notes?: string | null;
          recorded_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          profile_id?: string;
          temperature_value?: number;
          temperature_unit?: 'celsius' | 'fahrenheit';
          normalized_celsius?: number;
          measurement_method?: string | null;
          notes?: string | null;
          recorded_at?: string;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'temperature_records_profile_id_fkey';
            columns: ['profile_id'];
            isOneToOne: false;
            referencedRelation: 'users';
            referencedColumns: ['id'];
          },
        ];
      };
      medication_intake_records: {
        Row: {
          id: string;
          profile_id: string;
          prescription_id: string | null;
          medication_reference: string | null;
          medication_name_snapshot: string;
          scheduled_at: string;
          taken_at: string | null;
          status: 'scheduled' | 'taken' | 'missed' | 'delayed' | 'skipped';
          quantity_value: number | null;
          quantity_unit: string | null;
          notes: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          profile_id: string;
          prescription_id?: string | null;
          medication_reference?: string | null;
          medication_name_snapshot: string;
          scheduled_at: string;
          taken_at?: string | null;
          status?: 'scheduled' | 'taken' | 'missed' | 'delayed' | 'skipped';
          quantity_value?: number | null;
          quantity_unit?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          profile_id?: string;
          prescription_id?: string | null;
          medication_reference?: string | null;
          medication_name_snapshot?: string;
          scheduled_at?: string;
          taken_at?: string | null;
          status?: 'scheduled' | 'taken' | 'missed' | 'delayed' | 'skipped';
          quantity_value?: number | null;
          quantity_unit?: string | null;
          notes?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'medication_intake_records_profile_id_fkey';
            columns: ['profile_id'];
            isOneToOne: false;
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
