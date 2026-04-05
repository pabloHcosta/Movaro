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
    'uruguai->brasil',
    'brasil',
    'documents',
    'published',
    500,
    'Para me mudar do Uruguai ao Brasil, a cédula uruguaia basta?',
    '¿Para mudarme de Uruguay a Brasil alcanza con la cédula uruguaya?',
    'If I am moving from Uruguay to Brazil, is my Uruguayan ID enough?',
    'Para turismo no Mercosul, a Polícia Federal informa que a cédula de identidade pode bastar. Mas, para mudança, residência, estudo ou trabalho, a orientação oficial é tratar a viagem como não turística e confirmar o uso de passaporte válido e a estratégia migratória antes de embarcar.',
    'Para turismo en el Mercosur, la Policía Federal informa que la cédula de identidad puede alcanzar. Pero para mudanza, residencia, estudio o trabajo, la orientación oficial es tratar el viaje como no turístico y confirmar el uso de pasaporte válido y la estrategia migratoria antes de viajar.',
    'For Mercosur tourism, the Federal Police says an identity card may be enough. But for relocation, residence, study, or work, the official guidance is to treat the trip as non-tourism and confirm the use of a valid passport and the migration strategy before travel.',
    '{"pt":["cedula","cédula","passaporte","documento de viagem","mudança","mudar para o brasil"],"es":["cedula","cédula","pasaporte","documento de viaje","mudanza"],"en":["id card","passport","travel document","move to brazil"]}'::jsonb
  ),
  (
    'uruguai->brasil',
    'brasil',
    'documents',
    'published',
    490,
    'Uruguaios podem usar a residência Mercosul no Brasil?',
    '¿Las personas uruguayas pueden usar la residencia Mercosur en Brasil?',
    'Can Uruguayan citizens use Mercosur residence in Brazil?',
    'Sim. A Polícia Federal inclui o Uruguai no Acordo de Residência do Mercosul. Isso normalmente coloca a residência Mercosul como a principal rota de regularização para quem vai viver no Brasil.',
    'Sí. La Policía Federal incluye a Uruguay en el Acuerdo de Residencia del Mercosur. Eso normalmente convierte a la residencia Mercosur en la principal vía de regularización para quien va a vivir en Brasil.',
    'Yes. The Federal Police includes Uruguay in the Mercosur Residence Agreement. That usually makes Mercosur residence the main regularization path for someone planning to live in Brazil.',
    '{"pt":["mercosul","residência","residencia","regularização"],"es":["mercosur","residencia","regularizacion"],"en":["mercosur","residence","regularization"]}'::jsonb
  ),
  (
    'uruguai->brasil',
    'brasil',
    'documents',
    'published',
    480,
    'Como fica o CPF para estrangeiro vindo do Uruguai?',
    '¿Cómo funciona el CPF para una persona extranjera que viene de Uruguay?',
    'How does CPF work for a foreign national coming from Uruguay?',
    'O CPF continua sendo uma das primeiras chaves práticas no Brasil. A Receita Federal permite inscrição de estrangeiros, inclusive não residentes, mas os documentos aceitos variam conforme a situação migratória e o local do pedido, então vale conferir o canal certo antes de sair protocolando.',
    'El CPF sigue siendo una de las primeras llaves prácticas en Brasil. La Receita Federal permite la inscripción de personas extranjeras, incluso no residentes, pero los documentos aceptados varían según la situación migratoria y el canal de solicitud.',
    'CPF remains one of the first practical keys in Brazil. The Federal Revenue service allows foreign nationals, including non-residents, to enroll, but accepted documents vary by migration status and request channel.',
    '{"pt":["cpf","receita federal","cadastro","estrangeiro"],"es":["cpf","receita federal","registro","extranjero"],"en":["cpf","tax id","foreigner","federal revenue"]}'::jsonb
  ),
  (
    'uruguai->brasil',
    'brasil',
    'housing',
    'published',
    470,
    'Para aluguel no começo, o que costuma travar mais?',
    '¿Para alquilar al principio, qué suele trabar más?',
    'What usually blocks rent at the beginning?',
    'No começo, o atrito costuma estar menos em “achar imóvel” e mais em comprovação: CPF, documento migratório, garantia, caução ou fiador. Por isso, para chegada, a estratégia mais segura ainda é moradia temporária antes do aluguel estável.',
    'Al principio, el roce suele estar menos en “encontrar inmueble” y más en la comprobación: CPF, documento migratorio, garantía, depósito o fiador. Por eso, para llegar, la estrategia más segura sigue siendo vivienda temporal antes del alquiler estable.',
    'At the beginning, the friction is usually less about finding a property and more about proof: CPF, migration documents, guarantee, deposit, or guarantor. That is why temporary housing first is still the safer arrival strategy.',
    '{"pt":["aluguel","caução","fiador","moradia temporária"],"es":["alquiler","deposito","garantia","vivienda temporal"],"en":["rent","deposit","guarantor","temporary housing"]}'::jsonb
  ),
  (
    'uruguai->brasil',
    'brasil',
    'health',
    'published',
    460,
    'Quem vem do Uruguai pode usar o SUS?',
    '¿Quien llega desde Uruguay puede usar el SUS?',
    'Can someone arriving from Uruguay use SUS?',
    'Sim. O SUS é a porta pública de saúde no Brasil. Na prática, organizar CPF e comprovante de endereço ajuda muito no cadastro e na continuidade do atendimento, mas urgência não deveria depender de você já ter tudo resolvido.',
    'Sí. El SUS es la puerta pública de salud en Brasil. En la práctica, organizar CPF y comprobante de domicilio ayuda mucho para el registro y la continuidad de atención, pero una urgencia no debería depender de tener todo resuelto.',
    'Yes. SUS is the public health entry point in Brazil. In practice, organizing CPF and proof of address helps a lot with registration and continuity of care, but urgent care should not depend on having every document already solved.',
    '{"pt":["sus","saúde","hospital","posto de saúde"],"es":["sus","salud","hospital","centro de salud"],"en":["sus","health","hospital","clinic"]}'::jsonb
  ),
  (
    'uruguai->brasil',
    'brasil',
    'driving',
    'published',
    450,
    'Dá para dirigir no começo com habilitação uruguaia?',
    '¿Se puede conducir al principio con licencia uruguaya?',
    'Can I drive at first with a Uruguayan license?',
    'Em geral, sim, por período limitado e com permanência regular. Detrans estaduais costumam trabalhar com a lógica de até 180 dias para uso inicial da habilitação estrangeira válida, e depois vale confirmar convalidação ou exigências locais no estado onde você vai morar.',
    'En general, sí, por un período limitado y con permanencia regular. Los Detran estatales suelen trabajar con la lógica de hasta 180 días para uso inicial de una licencia extranjera válida, y después conviene confirmar la convalidación en el estado donde vas a vivir.',
    'In general, yes, for a limited period and with regular stay. State Detrans usually work with up to 180 days for initial use of a valid foreign license, and after that it is better to confirm conversion rules in the state where you will live.',
    '{"pt":["cnh","habilitação uruguaia","dirigir","detran"],"es":["licencia uruguaya","conducir","detran"],"en":["uruguayan license","drive","detran"]}'::jsonb
  ),
  (
    'uruguai->brasil',
    'brasil',
    'work',
    'published',
    440,
    'Para trabalhar formalmente no Brasil, o que costuma vir primeiro?',
    '¿Para trabajar formalmente en Brasil, qué suele venir primero?',
    'What usually comes first for formal work in Brazil?',
    'No plano prático, a ordem costuma ser: CPF, base migratória regular, conta bancária e depois os registros ligados ao trabalho formal, como Carteira de Trabalho Digital quando o vínculo exigir.',
    'En el plano práctico, el orden suele ser: CPF, base migratoria regular, cuenta bancaria y después los registros ligados al trabajo formal, como la Carteira de Trabalho Digital cuando la relación lo exija.',
    'In practical terms, the sequence is usually: CPF, regular migration status, bank account, and then the records tied to formal employment, such as the Digital Work Card when the role requires it.',
    '{"pt":["trabalho formal","clt","carteira de trabalho","conta bancária"],"es":["trabajo formal","clt","carteira de trabalho","cuenta bancaria"],"en":["formal work","clt","work card","bank account"]}'::jsonb
  ),
  (
    'uruguai->brasil',
    'brasil',
    'costs',
    'published',
    430,
    'Qual é a leitura mais realista de custo para mudar do Uruguai ao Brasil?',
    '¿Cuál es la lectura más realista de costos para mudarse de Uruguay a Brasil?',
    'What is the most realistic cost view for moving from Uruguay to Brazil?',
    'A leitura mais segura continua em três blocos: chegada, entrada em moradia e vida mensal. Na prática, a moradia costuma concentrar o atrito maior por causa de caução, garantia e instalação inicial.',
    'La lectura más segura sigue en tres bloques: llegada, entrada en vivienda y vida mensual. En la práctica, la vivienda suele concentrar el mayor roce por depósito, garantía e instalación inicial.',
    'The safest reading still starts in three blocks: arrival, housing move-in, and monthly life. In practice, housing usually concentrates the biggest friction because of deposit, guarantees, and setup costs.',
    '{"pt":["custos","orçamento","caução","mudança"],"es":["costos","presupuesto","deposito","mudanza"],"en":["costs","budget","deposit","moving"]}'::jsonb
  )
on conflict do nothing;

with cpf as (
  insert into public.assistant_document_entries (
    document_code, corridor_key, status, priority, phase,
    title_pt, title_es, title_en,
    summary_pt, summary_es, summary_en,
    notes_pt, notes_es, notes_en
  )
  values (
    'doc-01', 'uruguai->brasil', 'published', 500, 'documents',
    'Organizar CPF', 'Resolver CPF', 'Sort out CPF',
    'Para quem vem do Uruguai, o CPF segue sendo um dos primeiros destravadores práticos para banco, aluguel e contratos no Brasil.',
    'Para quien viene de Uruguay, el CPF sigue siendo uno de los primeros desbloqueos prácticos para banco, alquiler y contratos en Brasil.',
    'For someone coming from Uruguay, CPF remains one of the first practical unlocks for banking, rent, and contracts in Brazil.',
    'A Receita Federal aceita inscrição de estrangeiros, mas o canal e a documentação variam conforme a situação migratória.',
    'La Receita Federal acepta la inscripción de extranjeros, pero el canal y la documentación varían según la situación migratoria.',
    'The Federal Revenue service accepts foreign enrollment, but the channel and documents vary with migration status.'
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
    'doc-02', 'uruguai->brasil', 'published', 490, 'documents',
    'Revisar residência Mercosul', 'Revisar residencia Mercosur', 'Review Mercosur residence',
    'Para uruguaios que vão morar no Brasil, a residência Mercosul tende a ser a base principal de regularização.',
    'Para personas uruguayas que van a vivir en Brasil, la residencia Mercosur suele ser la base principal de regularización.',
    'For Uruguayans planning to live in Brazil, Mercosur residence tends to be the main regularization path.',
    'Vale tratar isso como etapa migratória central, e não como dúvida genérica de turismo.',
    'Conviene tratar esto como una etapa migratoria central y no como una duda genérica de turismo.',
    'This should be treated as a central migration step, not as a generic tourism question.'
  )
  on conflict do nothing
  returning id
),
driving as (
  insert into public.assistant_document_entries (
    document_code, corridor_key, status, priority, phase,
    title_pt, title_es, title_en,
    summary_pt, summary_es, summary_en,
    notes_pt, notes_es, notes_en
  )
  values (
    'arr-03', 'uruguai->brasil', 'published', 460, 'arrival',
    'Confirmar uso inicial da habilitação uruguaia', 'Confirmar uso inicial de la licencia uruguaya', 'Confirm initial use of the Uruguayan license',
    'A habilitação uruguaia válida costuma servir no começo, mas o prazo e a convalidação precisam ser confirmados no Detran do estado onde você vai morar.',
    'La licencia uruguaya válida suele servir al principio, pero el plazo y la convalidación deben confirmarse en el Detran del estado donde vas a vivir.',
    'A valid Uruguayan license usually works at first, but the time window and conversion process should be confirmed with the Detran of the state where you will live.',
    'Evite assumir que a regra operacional é igual em todos os estados sem checagem local.',
    'Evitá asumir que la regla operativa es igual en todos los estados sin chequeo local.',
    'Do not assume the operational rule is identical in every state without a local check.'
  )
  on conflict do nothing
  returning id
),
banking as (
  insert into public.assistant_document_entries (
    document_code, corridor_key, status, priority, phase,
    title_pt, title_es, title_en,
    summary_pt, summary_es, summary_en,
    notes_pt, notes_es, notes_en
  )
  values (
    'wor-01', 'uruguai->brasil', 'published', 450, 'work',
    'Abrir conta bancária com base regular', 'Abrir cuenta bancaria con base regular', 'Open a bank account with regular status',
    'Conta bancária costuma depender de CPF e, em muitos casos, de documentação migratória coerente com sua permanência no Brasil.',
    'La cuenta bancaria suele depender de CPF y, en muchos casos, de documentación migratoria coherente con tu permanencia en Brasil.',
    'A bank account usually depends on CPF and, in many cases, migration documents consistent with your stay in Brazil.',
    'Por isso, banco entra melhor depois do primeiro bloco documental.',
    'Por eso, el banco encaja mejor después del primer bloque documental.',
    'That is why banking fits better after the first document block.'
  )
  on conflict do nothing
  returning id
)
insert into public.assistant_document_keywords (entry_id, language_code, keyword, weight)
select id, null, keyword, weight
from cpf,
unnest(array['cpf','receita federal','cadastro','estrangeiro']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord = 1 then 1.5 else 1.0 end as weight) weights
union all
select id, null, keyword, weight
from residency,
unnest(array['mercosul','mercosur','residência','residencia','regularização','regularizacion']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord in (1,2) then 1.4 else 1.0 end as weight) weights
union all
select id, null, keyword, weight
from driving,
unnest(array['cnh','habilitação uruguaia','licencia uruguaya','detran','dirigir']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord in (1,4) then 1.3 else 1.0 end as weight) weights
union all
select id, null, keyword, weight
from banking,
unnest(array['conta bancária','cuenta bancaria','bank account','banco']) with ordinality as kw(keyword, ord)
cross join lateral (select case when ord = 1 then 1.3 else 1.0 end as weight) weights;

insert into public.assistant_quick_prompt_templates (
  corridor_key, prompt_key, status,
  label_pt, label_es, label_en,
  message_pt, message_es, message_en, message_default
)
values (
  'uruguai->brasil',
  'first_local_document',
  'published',
  'Primeiro documento local',
  'Primer documento local',
  'First local document',
  'Qual é o primeiro documento local que eu deveria resolver ao chegar no Brasil saindo do Uruguai?',
  '¿Cuál es el primer documento local que debería resolver al llegar a Brasil desde Uruguay?',
  'What is the first local document I should sort out after arriving in Brazil from Uruguay?',
  'What is the first local document I should sort out after arriving in Brazil?'
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
    'uruguai->brasil',
    'published',
    430,
    'Para quem sai do Uruguai rumo ao Brasil, a adaptação costuma passar mais por burocracia prática, idioma e ajuste de rotina do que por ruptura cultural forte.',
    'Para quien sale de Uruguay hacia Brasil, la adaptación suele pasar más por burocracia práctica, idioma y ajuste de rutina que por una ruptura cultural fuerte.',
    'For someone moving from Uruguay to Brazil, adaptation usually depends more on practical bureaucracy, language, and routine adjustment than on a major cultural rupture.',
    'Adaptation usually depends more on practical bureaucracy, language, and routine adjustment.',
    '{"adaptation","culture"}'
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
    'uruguai->brasil',
    'published',
    420,
    'No Brasil, o SUS continua sendo a porta pública de saúde. Para chegada organizada, vale destravar CPF e comprovante de endereço cedo, sem tratar urgência como algo que depende de documentação perfeita.',
    'En Brasil, el SUS sigue siendo la puerta pública de salud. Para una llegada organizada, conviene resolver CPF y comprobante de domicilio temprano, sin tratar una urgencia como algo que dependa de documentación perfecta.',
    'In Brazil, SUS remains the public health entry point. For an organized arrival, it helps to sort out CPF and proof of address early, without treating urgent care as something that depends on perfect paperwork.',
    'In Brazil, SUS remains the public health entry point.',
    '{"health","sus"}'
  )
  on conflict do nothing
  returning id
)
insert into public.assistant_faq_keywords (entry_id, language_code, keyword, weight)
select id, 'pt', keyword, 1.0
from adaptation,
unnest(array['adaptação','idioma','cultura','rotina']) as kw(keyword)
union all
select id, 'es', keyword, 1.0
from adaptation,
unnest(array['adaptación','idioma','cultura','rutina']) as kw(keyword)
union all
select id, 'en', keyword, 1.0
from adaptation,
unnest(array['adaptation','language','culture','routine']) as kw(keyword)
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
