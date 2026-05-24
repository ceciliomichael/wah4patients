begin;

alter table public.appointment_history_records
  add column if not exists gateway_transaction_id text not null default '';

create index if not exists appointment_history_records_gateway_transaction_id_idx
  on public.appointment_history_records (gateway_transaction_id);

commit;
