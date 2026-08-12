# Auditoria do fluxo de recomendação de cidades — v2

Data: 2026-08-11

## Objetivo

Reduzir esforço e erro de recomendação sem transformar a descoberta de cidade
em um cadastro longo. O resultado continua sendo uma shortlist explicável, não
uma promessa de que existe uma cidade universalmente “correta”.

## Diagnóstico do fluxo anterior

### Problemas de eficácia

1. O fluxo rápido usava `intent`, `timeline` e `priorities`. `timeline` muda o
   plano de execução, mas não participa do ranking da cidade. Em contrapartida,
   composição familiar e restrições duras — sinais que mudam custo, segurança,
   elegibilidade e shortlist — ficavam fora do caminho rápido.
2. O modo rápido era descrito como tendo quatro perguntas, mas tinha três quando
   origem e destino já estavam conhecidos.
3. O convite de refinamento dizia “uma pergunta extra”, embora pudesse abrir
   cinco ou seis etapas adicionais.
4. `constraints` misturava filtros realmente eliminatórios com preferências
   suaves. “Quero litoral”, “preciso de cidade grande”, “preciso de transporte”
   e “evitar cidades caras” alteram a elegibilidade; “prefiro o Sul” e “prefiro
   cidade média” apenas aplicavam penalidades. “Prefiro clima fresco” não tinha
   dado climático comparável e não alterava o score.
5. A opção “clima quente / praia” atribuía a maior parte do peso a uma dimensão
   climática sem dados. Isso criava uma promessa sem lastro. A interface agora
   fala em “litoral e praia” e o motor usa somente o sinal territorial disponível.
6. Opções importantes eram abreviadas para “Trabalho”, “Remoto”, “Família” e
   “Oferta”. Esses rótulos perdiam a diferença entre objetivo, fonte de renda e
   composição da mudança.
7. Um toque em qualquer resposta simples avançava imediatamente. A interação era
   rápida, mas escondia o estado selecionado antes de uma revisão e amplificava
   o custo de toques acidentais.

### Problemas de usabilidade e confiança

- A estimativa de tempo era calculada com 30–40 segundos por etapa e chegava a
  contradizer a promessa de “menos de um minuto”.
- O modo detalhado não estava disponível como escolha clara na entrada; aparecia
  apenas depois do caminho rápido.
- Havia até dez prioridades na mesma tela. Isso é aceitável como catálogo de
  atributos, mas selecionar três diluía o trade-off. O limite passou a dois.
- O usuário não conseguia distinguir perguntas que mudavam o ranking daquelas
  que personalizavam somente o plano posterior.

## Princípios adotados

1. **Valor de informação antes de volume:** perguntar primeiro o que pode trocar
   a cidade líder, eliminar uma candidata ou alterar materialmente o custo do
   domicílio.
2. **Uma decisão por tela:** cada etapa trata de um único conceito e mantém
   título, instrução e opções juntos.
3. **Progressive disclosure:** oferecer um começo curto e um aprofundamento
   explícito, com perguntas condicionais apenas quando a resposta anterior as
   torna relevante.
4. **Confirmação para decisões consequentes:** selecionar marca a opção; o botão
   “Continuar” confirma e avança. Voltar preserva a resposta.
5. **Sem precisão fictícia:** texto e score só devem falar de dimensões com sinal
   comparável. Incerteza, cobertura e estabilidade continuam visíveis no resultado.
6. **Respostas neutras válidas:** “não sei” e “nada disso” evitam respostas
   inventadas, mas permanecem exclusivas de outras escolhas.

## Novo desenho

### Entrada

Depois de “Descobrir cidades para mim”, o usuário escolhe:

- **Plano rápido (recomendado):** 4 perguntas essenciais, cerca de 1 minuto.
- **Recomendação detalhada:** 8 perguntas, com uma nona somente quando a fonte
  de recursos torna a reserva inicial relevante, cerca de 2–3 minutos.

Um rascunho existente retoma diretamente o modo e a etapa já escolhidos.

### Plano rápido

| Ordem | Pergunta | Por que entra antes do ranking |
|---|---|---|
| 1 | O que você busca nessa mudança? | Define pesos-base e regras especiais, como presença de universidade para estudo. |
| 2 | Como você vai fazer essa mudança? | Adultos e filhos alteram custo domiciliar, segurança e adequação familiar. |
| 3 | O que mais importa na escolha? (até 2) | Explicita o principal trade-off sem diluir peso em três ou mais desejos. |
| 4 | Existe algo que você não quer negociar? | Aplica filtros antes do ranking e evita sugerir cidade inviável. |

As restrições visíveis são apenas as que o motor consegue tratar como filtros:
litoral, cidade grande, transporte público verificado e pressão de custo, além
de “não tenho condições fixas”.

### Recomendação detalhada

Mantém as quatro respostas do modo rápido e adiciona:

1. tipo principal de trabalho/renda;
2. fonte de sustento nos primeiros meses;
3. reserva inicial, somente para reserva própria, apoio familiar ou indefinição;
4. pets, medicação contínua e veículo;
5. prazo aproximado da mudança.

Renda, reserva e prazo ajudam principalmente a tornar o plano executável. Pets,
medicação e veículo personalizam próximos passos e não recebem peso genérico de
cidade. Essa separação deve permanecer explícita na metodologia.

## Mudanças técnicas implementadas

- `QuestionnaireVariant.lean`: `intent`, `travel_group`, `priorities`,
  `constraints`.
- `QuestionnaireVariant.strategic`: núcleo rápido mais `work_arrangement`,
  `funding`, `available_capital` condicional, `support_needs` e `timeline`.
- Prioridades limitadas a duas.
- Remoção de preferências suaves/sem dados da tela de condições eliminatórias.
- Avanço automático desativado; seleção e confirmação são estados separados.
- Rótulos completos em objetivo, renda, composição familiar, necessidades e
  restrições; linhas suportam duas linhas e alvo mínimo de 52 px.
- Estimativa de 18 s por etapa rápida e 25 s por etapa detalhada.
- Metodologia do motor atualizada para `city-recommendation-v2.2.0`.
- A chave legada `warm_climate_beach` permanece compatível, mas passa a pontuar
  apenas `nature`/litoral. O produto não apresenta clima sem normais comparáveis.

## Referências que orientaram a decisão

- [W3C WAI — Forms Tutorial](https://www.w3.org/WAI/tutorials/forms/): pedir
  somente o necessário, oferecer instruções, alvos clicáveis amplos, validação,
  desfazer e progresso em formulários de múltiplas páginas.
- [GOV.UK Design System — Question pages](https://design-system.service.gov.uk/patterns/question-pages/):
  começar com uma pergunta por página para foco e compreensão.
- [GOV.UK Service Manual — Structuring forms](https://www.gov.uk/service-manual/design/form-structure):
  ordenar perguntas que evitam desperdício de tempo e dividir formulários em
  passos lógicos.
- [Pew Research Center — Writing Survey Questions](https://www.pewresearch.org/writing-survey-questions/):
  opções, redação e ordem alteram respostas; categorias fechadas devem ser
  testadas e efeitos de primazia precisam ser considerados.
- [IJCAI 2024 — Model-Free Preference Elicitation](https://www.ijcai.org/proceedings/2024/387):
  expected value of information como critério para escolher perguntas que mais
  aumentam utilidade da recomendação.
- [UAI 2024 — Cold-start Recommendation by Personalized Embedding Region Elicitation](https://proceedings.mlr.press/v244/nguyen24a.html):
  elicitação personalizada supera um conjunto fixo igual para todos os novos usuários.
- [Journal of Consumer Psychology — Choice overload meta-analysis](https://doi.org/10.1016/j.jcps.2014.08.002):
  complexidade, dificuldade, incerteza de preferência e objetivo moderam
  sobrecarga; portanto, reduzir escolhas é mais importante neste domínio de alta
  incerteza do que aplicar um limite universal de opções.
- [People + AI Guidebook worksheets](https://pair.withgoogle.com/worksheet/People%20%2B%20AI%20Guidebook%20-%20All%20Worksheets.pdf):
  decisões que o usuário deve verificar pedem explicação explícita e comunicação
  de incerteza.

## Validação recomendada

Não chamar aceitação de “acerto”. A cidade escolhida pode refletir familiaridade,
preço momentâneo ou viés de apresentação. Medir em três camadas:

### Instrumentação de funil

- início e conclusão por modo;
- abandono por pergunta;
- tempo por pergunta (mediana e p90);
- uso de voltar e troca de resposta;
- seleção de “não sei”/“nada disso”;
- refinamento aceito após resultado rápido.

### Qualidade offline

- suíte fixa de perfis com restrições e casos-limite;
- top-1, top-3 e filtros esperados revisados por especialista;
- estabilidade da primeira cidade sob variação de pesos;
- cobertura de dados por dimensão;
- ganho marginal de cada pergunta: comparar shortlist com e sem a resposta;
- teste de contradições, por exemplo estudo sem universidade ou litoral sem costa.

### Pesquisa com usuários

- teste moderado com 5–8 pessoas por idioma principal antes de experimento amplo;
- pergunta de compreensão (“por que esta cidade apareceu?”), não apenas gosto;
- confiança calibrada antes/depois de abrir motivos e limitações;
- acompanhamento posterior: cidade mantida, comparada ou descartada e motivo.

### Critérios iniciais de sucesso

- conclusão do rápido >= 80%;
- mediana <= 75 s no rápido e <= 180 s no detalhado;
- menos de 10% de retornos causados por toque acidental;
- nenhuma violação de restrição dura na shortlist;
- queda mensurável em feedback “não combina comigo” sem reduzir cobertura;
- estabilidade e cobertura exibidas, sem transformar score em probabilidade de acerto.

## Próxima evolução técnica

O passo de maior retorno é substituir a sequência estratégica fixa por seleção
adaptativa. Após as quatro respostas rápidas, a API deve simular o ranking com
cada pergunta candidata e pedir somente aquela com maior ganho esperado na
shortlist, parando quando a cidade líder estiver estável ou o ganho ficar abaixo
de um limiar. Isso exige logs agregados por versão, uma suíte offline e revisão
humana; cliques não devem recalibrar pesos automaticamente.
