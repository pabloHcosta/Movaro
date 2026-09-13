create table if not exists public.launch_interests (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  locale text not null default 'pt' check (locale in ('pt', 'es', 'en')),
  source text not null default 'landing_page' check (char_length(source) between 3 and 64),
  status text not null default 'interested' check (status in ('interested', 'invited', 'unsubscribed')),
  submission_count integer not null default 1 check (submission_count > 0),
  consented_at timestamptz not null default now(),
  last_submitted_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint launch_interests_email_normalized check (email = lower(btrim(email))),
  constraint launch_interests_email_length check (char_length(email) between 3 and 254),
  constraint launch_interests_email_unique unique (email)
);

create index if not exists launch_interests_status_created_at_idx
  on public.launch_interests (status, created_at desc);

create or replace function public.bump_launch_interest_submission()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.submission_count := old.submission_count + 1;
  return new;
end;
$$;

drop trigger if exists launch_interests_increment_submission on public.launch_interests;
create trigger launch_interests_increment_submission
before update on public.launch_interests
for each row execute function public.bump_launch_interest_submission();

alter table public.launch_interests enable row level security;

-- No public policies: only the server-side Supabase key can access launch emails.
