create table if not exists public.product_flow_events (
  event_id text primary key,
  installation_token text not null,
  app_environment text not null,
  event_name text not null check (
    event_name in (
      'questionnaireStarted',
      'questionAnswered',
      'planGenerated',
      'taskSelected',
      'taskStarted',
      'taskWaiting',
      'taskResumed',
      'taskCompleted',
      'fullPlanOpened'
    )
  ),
  occurred_at timestamptz not null,
  step_index integer null check (step_index between 0 and 100),
  created_at timestamptz not null default timezone('utc'::text, now())
);

create index if not exists product_flow_events_occurred_at_idx
  on public.product_flow_events (occurred_at desc);

create index if not exists product_flow_events_funnel_idx
  on public.product_flow_events (event_name, occurred_at desc);

alter table public.product_flow_events enable row level security;

-- Product events are server-write-only. The Nest API uses the service role.
-- No anon/authenticated select or write policy is intentionally created.
