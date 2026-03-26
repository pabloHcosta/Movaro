create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.migration_plans (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid references auth.users (id) on delete cascade,
  plan_key text not null,
  status text not null default 'draft',
  origin_country text not null,
  destination_country text not null,
  goal text not null,
  timeline text not null,
  variant text not null default 'lean',
  funding text not null default '',
  travel_group text not null default '',
  children_count integer,
  available_capital text not null default '',
  archetype_key text,
  confidence numeric(5,4) not null default 0,
  selected_priorities text[] not null default '{}',
  selected_constraints text[] not null default '{}',
  recommended_city_id text,
  preferred_city_id text,
  is_city_confirmed boolean not null default false,
  plan_payload jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint migration_plans_status_check
    check (status in ('draft', 'active', 'archived'))
);

create index if not exists migration_plans_owner_created_idx
  on public.migration_plans (owner_user_id, created_at desc);

create index if not exists migration_plans_corridor_idx
  on public.migration_plans (origin_country, destination_country);

create index if not exists migration_plans_city_idx
  on public.migration_plans (recommended_city_id);

create index if not exists migration_plans_payload_gin_idx
  on public.migration_plans using gin (plan_payload);

create table if not exists public.migration_plan_progress (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.migration_plans (id) on delete cascade,
  owner_user_id uuid references auth.users (id) on delete cascade,
  active_item_id text,
  readiness_completed_ids text[] not null default '{}',
  document_completed_ids text[] not null default '{}',
  arrival_completed_ids text[] not null default '{}',
  completed_at_by_id jsonb not null default '{}'::jsonb,
  progress_percent numeric(5,4) not null default 0,
  updated_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  constraint migration_plan_progress_progress_check
    check (progress_percent >= 0 and progress_percent <= 1)
);

create unique index if not exists migration_plan_progress_plan_unique_idx
  on public.migration_plan_progress (plan_id);

create index if not exists migration_plan_progress_owner_updated_idx
  on public.migration_plan_progress (owner_user_id, updated_at desc);

create table if not exists public.assistant_chat_sessions (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid references auth.users (id) on delete cascade,
  plan_id uuid references public.migration_plans (id) on delete set null,
  origin_country text not null,
  destination_country text not null,
  locale text not null default 'pt',
  status text not null default 'open',
  recommended_city_id text,
  current_phase text,
  migration_goal text,
  plan_timeline text,
  context_snapshot jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint assistant_chat_sessions_status_check
    check (status in ('open', 'closed', 'archived'))
);

create index if not exists assistant_chat_sessions_owner_created_idx
  on public.assistant_chat_sessions (owner_user_id, created_at desc);

create index if not exists assistant_chat_sessions_plan_idx
  on public.assistant_chat_sessions (plan_id);

create table if not exists public.assistant_chat_messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.assistant_chat_sessions (id) on delete cascade,
  owner_user_id uuid references auth.users (id) on delete cascade,
  role text not null,
  source text not null default 'app_data',
  intent text,
  confidence numeric(5,4),
  content text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  constraint assistant_chat_messages_role_check
    check (role in ('user', 'assistant', 'system')),
  constraint assistant_chat_messages_source_check
    check (source in ('app_data', 'ai', 'system', 'unknown'))
);

create index if not exists assistant_chat_messages_session_created_idx
  on public.assistant_chat_messages (session_id, created_at asc);

create index if not exists assistant_chat_messages_owner_created_idx
  on public.assistant_chat_messages (owner_user_id, created_at desc);

create table if not exists public.assistant_message_feedback (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.assistant_chat_messages (id) on delete cascade,
  owner_user_id uuid references auth.users (id) on delete cascade,
  rating smallint not null,
  feedback_text text,
  created_at timestamptz not null default timezone('utc', now()),
  constraint assistant_message_feedback_rating_check
    check (rating in (-1, 1))
);

create unique index if not exists assistant_message_feedback_message_owner_unique_idx
  on public.assistant_message_feedback (message_id, owner_user_id);

create or replace function public.sync_plan_progress_owner()
returns trigger
language plpgsql
as $$
begin
  if new.owner_user_id is null then
    select owner_user_id into new.owner_user_id
    from public.migration_plans
    where id = new.plan_id;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_migration_plans_updated_at on public.migration_plans;
create trigger trg_migration_plans_updated_at
before update on public.migration_plans
for each row
execute function public.set_updated_at();

drop trigger if exists trg_migration_plan_progress_updated_at on public.migration_plan_progress;
create trigger trg_migration_plan_progress_updated_at
before update on public.migration_plan_progress
for each row
execute function public.set_updated_at();

drop trigger if exists trg_assistant_chat_sessions_updated_at on public.assistant_chat_sessions;
create trigger trg_assistant_chat_sessions_updated_at
before update on public.assistant_chat_sessions
for each row
execute function public.set_updated_at();

drop trigger if exists trg_sync_plan_progress_owner on public.migration_plan_progress;
create trigger trg_sync_plan_progress_owner
before insert or update on public.migration_plan_progress
for each row
execute function public.sync_plan_progress_owner();

alter table public.migration_plans enable row level security;
alter table public.migration_plan_progress enable row level security;
alter table public.assistant_chat_sessions enable row level security;
alter table public.assistant_chat_messages enable row level security;
alter table public.assistant_message_feedback enable row level security;

drop policy if exists "Users manage own migration plans" on public.migration_plans;
create policy "Users manage own migration plans"
on public.migration_plans
for all
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

drop policy if exists "Users manage own migration plan progress" on public.migration_plan_progress;
create policy "Users manage own migration plan progress"
on public.migration_plan_progress
for all
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

drop policy if exists "Users manage own chat sessions" on public.assistant_chat_sessions;
create policy "Users manage own chat sessions"
on public.assistant_chat_sessions
for all
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

drop policy if exists "Users manage own chat messages" on public.assistant_chat_messages;
create policy "Users manage own chat messages"
on public.assistant_chat_messages
for all
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());

drop policy if exists "Users manage own chat feedback" on public.assistant_message_feedback;
create policy "Users manage own chat feedback"
on public.assistant_message_feedback
for all
using (owner_user_id = auth.uid())
with check (owner_user_id = auth.uid());
