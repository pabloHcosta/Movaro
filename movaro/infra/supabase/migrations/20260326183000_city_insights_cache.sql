create table if not exists public.city_insights_cache (
  cache_key text primary key,
  city_id text not null,
  goal text null,
  timeline text null,
  locale text not null default 'pt',
  source text not null default 'template',
  payload jsonb not null,
  expires_at timestamptz not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists city_insights_cache_city_id_idx
  on public.city_insights_cache (city_id);

create index if not exists city_insights_cache_expires_at_idx
  on public.city_insights_cache (expires_at);

create or replace function public.set_city_insights_cache_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists city_insights_cache_set_updated_at on public.city_insights_cache;

create trigger city_insights_cache_set_updated_at
before update on public.city_insights_cache
for each row
execute function public.set_city_insights_cache_updated_at();
