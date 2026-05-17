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
