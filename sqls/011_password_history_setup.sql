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
