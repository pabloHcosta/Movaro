create table if not exists public.landing_page_sessions (
  session_id uuid primary key,
  locale text not null check (locale in ('pt', 'es', 'en')),
  started_at timestamptz not null,
  last_seen_at timestamptz not null,
  active_seconds integer not null default 0 check (active_seconds between 0 and 86400),
  max_scroll_percent integer not null default 0 check (max_scroll_percent between 0 and 100),
  referrer_host text,
  utm_source text,
  utm_medium text,
  utm_campaign text,
  converted boolean not null default false,
  converted_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists landing_page_sessions_started_at_idx
  on public.landing_page_sessions (started_at desc);

create index if not exists landing_page_sessions_conversion_idx
  on public.landing_page_sessions (converted, started_at desc);

create table if not exists public.landing_page_section_engagement (
  session_id uuid not null references public.landing_page_sessions (session_id) on delete cascade,
  section_key text not null check (char_length(section_key) between 2 and 64),
  active_seconds integer not null default 0 check (active_seconds between 0 and 86400),
  view_count integer not null default 0 check (view_count between 0 and 1000),
  max_visibility_percent integer not null default 0 check (max_visibility_percent between 0 and 100),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (session_id, section_key)
);

create index if not exists landing_page_section_engagement_ranking_idx
  on public.landing_page_section_engagement (section_key, active_seconds desc);

alter table public.landing_page_sessions enable row level security;
alter table public.landing_page_section_engagement enable row level security;

-- Server-only tables: the browser sends metrics through the Nest API.

alter table public.launch_interests
  add column if not exists analytics_session_id uuid;

create index if not exists launch_interests_analytics_session_idx
  on public.launch_interests (analytics_session_id);

drop trigger if exists trg_landing_page_sessions_updated_at on public.landing_page_sessions;
create trigger trg_landing_page_sessions_updated_at
before update on public.landing_page_sessions
for each row execute function public.set_updated_at();

drop trigger if exists trg_landing_page_section_engagement_updated_at on public.landing_page_section_engagement;
create trigger trg_landing_page_section_engagement_updated_at
before update on public.landing_page_section_engagement
for each row execute function public.set_updated_at();
