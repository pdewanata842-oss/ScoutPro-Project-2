-- ScoutPro multi-device sync schema for the bundled app.
-- Run this entire file in Supabase Dashboard > SQL Editor.
create table if not exists public.scoutpro_records (
  id text not null,
  owner_id uuid not null references auth.users(id) on delete cascade,
  record_type text not null check (record_type in ('player','match','event')),
  payload jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (owner_id, record_type, id)
);
create index if not exists scoutpro_records_owner_type_idx
  on public.scoutpro_records(owner_id, record_type);
alter table public.scoutpro_records enable row level security;
drop policy if exists "Users can read own ScoutPro records" on public.scoutpro_records;
drop policy if exists "Users can insert own ScoutPro records" on public.scoutpro_records;
drop policy if exists "Users can update own ScoutPro records" on public.scoutpro_records;
drop policy if exists "Users can delete own ScoutPro records" on public.scoutpro_records;
create policy "Users can read own ScoutPro records" on public.scoutpro_records
  for select to authenticated using (owner_id = (select auth.uid()));
create policy "Users can insert own ScoutPro records" on public.scoutpro_records
  for insert to authenticated with check (owner_id = (select auth.uid()));
create policy "Users can update own ScoutPro records" on public.scoutpro_records
  for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "Users can delete own ScoutPro records" on public.scoutpro_records
  for delete to authenticated using (owner_id = (select auth.uid()));
-- Enable Realtime notifications for changes to this table.
do $$ begin
  alter publication supabase_realtime add table public.scoutpro_records;
exception when duplicate_object then null;
when undefined_object then null;
end $$;
