create table if not exists public.assistant_language_rules (
  id uuid primary key default gen_random_uuid(),
  language_code text not null,
  priority integer not null default 100,
  keyword_patterns jsonb not null default '[]'::jsonb,
  regex_patterns jsonb not null default '[]'::jsonb,
  fallback_language_code text not null default 'en',
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint assistant_language_rules_language_code_check
    check (language_code in ('pt', 'es', 'en'))
);

create unique index if not exists assistant_language_rules_language_code_unique_idx
  on public.assistant_language_rules (language_code)
  where is_active = true;

create table if not exists public.assistant_faq_entries (
  id uuid primary key default gen_random_uuid(),
  slug text not null,
  corridor_key text,
  status text not null default 'draft',
  priority integer not null default 100,
  answer_pt text,
  answer_es text,
  answer_en text,
  answer_default text,
  tags text[] not null default '{}',
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint assistant_faq_entries_status_check
    check (status in ('draft', 'published', 'archived'))
);

create unique index if not exists assistant_faq_entries_slug_corridor_unique_idx
  on public.assistant_faq_entries (slug, coalesce(corridor_key, '__global__'));

create index if not exists assistant_faq_entries_status_priority_idx
  on public.assistant_faq_entries (status, priority desc);

create table if not exists public.assistant_faq_keywords (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid not null references public.assistant_faq_entries (id) on delete cascade,
  language_code text,
  keyword text not null,
  weight numeric(6,3) not null default 1,
  created_at timestamptz not null default timezone('utc', now()),
  constraint assistant_faq_keywords_language_code_check
    check (language_code is null or language_code in ('pt', 'es', 'en'))
);

create index if not exists assistant_faq_keywords_entry_idx
  on public.assistant_faq_keywords (entry_id);

create index if not exists assistant_faq_keywords_language_keyword_idx
  on public.assistant_faq_keywords (language_code, keyword);

drop trigger if exists trg_assistant_language_rules_updated_at on public.assistant_language_rules;
create trigger trg_assistant_language_rules_updated_at
before update on public.assistant_language_rules
for each row
execute function public.set_updated_at();

drop trigger if exists trg_assistant_faq_entries_updated_at on public.assistant_faq_entries;
create trigger trg_assistant_faq_entries_updated_at
before update on public.assistant_faq_entries
for each row
execute function public.set_updated_at();

alter table public.assistant_language_rules enable row level security;
alter table public.assistant_faq_entries enable row level security;
alter table public.assistant_faq_keywords enable row level security;

drop policy if exists "Service role manages assistant language rules" on public.assistant_language_rules;
create policy "Service role manages assistant language rules"
on public.assistant_language_rules
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

drop policy if exists "Service role manages assistant faq entries" on public.assistant_faq_entries;
create policy "Service role manages assistant faq entries"
on public.assistant_faq_entries
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

drop policy if exists "Service role manages assistant faq keywords" on public.assistant_faq_keywords;
create policy "Service role manages assistant faq keywords"
on public.assistant_faq_keywords
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

insert into public.assistant_language_rules (
  language_code,
  priority,
  keyword_patterns,
  regex_patterns,
  fallback_language_code,
  is_active
)
values
  (
    'pt',
    300,
    '["como","quais","quanto","preciso","documentos","moradia","trabalho","cidade","visto","cpf","para","com","não","quero"]'::jsonb,
    '["\\\\b(voc[eê]|vocês|pra|não|quão|moradia|alugu[eé]l)\\\\b"]'::jsonb,
    'en',
    true
  ),
  (
    'es',
    300,
    '["como","cuáles","cuanto","necesito","documentos","vivienda","trabajo","ciudad","visa","residencia","para","con","quiero"]'::jsonb,
    '["\\\\b(necesit[oá]s|quer[eé]s|vivienda|alquiler|cu[aá]l|cu[aá]nto)\\\\b"]'::jsonb,
    'en',
    true
  ),
  (
    'en',
    250,
    '["how","what","which","need","documents","housing","work","city","visa","cost","move","rent","job"]'::jsonb,
    '["\\\\b(how|what|which|where|need|housing|documents|move|rent|job)\\\\b"]'::jsonb,
    'en',
    true
  )
on conflict do nothing;

with adaptation as (
  insert into public.assistant_faq_entries (
    slug,
    corridor_key,
    status,
    priority,
    answer_pt,
    answer_es,
    answer_en,
    answer_default,
    tags
  )
  values (
    'cultural_adaptation',
    'argentina->brasil',
    'published',
    500,
    'A adaptação de argentinos no Brasil costuma ser tranquila. O maior atrito tende a estar na burocracia inicial, não na cultura. Português, rotina social, mercado e primeiras redes de apoio costumam ser os pontos mais práticos para ajustar no começo.',
    'La adaptación de argentinos en Brasil suele ser fluida. El mayor roce suele estar en la burocracia inicial, no en la cultura. Portugués, rutina social, mercado y primeras redes de apoyo suelen ser los puntos más prácticos para ajustar al comienzo.',
    'Argentinians usually adapt well in Brazil. The biggest friction is usually early bureaucracy, not culture. Portuguese, social rhythm, shopping routines, and first support networks are the most practical things to adjust first.',
    'Argentinians usually adapt well in Brazil. The biggest friction is early bureaucracy, not culture.',
    '{"adaptation","culture"}'
  )
  on conflict do nothing
  returning id
),
language_learning as (
  insert into public.assistant_faq_entries (
    slug,
    corridor_key,
    status,
    priority,
    answer_pt,
    answer_es,
    answer_en,
    answer_default,
    tags
  )
  values (
    'learn_portuguese',
    'argentina->brasil',
    'published',
    480,
    'Para argentinos, aprender português tende a ser uma adaptação rápida. O maior ganho vem de usar português desde o primeiro dia, consumir conteúdo brasileiro e praticar fala no contexto real de trabalho, banco e moradia.',
    'Para argentinos, aprender portugués suele ser una adaptación rápida. La mayor ganancia viene de usar portugués desde el primer día, consumir contenido brasileño y practicar habla en contextos reales de trabajo, banco y vivienda.',
    'For Argentinians, learning Portuguese is usually a fast adaptation. The biggest gain comes from using Portuguese from day one, consuming Brazilian content, and practicing in real work, banking, and housing situations.',
    'For Argentinians, learning Portuguese is usually a fast adaptation.',
    '{"language","portuguese"}'
  )
  on conflict do nothing
  returning id
),
healthcare as (
  insert into public.assistant_faq_entries (
    slug,
    corridor_key,
    status,
    priority,
    answer_pt,
    answer_es,
    answer_en,
    answer_default,
    tags
  )
  values (
    'healthcare_brazil',
    'argentina->brasil',
    'published',
    470,
    'No Brasil, o SUS é a porta pública de atendimento. Para quem está chegando, o melhor é organizar CPF e comprovante de endereço assim que possível para facilitar cadastro e continuidade no atendimento.',
    'En Brasil, el SUS es la puerta pública de atención. Para quien está llegando, lo mejor es organizar CPF y comprobante de domicilio cuanto antes para facilitar registro y continuidad de atención.',
    'In Brazil, SUS is the public health entry point. For new arrivals, the best move is to organize CPF and proof of address as early as possible to make registration and continuity of care easier.',
    'In Brazil, SUS is the public health entry point.',
    '{"health","sus"}'
  )
  on conflict do nothing
  returning id
)
insert into public.assistant_faq_keywords (entry_id, language_code, keyword, weight)
select id, 'pt', keyword, weight
from adaptation,
unnest(array['adaptação','cultura','costumes','viver no brasil']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord = 1 then 1.4 else 1.0 end as weight) weights
union all
select id, 'es', keyword, weight
from adaptation,
unnest(array['adaptación','cultura','costumbres','vivir en brasil']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord = 1 then 1.4 else 1.0 end as weight) weights
union all
select id, 'en', keyword, weight
from adaptation,
unnest(array['adaptation','culture','customs','live in brazil']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord = 1 then 1.4 else 1.0 end as weight) weights
union all
select id, 'pt', keyword, 1.0
from language_learning,
unnest(array['idioma','língua','português','aprender']) as kw(keyword)
union all
select id, 'es', keyword, 1.0
from language_learning,
unnest(array['idioma','portugués','aprender','portuñol']) as kw(keyword)
union all
select id, 'en', keyword, 1.0
from language_learning,
unnest(array['language','portuguese','learn']) as kw(keyword)
union all
select id, 'pt', keyword, 1.0
from healthcare,
unnest(array['saúde','sus','hospital','médico']) as kw(keyword)
union all
select id, 'es', keyword, 1.0
from healthcare,
unnest(array['salud','sus','hospital','médico']) as kw(keyword)
union all
select id, 'en', keyword, 1.0
from healthcare,
unnest(array['health','sus','hospital','doctor']) as kw(keyword);
