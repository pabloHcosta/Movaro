create table if not exists public.assistant_guide_answers (
  id uuid primary key default gen_random_uuid(),
  corridor_key text,
  destination_country text,
  section text not null,
  status text not null default 'draft',
  priority integer not null default 100,
  question_pt text,
  question_es text,
  question_en text,
  answer_pt text,
  answer_es text,
  answer_en text,
  keywords jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint assistant_guide_answers_status_check
    check (status in ('draft', 'published', 'archived')),
  constraint assistant_guide_answers_section_check
    check (section in ('documents', 'housing', 'health', 'work', 'driving', 'costs'))
);

create index if not exists assistant_guide_answers_status_priority_idx
  on public.assistant_guide_answers (status, priority desc);

create index if not exists assistant_guide_answers_corridor_destination_idx
  on public.assistant_guide_answers (corridor_key, destination_country);

drop trigger if exists trg_assistant_guide_answers_updated_at on public.assistant_guide_answers;
create trigger trg_assistant_guide_answers_updated_at
before update on public.assistant_guide_answers
for each row
execute function public.set_updated_at();

alter table public.assistant_guide_answers enable row level security;

drop policy if exists "Service role manages assistant guide answers" on public.assistant_guide_answers;
create policy "Service role manages assistant guide answers"
on public.assistant_guide_answers
for all
using (auth.role() = 'service_role')
with check (auth.role() = 'service_role');

insert into public.assistant_guide_answers (
  corridor_key,
  destination_country,
  section,
  status,
  priority,
  question_pt,
  question_es,
  question_en,
  answer_pt,
  answer_es,
  answer_en,
  keywords
)
values
  (
    'argentina->brasil',
    'brasil',
    'documents',
    'published',
    500,
    'Para viajar da Argentina ao Brasil eu preciso de passaporte?',
    '¿Para viajar de Argentina a Brasil necesito pasaporte?',
    'Do I need a passport to travel from Argentina to Brazil?',
    'Não necessariamente. Para argentinos, a viagem ao Brasil pode ser feita com DNI físico válido, em bom estado e com foto que permita identificar o titular.',
    'No necesariamente. Para argentinos, el viaje a Brasil puede hacerse con DNI físico válido, en buen estado y con foto que identifique claramente al titular.',
    'Not necessarily. Argentinians can usually travel to Brazil with a valid physical national ID in good condition and with a clear photo.',
    '{"pt":["passaporte","dni","documento para viajar","mercosul"],"es":["pasaporte","dni","documento para viajar","mercosur"],"en":["passport","dni","travel document","mercosur"]}'::jsonb
  ),
  (
    'argentina->brasil',
    'brasil',
    'documents',
    'published',
    490,
    'Só o CPF resolve banco e contrato?',
    '¿El CPF por sí solo resuelve banco y contrato?',
    'Does CPF alone solve banking and contracts?',
    'Não. O CPF ajuda bastante, mas normalmente não substitui um documento migratório regular.',
    'No. El CPF ayuda mucho, pero normalmente no reemplaza un documento migratorio regular.',
    'No. CPF helps a lot, but it usually does not replace regular migration documentation.',
    '{"pt":["cpf","banco","contrato","cadastro"],"es":["cpf","banco","contrato","registro"],"en":["cpf","bank","contract","registration"]}'::jsonb
  ),
  (
    'argentina->brasil',
    'brasil',
    'documents',
    'published',
    480,
    'Ficar mais tempo como visitante é o mesmo que morar de forma regular?',
    '¿Quedarse más tiempo como visitante es lo mismo que vivir de forma regular?',
    'Is staying longer as a visitor the same as living regularly?',
    'Não. Para quem vai viver no Brasil, a residência regular costuma ser o caminho certo.',
    'No. Para quien va a vivir en Brasil, la residencia regular suele ser el camino correcto.',
    'No. For someone planning to live in Brazil, regular residence is usually the right path.',
    '{"pt":["visitante","residencia","morar","permanencia"],"es":["visitante","residencia","vivir","permanencia"],"en":["visitor","residence","stay","live"]}'::jsonb
  ),
  (
    'argentina->brasil',
    'brasil',
    'health',
    'published',
    470,
    'Estrangeiro pode usar o SUS?',
    '¿Una persona extranjera puede usar el SUS?',
    'Can a foreign national use SUS?',
    'Sim. O SUS é universal no Brasil, e o acesso inicial não deveria depender de você já ter tudo pronto.',
    'Sí. El SUS es universal en Brasil, y el acceso inicial no debería depender de que ya tengas todo resuelto.',
    'Yes. SUS is universal in Brazil, and initial access should not depend on having every document already resolved.',
    '{"pt":["sus","saude","saúde","hospital"],"es":["sus","salud","hospital"],"en":["sus","health","hospital"]}'::jsonb
  ),
  (
    'argentina->brasil',
    'brasil',
    'driving',
    'published',
    460,
    'Posso dirigir com minha carteira estrangeira no começo?',
    '¿Puedo conducir al principio con mi licencia extranjera?',
    'Can I drive at first with my foreign license?',
    'Em regra, sim, por período limitado e com documento válido. Depois disso, vale confirmar com o Detran do estado.',
    'En general, sí, por un período limitado y con documento válido. Después conviene confirmar con el Detran del estado.',
    'In general, yes, for a limited period and with valid documents. After that, it is better to confirm with the state Detran.',
    '{"pt":["carteira estrangeira","detran","dirigir","cnh"],"es":["licencia extranjera","detran","conducir"],"en":["foreign license","detran","drive"]}'::jsonb
  ),
  (
    'argentina->brasil',
    'brasil',
    'work',
    'published',
    450,
    'Carteira assinada ainda existe? Como funciona?',
    '¿Todavía existe el trabajo formal registrado? ¿Cómo funciona?',
    'Does formal employment still exist, and how does it work?',
    'Sim. No trabalho formal pela CLT, o vínculo fica registrado e a Carteira de Trabalho Digital concentra o histórico laboral.',
    'Sí. En el trabajo formal por CLT, la relación queda registrada y la Carteira de Trabalho Digital concentra el historial laboral.',
    'Yes. In formal CLT employment, the relationship is registered and the Digital Work Card holds the work record.',
    '{"pt":["clt","carteira de trabalho","trabalho formal"],"es":["clt","trabajo registrado","carteira de trabalho"],"en":["clt","formal employment","work card"]}'::jsonb
  ),
  (
    'argentina->brasil',
    'brasil',
    'work',
    'published',
    440,
    'Dá para construir renda no mercado de trabalho brasileiro?',
    '¿Se puede construir ingresos en el mercado laboral brasileño?',
    'Is Brazil a good place to build income from work?',
    'Sim, mas a expectativa prática é de renda viável e crescimento gradual, não de salários excepcionalmente altos logo na chegada.',
    'Sí, pero la expectativa práctica es de ingreso viable y crecimiento gradual, no de salarios excepcionalmente altos apenas llegás.',
    'Yes, but the practical expectation is steady income and gradual growth, not exceptionally high pay right away.',
    '{"pt":["mercado de trabalho","salario","renda"],"es":["mercado laboral","salario","ingresos"],"en":["job market","salary","income"]}'::jsonb
  ),
  (
    'argentina->brasil',
    'brasil',
    'housing',
    'published',
    430,
    'Segurança no Brasil é igual em todo lugar?',
    '¿La seguridad en Brasil es igual en todos lados?',
    'Is safety in Brazil the same everywhere?',
    'Não. A segurança varia muito por estado, cidade, bairro e rotina diária.',
    'No. La seguridad varía mucho por estado, ciudad, barrio y rutina diaria.',
    'No. Safety varies a lot by state, city, neighborhood, and daily routine.',
    '{"pt":["seguranca","bairro","cidade segura"],"es":["seguridad","barrio","ciudad segura"],"en":["safety","neighborhood","safe city"]}'::jsonb
  )
on conflict do nothing;
