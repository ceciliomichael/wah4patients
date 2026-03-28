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
      profiles: {
        Row: {
          id: string;
          email: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          email: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          created_at?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: "profiles_id_fkey";
            columns: ["id"];
            isOneToOne: true;
            referencedRelation: "users";
            referencedColumns: ["id"];
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
