create table if not exists public.app_state_snapshots (
  user_id uuid not null references auth.users (id) on delete cascade,
  scope text not null,
  installation_id text not null,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default timezone('utc'::text, now()),
  primary key (user_id, scope)
);

create index if not exists app_state_snapshots_updated_at_idx
  on public.app_state_snapshots (updated_at desc);

alter table public.app_state_snapshots enable row level security;

drop policy if exists "app_state_snapshots_select_own" on public.app_state_snapshots;
create policy "app_state_snapshots_select_own"
  on public.app_state_snapshots
  for select
  to authenticated, anon
  using (auth.uid() = user_id);

drop policy if exists "app_state_snapshots_insert_own" on public.app_state_snapshots;
create policy "app_state_snapshots_insert_own"
  on public.app_state_snapshots
  for insert
  to authenticated, anon
  with check (auth.uid() = user_id);

drop policy if exists "app_state_snapshots_update_own" on public.app_state_snapshots;
create policy "app_state_snapshots_update_own"
  on public.app_state_snapshots
  for update
  to authenticated, anon
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "app_state_snapshots_delete_own" on public.app_state_snapshots;
create policy "app_state_snapshots_delete_own"
  on public.app_state_snapshots
  for delete
  to authenticated, anon
  using (auth.uid() = user_id);
