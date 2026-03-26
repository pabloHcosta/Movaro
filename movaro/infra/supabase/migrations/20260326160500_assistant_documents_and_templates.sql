create table if not exists public.assistant_document_entries (
  id uuid primary key default gen_random_uuid(),
  document_code text not null,
  corridor_key text,
  status text not null default 'draft',
  priority integer not null default 100,
  phase text,
  title_pt text,
  title_es text,
  title_en text,
  summary_pt text,
  summary_es text,
  summary_en text,
  notes_pt text,
  notes_es text,
  notes_en text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint assistant_document_entries_status_check
    check (status in ('draft', 'published', 'archived'))
);

create unique index if not exists assistant_document_entries_code_corridor_unique_idx
  on public.assistant_document_entries (document_code, coalesce(corridor_key, '__global__'));

create index if not exists assistant_document_entries_status_priority_idx
  on public.assistant_document_entries (status, priority desc);

create table if not exists public.assistant_document_keywords (
  id uuid primary key default gen_random_uuid(),
  entry_id uuid not null references public.assistant_document_entries (id) on delete cascade,
  language_code text,
  keyword text not null,
  weight numeric(6,3) not null default 1,
  created_at timestamptz not null default timezone('utc', now()),
  constraint assistant_document_keywords_language_code_check
    check (language_code is null or language_code in ('pt', 'es', 'en'))
);

create index if not exists assistant_document_keywords_entry_idx
  on public.assistant_document_keywords (entry_id);

create index if not exists assistant_document_keywords_language_keyword_idx
  on public.assistant_document_keywords (language_code, keyword);

create table if not exists public.assistant_quick_prompt_templates (
  id uuid primary key default gen_random_uuid(),
  corridor_key text,
  prompt_key text not null,
  status text not null default 'draft',
  label_pt text,
  label_es text,
  label_en text,
  message_pt text,
  message_es text,
  message_en text,
  message_default text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint assistant_quick_prompt_templates_status_check
    check (status in ('draft', 'published', 'archived'))
);

create unique index if not exists assistant_quick_prompt_templates_key_corridor_unique_idx
  on public.assistant_quick_prompt_templates (prompt_key, coalesce(corridor_key, '__global__'));

drop trigger if exists trg_assistant_document_entries_updated_at on public.assistant_document_entries;
create trigger trg_assistant_document_entries_updated_at
before update on public.assistant_document_entries
for each row
execute function public.set_updated_at();

drop trigger if exists trg_assistant_quick_prompt_templates_updated_at on public.assistant_quick_prompt_templates;
create trigger trg_assistant_quick_prompt_templates_updated_at
before update on public.assistant_quick_prompt_templates
for each row
execute function public.set_updated_at();

alter table public.assistant_document_entries enable row level security;
alter table public.assistant_document_keywords enable row level security;
alter table public.assistant_quick_prompt_templates enable row level security;

drop policy if exists "Service role manages assistant document entries" on public.assistant_document_entries;
create policy "Service role manages assistant document entries"
on public.assistant_document_entries
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

drop policy if exists "Service role manages assistant document keywords" on public.assistant_document_keywords;
create policy "Service role manages assistant document keywords"
on public.assistant_document_keywords
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

drop policy if exists "Service role manages assistant quick prompt templates" on public.assistant_quick_prompt_templates;
create policy "Service role manages assistant quick prompt templates"
on public.assistant_quick_prompt_templates
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

with cpf as (
  insert into public.assistant_document_entries (
    document_code, corridor_key, status, priority, phase,
    title_pt, title_es, title_en,
    summary_pt, summary_es, summary_en,
    notes_pt, notes_es, notes_en
  )
  values (
    'doc-01', 'argentina->brasil', 'published', 500, 'documents',
    'Obter CPF', 'Obtener CPF', 'Get CPF',
    'Organizar o CPF cedo destrava banco, aluguel, contratos e trabalho formal no Brasil.',
    'Resolver el CPF temprano destraba banco, alquiler, contratos y trabajo formal en Brasil.',
    'Getting CPF early unlocks banking, rent, contracts, and formal work in Brazil.',
    'Vale resolver isso antes de depender de etapas mais pesadas.',
    'Conviene resolver esto antes de depender de trámites más pesados.',
    'This should be done before heavier execution steps.'
  )
  on conflict do nothing
  returning id
),
residency as (
  insert into public.assistant_document_entries (
    document_code, corridor_key, status, priority, phase,
    title_pt, title_es, title_en,
    summary_pt, summary_es, summary_en,
    notes_pt, notes_es, notes_en
  )
  values (
    'doc-02', 'argentina->brasil', 'published', 490, 'documents',
    'Solicitar residência MERCOSUL', 'Solicitar residencia MERCOSUR', 'Apply for MERCOSUR residency',
    'Para argentinos no Brasil, a regularização costuma passar pela rota de residência MERCOSUL.',
    'Para argentinos en Brasil, la regularización suele pasar por la vía de residencia MERCOSUR.',
    'For Argentinians in Brazil, regularization usually goes through the MERCOSUR residency path.',
    'Não trate isso como pergunta genérica de turismo se o plano já é de mudança.',
    'No lo trates como una consulta genérica de turismo si el plan ya es de mudanza.',
    'Do not treat this as a generic tourism question if the plan is already relocation.'
  )
  on conflict do nothing
  returning id
),
apostille as (
  insert into public.assistant_document_entries (
    document_code, corridor_key, status, priority, phase,
    title_pt, title_es, title_en,
    summary_pt, summary_es, summary_en,
    notes_pt, notes_es, notes_en
  )
  values (
    'prep-04', 'argentina->brasil', 'published', 470, 'preparation',
    'Separar documentos apostiláveis', 'Separar documentos apostillables', 'Separate apostille-ready documents',
    'Antecedentes, certidões e documentos pessoais devem ser separados cedo se houver chance de exigirem apostila ou tradução.',
    'Antecedentes, partidas y documentos personales deben separarse temprano si existe chance de apostilla o traducción.',
    'Criminal records, certificates, and personal records should be separated early if apostille or sworn translation may be required.',
    'Isso reduz atraso quando o processo migratório apertar.',
    'Esto reduce retraso cuando el proceso migratorio se acelera.',
    'This reduces delays once the migration process becomes time-sensitive.'
  )
  on conflict do nothing
  returning id
)
insert into public.assistant_document_keywords (entry_id, language_code, keyword, weight)
select id, null, keyword, weight
from cpf,
unnest(array['cpf','cadastro de pessoa física','cadastro pessoa']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord = 1 then 1.5 else 1.0 end as weight) weights
union all
select id, null, keyword, weight
from residency,
unnest(array['residência','residencia','residency','mercosul','mercosur','visto','visa']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord in (4,5) then 1.4 else 1.0 end as weight) weights
union all
select id, null, keyword, weight
from apostille,
unnest(array['apostila','apostille','antecedentes','tradução','traduccion']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord in (1,2) then 1.4 else 1.0 end as weight) weights;

insert into public.assistant_quick_prompt_templates (
  corridor_key, prompt_key, status,
  label_pt, label_es, label_en,
  message_pt, message_es, message_en, message_default
)
values (
  'argentina->brasil',
  'first_local_document',
  'published',
  'Como tirar o CPF?',
  '¿Cómo obtener mi CPF?',
  'How do I get my CPF?',
  'Como tirar o CPF?',
  '¿Cómo obtener mi CPF?',
  'How do I get my CPF?',
  'How do I get my first local document?'
), (
  null,
  'first_local_document',
  'published',
  'Primeiro documento local',
  'Primer documento local',
  'First local document',
  'Qual é o primeiro documento local que eu deveria resolver ao chegar?',
  '¿Cuál es el primer documento local que debería resolver al llegar?',
  'What is the first local document I should sort out after arrival?',
  'What is the first local document I should sort out after arrival?'
)
on conflict do nothing;
