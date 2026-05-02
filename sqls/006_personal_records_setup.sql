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
