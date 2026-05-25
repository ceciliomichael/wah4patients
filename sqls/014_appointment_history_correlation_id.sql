begin;

alter table public.appointment_history_records
  add column if not exists correlation_id text not null default '';

create index if not exists appointment_history_records_correlation_id_idx
  on public.appointment_history_records (correlation_id);

commit;
