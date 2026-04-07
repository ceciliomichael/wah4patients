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
