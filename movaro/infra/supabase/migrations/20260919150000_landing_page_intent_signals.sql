create table if not exists public.landing_page_intent_signals (
  session_id uuid primary key,
  locale text not null check (locale in ('pt', 'es', 'en')),
  intent_category text not null check (
    intent_category in (
      'cityFit',
      'costsAndHousing',
      'documentsAndSteps',
      'stillExploring'
    )
  ),
  move_stage text not null check (
    move_stage in ('exploring', 'withinSixMonths', 'organizingMove')
  ),
  submitted_at timestamptz not null default timezone('utc', now()),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists landing_page_intent_signals_analysis_idx
  on public.landing_page_intent_signals (
    intent_category,
    move_stage,
    locale,
    submitted_at desc
  );

alter table public.landing_page_intent_signals enable row level security;

-- Server-only table: the browser submits bounded categories through the API.

drop trigger if exists trg_landing_page_intent_signals_updated_at
  on public.landing_page_intent_signals;
create trigger trg_landing_page_intent_signals_updated_at
before update on public.landing_page_intent_signals
for each row execute function public.set_updated_at();
