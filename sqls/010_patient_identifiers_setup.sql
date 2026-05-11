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
