begin;

alter table public.medication_resupply_history_records
  add column if not exists gateway_transaction_id text not null default '';

alter table public.medication_resupply_history_records
  add column if not exists correlation_id text not null default '';

create index if not exists medication_resupply_history_records_gateway_transaction_id_idx
  on public.medication_resupply_history_records (gateway_transaction_id);

create index if not exists medication_resupply_history_records_correlation_id_idx
  on public.medication_resupply_history_records (correlation_id);

commit;
