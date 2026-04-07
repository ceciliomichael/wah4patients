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
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

alter table public.profiles
  add column if not exists given_names text[] not null default '{}'::text[];

alter table public.profiles
  add column if not exists family_name text not null default '';

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
