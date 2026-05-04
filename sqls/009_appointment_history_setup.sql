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
