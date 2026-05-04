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
