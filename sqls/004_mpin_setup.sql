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
