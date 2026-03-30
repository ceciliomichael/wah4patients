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
