begin;

create extension if not exists pgcrypto;

create table if not exists public.registration_otps (
  email text primary key check (char_length(email) between 6 and 254),
  code_hash text not null,
  expires_at timestamptz not null,
  failed_attempts integer not null default 0 check (failed_attempts >= 0),
  last_sent_at timestamptz not null default timezone('utc', now()),
  verified_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique check (char_length(email) between 6 and 254),
  given_names text[] not null default '{}'::text[],
  family_name text not null default '',
  patient_profile jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.profiles
  add column if not exists given_names text[] not null default '{}'::text[];

alter table public.profiles
  add column if not exists family_name text not null default '';

alter table public.profiles
  add column if not exists patient_profile jsonb not null default '{}'::jsonb;

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists registration_otps_set_updated_at on public.registration_otps;
create trigger registration_otps_set_updated_at
before update on public.registration_otps
for each row execute function public.set_updated_at_timestamp();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at_timestamp();

create or replace function public.handle_auth_user_profile_sync()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email is null then
    return new;
  end if;

  insert into public.profiles (id, email)
  values (new.id, lower(new.email))
  on conflict (id) do update
    set email = excluded.email,
        updated_at = timezone('utc', now());

  return new;
end;
$$;

drop trigger if exists auth_user_profile_sync on auth.users;
create trigger auth_user_profile_sync
after insert or update of email on auth.users
for each row execute function public.handle_auth_user_profile_sync();

alter table public.registration_otps enable row level security;
alter table public.profiles enable row level security;

drop policy if exists registration_otps_deny_client_access on public.registration_otps;
create policy registration_otps_deny_client_access
on public.registration_otps
for all
to public
using (false)
with check (false);

drop policy if exists profile_select_own on public.profiles;
create policy profile_select_own
on public.profiles
for select
to authenticated
using ((select auth.uid()) = id);

drop policy if exists profile_update_own on public.profiles;
create policy profile_update_own
on public.profiles
for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

commit;
begin;

create table if not exists public.password_reset_otps (
  email text primary key check (char_length(email) between 6 and 254),
  code_hash text not null,
  expires_at timestamptz not null,
  failed_attempts integer not null default 0 check (failed_attempts >= 0),
  last_sent_at timestamptz not null default timezone('utc', now()),
  verified_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists password_reset_otps_set_updated_at on public.password_reset_otps;
create trigger password_reset_otps_set_updated_at
before update on public.password_reset_otps
for each row execute function public.set_updated_at_timestamp();

alter table public.password_reset_otps enable row level security;

drop policy if exists password_reset_otps_deny_client_access on public.password_reset_otps;
create policy password_reset_otps_deny_client_access
on public.password_reset_otps
for all
to public
using (false)
with check (false);

commit;
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

drop index if exists public.user_totp_recovery_codes_user_id_idx;

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
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

drop policy if exists user_totp_factors_deny_client_access on public.user_totp_factors;
create policy user_totp_factors_deny_client_access
on public.user_totp_factors
for all
to public
using (false)
with check (false);

drop policy if exists user_totp_recovery_codes_deny_client_access on public.user_totp_recovery_codes;
create policy user_totp_recovery_codes_deny_client_access
on public.user_totp_recovery_codes
for all
to public
using (false)
with check (false);

-- Backend service-role flow should manage read/write for both tables.
-- No authenticated client policies are added intentionally to avoid exposing secrets.

commit;
begin;

create table if not exists public.user_mpins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  mpin_hash text not null,
  failed_attempts integer not null default 0 check (failed_attempts >= 0),
  locked_until timestamptz,
  last_verified_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists user_mpins_set_updated_at on public.user_mpins;
create trigger user_mpins_set_updated_at
before update on public.user_mpins
for each row execute function public.set_updated_at_timestamp();

create table if not exists public.user_mpin_devices (
  user_id uuid primary key references auth.users (id) on delete cascade,
  device_id text not null check (char_length(device_id) between 16 and 128),
  registered_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

drop trigger if exists user_mpin_devices_set_updated_at on public.user_mpin_devices;
create trigger user_mpin_devices_set_updated_at
before update on public.user_mpin_devices
for each row execute function public.set_updated_at_timestamp();

alter table public.user_mpins enable row level security;
alter table public.user_mpin_devices enable row level security;

drop policy if exists user_mpins_deny_client_access on public.user_mpins;
create policy user_mpins_deny_client_access
on public.user_mpins
for all
to public
using (false)
with check (false);

drop policy if exists user_mpin_devices_deny_client_access on public.user_mpin_devices;
create policy user_mpin_devices_deny_client_access
on public.user_mpin_devices
for all
to public
using (false)
with check (false);

-- Backend service-role flow manages this table; no authenticated client policies.

commit;
begin;

create table if not exists public.user_mpin_devices (
  user_id uuid primary key references auth.users (id) on delete cascade,
  device_id text not null check (char_length(device_id) between 16 and 128),
  registered_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

drop trigger if exists user_mpin_devices_set_updated_at on public.user_mpin_devices;
create trigger user_mpin_devices_set_updated_at
before update on public.user_mpin_devices
for each row execute function public.set_updated_at_timestamp();

alter table public.user_mpin_devices enable row level security;

alter table public.user_mpins
  drop column if exists device_id;

commit;
begin;

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.bmi_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  weight_kg numeric(6,2) not null check (weight_kg > 0),
  height_cm numeric(6,2) not null check (height_cm > 0),
  bmi_value numeric(5,2) not null check (bmi_value > 0),
  manual_bmi_value numeric(5,2),
  bmi_source text not null default 'computed' check (bmi_source in ('computed', 'manual')),
  measurement_system text not null check (measurement_system in ('metric', 'imperial')),
  notes text,
  recorded_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint bmi_records_manual_bmi_value_check check (
    manual_bmi_value is null or manual_bmi_value > 0
  )
);

create index if not exists bmi_records_profile_recorded_at_idx
  on public.bmi_records (profile_id, recorded_at desc);

drop trigger if exists bmi_records_set_updated_at on public.bmi_records;
create trigger bmi_records_set_updated_at
before update on public.bmi_records
for each row execute function public.set_updated_at_timestamp();

alter table public.bmi_records enable row level security;

drop policy if exists bmi_records_select_own on public.bmi_records;
create policy bmi_records_select_own
on public.bmi_records
for select
 to authenticated
using ((select auth.uid()) = profile_id);

drop policy if exists bmi_records_insert_own on public.bmi_records;
create policy bmi_records_insert_own
on public.bmi_records
for insert
 to authenticated
with check ((select auth.uid()) = profile_id);

drop policy if exists bmi_records_update_own on public.bmi_records;
create policy bmi_records_update_own
on public.bmi_records
for update
 to authenticated
using ((select auth.uid()) = profile_id)
with check ((select auth.uid()) = profile_id);

drop policy if exists bmi_records_delete_own on public.bmi_records;
create policy bmi_records_delete_own
on public.bmi_records
for delete
 to authenticated
using ((select auth.uid()) = profile_id);

create table if not exists public.blood_pressure_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  systolic_mm_hg integer not null check (systolic_mm_hg > 0),
  diastolic_mm_hg integer not null check (diastolic_mm_hg > 0),
  pulse_rate integer check (pulse_rate > 0),
  measurement_position text check (
    measurement_position is null or measurement_position in (
      'sitting',
      'standing',
      'lying',
      'other'
    )
  ),
  measurement_method text,
  notes text,
  recorded_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists blood_pressure_records_profile_recorded_at_idx
  on public.blood_pressure_records (profile_id, recorded_at desc);

drop trigger if exists blood_pressure_records_set_updated_at on public.blood_pressure_records;
create trigger blood_pressure_records_set_updated_at
before update on public.blood_pressure_records
for each row execute function public.set_updated_at_timestamp();

alter table public.blood_pressure_records enable row level security;

drop policy if exists blood_pressure_records_select_own on public.blood_pressure_records;
create policy blood_pressure_records_select_own
on public.blood_pressure_records
for select
 to authenticated
using ((select auth.uid()) = profile_id);

drop policy if exists blood_pressure_records_insert_own on public.blood_pressure_records;
create policy blood_pressure_records_insert_own
on public.blood_pressure_records
for insert
 to authenticated
with check ((select auth.uid()) = profile_id);

drop policy if exists blood_pressure_records_update_own on public.blood_pressure_records;
create policy blood_pressure_records_update_own
on public.blood_pressure_records
for update
 to authenticated
using ((select auth.uid()) = profile_id)
with check ((select auth.uid()) = profile_id);

drop policy if exists blood_pressure_records_delete_own on public.blood_pressure_records;
create policy blood_pressure_records_delete_own
on public.blood_pressure_records
for delete
 to authenticated
using ((select auth.uid()) = profile_id);

create table if not exists public.temperature_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  temperature_value numeric(5,2) not null,
  temperature_unit text not null check (temperature_unit in ('celsius', 'fahrenheit')),
  normalized_celsius numeric(5,2) not null,
  measurement_method text,
  notes text,
  recorded_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint temperature_records_value_check check (temperature_value > 0),
  constraint temperature_records_normalized_celsius_check check (normalized_celsius > 0)
);

create index if not exists temperature_records_profile_recorded_at_idx
  on public.temperature_records (profile_id, recorded_at desc);

drop trigger if exists temperature_records_set_updated_at on public.temperature_records;
create trigger temperature_records_set_updated_at
before update on public.temperature_records
for each row execute function public.set_updated_at_timestamp();

alter table public.temperature_records enable row level security;

drop policy if exists temperature_records_select_own on public.temperature_records;
create policy temperature_records_select_own
on public.temperature_records
for select
 to authenticated
using ((select auth.uid()) = profile_id);

drop policy if exists temperature_records_insert_own on public.temperature_records;
create policy temperature_records_insert_own
on public.temperature_records
for insert
 to authenticated
with check ((select auth.uid()) = profile_id);

drop policy if exists temperature_records_update_own on public.temperature_records;
create policy temperature_records_update_own
on public.temperature_records
for update
 to authenticated
using ((select auth.uid()) = profile_id)
with check ((select auth.uid()) = profile_id);

drop policy if exists temperature_records_delete_own on public.temperature_records;
create policy temperature_records_delete_own
on public.temperature_records
for delete
 to authenticated
using ((select auth.uid()) = profile_id);

create table if not exists public.medication_intake_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  prescription_id uuid,
  medication_reference text,
  medication_name_snapshot text not null check (char_length(medication_name_snapshot) between 1 and 200),
  scheduled_at timestamptz not null,
  taken_at timestamptz,
  status text not null default 'scheduled' check (
    status in ('scheduled', 'taken', 'missed', 'delayed', 'skipped')
  ),
  quantity_value numeric(10,2),
  quantity_unit text,
  notes text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint medication_intake_records_taken_at_check check (
    status <> 'taken' or taken_at is not null
  )
);

create index if not exists medication_intake_records_profile_scheduled_at_idx
  on public.medication_intake_records (profile_id, scheduled_at desc);

drop trigger if exists medication_intake_records_set_updated_at on public.medication_intake_records;
create trigger medication_intake_records_set_updated_at
before update on public.medication_intake_records
for each row execute function public.set_updated_at_timestamp();

alter table public.medication_intake_records enable row level security;

drop policy if exists medication_intake_records_select_own on public.medication_intake_records;
create policy medication_intake_records_select_own
on public.medication_intake_records
for select
 to authenticated
using ((select auth.uid()) = profile_id);

drop policy if exists medication_intake_records_insert_own on public.medication_intake_records;
create policy medication_intake_records_insert_own
on public.medication_intake_records
for insert
 to authenticated
with check ((select auth.uid()) = profile_id);

drop policy if exists medication_intake_records_update_own on public.medication_intake_records;
create policy medication_intake_records_update_own
on public.medication_intake_records
for update
 to authenticated
using ((select auth.uid()) = profile_id)
with check ((select auth.uid()) = profile_id);

drop policy if exists medication_intake_records_delete_own on public.medication_intake_records;
create policy medication_intake_records_delete_own
on public.medication_intake_records
for delete
 to authenticated
using ((select auth.uid()) = profile_id);

commit;
begin;

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.medical_history_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 200),
  subtitle text not null default '',
  summary_label text not null check (char_length(trim(summary_label)) between 1 and 80),
  summary_value text not null default '',
  filter_value text not null check (char_length(trim(filter_value)) between 1 and 80),
  status_label text not null check (char_length(trim(status_label)) between 1 and 80),
  status_color_key text not null default 'primary',
  accent_color_key text not null default 'primary',
  icon_key text not null default 'history',
  details_json jsonb not null default '[]'::jsonb,
  recorded_at timestamptz not null default timezone('utc', now()),
  display_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint medical_history_records_details_json_array_check check (jsonb_typeof(details_json) = 'array')
);

create index if not exists medical_history_records_profile_recorded_at_idx
  on public.medical_history_records (profile_id, recorded_at desc);

create index if not exists medical_history_records_profile_filter_idx
  on public.medical_history_records (profile_id, filter_value);

drop trigger if exists medical_history_records_set_updated_at on public.medical_history_records;
create trigger medical_history_records_set_updated_at
before update on public.medical_history_records
for each row execute function public.set_updated_at_timestamp();

alter table public.medical_history_records enable row level security;

drop policy if exists medical_history_records_select_own on public.medical_history_records;
create policy medical_history_records_select_own
on public.medical_history_records
for select
to authenticated
using ((select auth.uid()) = profile_id);

create table if not exists public.immunization_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 200),
  subtitle text not null default '',
  summary_label text not null check (char_length(trim(summary_label)) between 1 and 80),
  summary_value text not null default '',
  filter_value text not null check (char_length(trim(filter_value)) between 1 and 80),
  status_label text not null check (char_length(trim(status_label)) between 1 and 80),
  status_color_key text not null default 'success',
  accent_color_key text not null default 'secondary',
  icon_key text not null default 'vaccines',
  details_json jsonb not null default '[]'::jsonb,
  recorded_at timestamptz not null default timezone('utc', now()),
  display_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint immunization_records_details_json_array_check check (jsonb_typeof(details_json) = 'array')
);

create index if not exists immunization_records_profile_recorded_at_idx
  on public.immunization_records (profile_id, recorded_at desc);

create index if not exists immunization_records_profile_filter_idx
  on public.immunization_records (profile_id, filter_value);

drop trigger if exists immunization_records_set_updated_at on public.immunization_records;
create trigger immunization_records_set_updated_at
before update on public.immunization_records
for each row execute function public.set_updated_at_timestamp();

alter table public.immunization_records enable row level security;

drop policy if exists immunization_records_select_own on public.immunization_records;
create policy immunization_records_select_own
on public.immunization_records
for select
to authenticated
using ((select auth.uid()) = profile_id);

create table if not exists public.medical_consultation_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 200),
  subtitle text not null default '',
  summary_label text not null check (char_length(trim(summary_label)) between 1 and 80),
  summary_value text not null default '',
  filter_value text not null check (char_length(trim(filter_value)) between 1 and 80),
  status_label text not null check (char_length(trim(status_label)) between 1 and 80),
  status_color_key text not null default 'primary',
  accent_color_key text not null default 'primary',
  icon_key text not null default 'medical_services',
  details_json jsonb not null default '[]'::jsonb,
  recorded_at timestamptz not null default timezone('utc', now()),
  display_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint medical_consultation_records_details_json_array_check check (jsonb_typeof(details_json) = 'array')
);

create index if not exists medical_consultation_records_profile_recorded_at_idx
  on public.medical_consultation_records (profile_id, recorded_at desc);

create index if not exists medical_consultation_records_profile_filter_idx
  on public.medical_consultation_records (profile_id, filter_value);

drop trigger if exists medical_consultation_records_set_updated_at on public.medical_consultation_records;
create trigger medical_consultation_records_set_updated_at
before update on public.medical_consultation_records
for each row execute function public.set_updated_at_timestamp();

alter table public.medical_consultation_records enable row level security;

drop policy if exists medical_consultation_records_select_own on public.medical_consultation_records;
create policy medical_consultation_records_select_own
on public.medical_consultation_records
for select
to authenticated
using ((select auth.uid()) = profile_id);

create table if not exists public.laboratory_result_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 200),
  subtitle text not null default '',
  summary_label text not null check (char_length(trim(summary_label)) between 1 and 80),
  summary_value text not null default '',
  filter_value text not null check (char_length(trim(filter_value)) between 1 and 80),
  status_label text not null check (char_length(trim(status_label)) between 1 and 80),
  status_color_key text not null default 'success',
  accent_color_key text not null default 'primary_dark',
  icon_key text not null default 'science',
  details_json jsonb not null default '[]'::jsonb,
  recorded_at timestamptz not null default timezone('utc', now()),
  display_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint laboratory_result_records_details_json_array_check check (jsonb_typeof(details_json) = 'array')
);

create index if not exists laboratory_result_records_profile_recorded_at_idx
  on public.laboratory_result_records (profile_id, recorded_at desc);

create index if not exists laboratory_result_records_profile_filter_idx
  on public.laboratory_result_records (profile_id, filter_value);

drop trigger if exists laboratory_result_records_set_updated_at on public.laboratory_result_records;
create trigger laboratory_result_records_set_updated_at
before update on public.laboratory_result_records
for each row execute function public.set_updated_at_timestamp();

alter table public.laboratory_result_records enable row level security;

drop policy if exists laboratory_result_records_select_own on public.laboratory_result_records;
create policy laboratory_result_records_select_own
on public.laboratory_result_records
for select
to authenticated
using ((select auth.uid()) = profile_id);

commit;
begin;

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.medication_resupply_history_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  medication_name text not null check (char_length(trim(medication_name)) between 1 and 200),
  dosage text not null default '',
  status text not null check (
    status in ('pending', 'approved', 'rejected', 'cancelled')
  ),
  note text not null default '',
  requested_at timestamptz not null default timezone('utc', now()),
  display_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists medication_resupply_history_records_profile_requested_at_idx
  on public.medication_resupply_history_records (profile_id, requested_at desc);

create index if not exists medication_resupply_history_records_profile_status_idx
  on public.medication_resupply_history_records (profile_id, status);

drop trigger if exists medication_resupply_history_records_set_updated_at on public.medication_resupply_history_records;
create trigger medication_resupply_history_records_set_updated_at
before update on public.medication_resupply_history_records
for each row execute function public.set_updated_at_timestamp();

alter table public.medication_resupply_history_records enable row level security;

drop policy if exists medication_resupply_history_records_select_own on public.medication_resupply_history_records;
create policy medication_resupply_history_records_select_own
on public.medication_resupply_history_records
for select
to authenticated
using ((select auth.uid()) = profile_id);

commit;
begin;

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.appointment_history_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 200),
  subtitle text not null default '',
  summary_label text not null check (char_length(trim(summary_label)) between 1 and 80),
  summary_value text not null default '',
  filter_value text not null check (char_length(trim(filter_value)) between 1 and 80),
  status_label text not null check (char_length(trim(status_label)) between 1 and 80),
  status_color_key text not null default 'primary',
  accent_color_key text not null default 'primary',
  icon_key text not null default 'calendar_month',
  details_json jsonb not null default '[]'::jsonb,
  recorded_at timestamptz not null default timezone('utc', now()),
  display_order integer not null default 0,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint appointment_history_records_details_json_array_check check (
    jsonb_typeof(details_json) = 'array'
  )
);

create index if not exists appointment_history_records_profile_recorded_at_idx
  on public.appointment_history_records (profile_id, recorded_at desc);

create index if not exists appointment_history_records_profile_filter_idx
  on public.appointment_history_records (profile_id, filter_value);

drop trigger if exists appointment_history_records_set_updated_at on public.appointment_history_records;
create trigger appointment_history_records_set_updated_at
before update on public.appointment_history_records
for each row execute function public.set_updated_at_timestamp();

alter table public.appointment_history_records enable row level security;

drop policy if exists appointment_history_records_select_own on public.appointment_history_records;
create policy appointment_history_records_select_own
on public.appointment_history_records
for select
to authenticated
using ((select auth.uid()) = profile_id);

commit;
begin;

create table if not exists public.patient_identifiers (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references auth.users (id) on delete cascade,
  identifier_system text not null check (char_length(trim(identifier_system)) between 1 and 255),
  identifier_value text not null check (char_length(trim(identifier_value)) between 1 and 255),
  verified_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint patient_identifiers_profile_identifier_unique unique (
    profile_id,
    identifier_system,
    identifier_value
  )
);

create index if not exists patient_identifiers_system_value_idx
  on public.patient_identifiers (identifier_system, identifier_value);

create index if not exists patient_identifiers_profile_idx
  on public.patient_identifiers (profile_id);

drop trigger if exists patient_identifiers_set_updated_at on public.patient_identifiers;
create trigger patient_identifiers_set_updated_at
before update on public.patient_identifiers
for each row execute function public.set_updated_at_timestamp();

alter table public.patient_identifiers enable row level security;

drop policy if exists patient_identifiers_select_own on public.patient_identifiers;
create policy patient_identifiers_select_own
on public.patient_identifiers
for select
to authenticated
using ((select auth.uid()) = profile_id);

commit;
begin;

create extension if not exists pgcrypto;

create table if not exists public.password_history_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  password_hash text not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists password_history_records_user_id_created_at_idx
  on public.password_history_records (user_id, created_at desc);

create or replace function public.set_updated_at_timestamp()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists password_history_records_set_updated_at on public.password_history_records;
create trigger password_history_records_set_updated_at
before update on public.password_history_records
for each row execute function public.set_updated_at_timestamp();

alter table public.password_history_records enable row level security;

drop policy if exists password_history_records_deny_client_access on public.password_history_records;
create policy password_history_records_deny_client_access
on public.password_history_records
for all
to public
using (false)
with check (false);

commit;
begin;

create table if not exists public.fhir_sync_transactions (
  id uuid primary key default gen_random_uuid(),
  transaction_id text not null check (char_length(trim(transaction_id)) between 1 and 255),
  profile_id uuid not null references auth.users (id) on delete cascade,
  requester_id uuid not null,
  target_provider_id uuid not null,
  resource_type text not null check (char_length(trim(resource_type)) between 1 and 64),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint fhir_sync_transactions_transaction_id_unique unique (transaction_id)
);

create index if not exists fhir_sync_transactions_profile_id_idx
  on public.fhir_sync_transactions (profile_id, created_at desc);

create index if not exists fhir_sync_transactions_requester_id_idx
  on public.fhir_sync_transactions (requester_id, created_at desc);

create index if not exists fhir_sync_transactions_target_provider_id_idx
  on public.fhir_sync_transactions (target_provider_id, created_at desc);

create index if not exists fhir_sync_transactions_resource_type_idx
  on public.fhir_sync_transactions (resource_type, created_at desc);

drop trigger if exists fhir_sync_transactions_set_updated_at on public.fhir_sync_transactions;
create trigger fhir_sync_transactions_set_updated_at
before update on public.fhir_sync_transactions
for each row execute function public.set_updated_at_timestamp();

alter table public.fhir_sync_transactions enable row level security;

drop policy if exists fhir_sync_transactions_select_own on public.fhir_sync_transactions;
create policy fhir_sync_transactions_select_own
on public.fhir_sync_transactions
for select
to authenticated
using ((select auth.uid()) = profile_id);

commit;
begin;

alter table public.appointment_history_records
  add column if not exists gateway_transaction_id text not null default '';

create index if not exists appointment_history_records_gateway_transaction_id_idx
  on public.appointment_history_records (gateway_transaction_id);

commit;
begin;

alter table public.appointment_history_records
  add column if not exists correlation_id text not null default '';

create index if not exists appointment_history_records_correlation_id_idx
  on public.appointment_history_records (correlation_id);

commit;
begin;

alter table public.medication_resupply_history_records
  add column if not exists gateway_transaction_id text not null default '';

alter table public.medication_resupply_history_records
  add column if not exists correlation_id text not null default '';

create index if not exists medication_resupply_history_records_gateway_transaction_id_idx
  on public.medication_resupply_history_records (gateway_transaction_id);

create index if not exists medication_resupply_history_records_correlation_id_idx
  on public.medication_resupply_history_records (correlation_id);

commit;
