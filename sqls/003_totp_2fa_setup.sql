begin;

create extension if not exists pgcrypto;

create table if not exists public.user_totp_factors (
  user_id uuid primary key references auth.users (id) on delete cascade,
  is_enabled boolean not null default false,
  totp_secret_ciphertext text,
  totp_secret_temp_ciphertext text,
  enabled_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint user_totp_factors_active_secret_when_enabled check (
    (is_enabled = false)
    or (is_enabled = true and totp_secret_ciphertext is not null)
  )
);

create table if not exists public.user_totp_recovery_codes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  code_hash text not null,
  used_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists user_totp_recovery_codes_user_id_code_hash_uidx
  on public.user_totp_recovery_codes (user_id, code_hash);

create index if not exists user_totp_recovery_codes_user_id_idx
  on public.user_totp_recovery_codes (user_id);

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists user_totp_factors_set_updated_at on public.user_totp_factors;
create trigger user_totp_factors_set_updated_at
before update on public.user_totp_factors
for each row execute function public.set_updated_at_timestamp();

drop trigger if exists user_totp_recovery_codes_set_updated_at on public.user_totp_recovery_codes;
create trigger user_totp_recovery_codes_set_updated_at
before update on public.user_totp_recovery_codes
for each row execute function public.set_updated_at_timestamp();

alter table public.user_totp_factors enable row level security;
alter table public.user_totp_recovery_codes enable row level security;

-- Backend service-role flow should manage read/write for both tables.
-- No authenticated client policies are added intentionally to avoid exposing secrets.

commit;
