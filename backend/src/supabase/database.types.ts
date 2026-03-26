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
    };
    Views: Record<string, never>;
    Functions: Record<string, never>;
    Enums: Record<string, never>;
    CompositeTypes: Record<string, never>;
  };
}
