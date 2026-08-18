# Motor de recomendação de cidades v2

## Objetivo

O motor oferece uma shortlist inicial para apoiar uma decisão. Ele não declara
uma cidade como escolha universalmente correta e não substitui validação
financeira, acadêmica ou profissional feita pelo usuário.

## Autoridade e versão

- A API é a única autoridade de filtro, cálculo, ordenação e evidência.
- O aplicativo não mantém um ranking personalizado alternativo ou fallback.
- A versão P2 é `city-recommendation-v2.3.0`.
- Cada execução recebe um `recommendationId` aleatório, salvo apenas junto ao
  plano local para diagnóstico e suporte futuro. Esse identificador não é
  enviado à telemetria.

## Entradas utilizadas

- objetivo da mudança;
- prioridades declaradas;
- restrições obrigatórias;
- fonte de renda e regime de trabalho;
- grupo de viagem e quantidade de filhos;
- faixa de capital disponível;
- coordenada de origem reduzida a precisão municipal.

Necessidades de suporte são usadas para adaptar o plano e só entram no motor
quando representam uma necessidade material verificável, como composição
familiar. Elas não são convertidas genericamente em preferência de cidade.

## Filtros e dimensões

Restrições obrigatórias são aplicadas antes do ranking. O motor não relaxa um
filtro silenciosamente para completar três resultados.

As dimensões só participam quando existe sinal comparável. Uma dimensão ausente
é retirada e gera aviso; não é estimada por população, latitude ou outro proxy
não validado.

## Avaliação de estabilidade P2

Depois do ranking principal, a API executa cenários de sensibilidade variando em
25% o peso de cada dimensão ativa, uma por vez, para cima e para baixo.

O resultado recebe:

- `stabilityBand`: estabilidade da primeira cidade sob essas variações;
- `scoreSeparationBand`: separação qualitativa entre as duas primeiras;
- `reliabilityBand`: composição qualitativa de estabilidade, cobertura de dados
  e completude do perfil;
- `scenariosEvaluated`: quantidade de cenários efetivamente calculados.

Essas faixas não são probabilidades de acerto. O aplicativo não mostra
percentuais de compatibilidade.

## Refinamento adaptativo P2

Depois do núcleo rápido de quatro perguntas, o motor simula os rankings possíveis
para cada atributo ainda não respondido que afeta a ordenação. A discriminação
esperada combina mudança da cidade líder (70%) e deslocamento do top 3 (30%).
Entre `work_arrangement` e `available_capital`, somente o atributo com maior ganho
é elegível, e no máximo uma pergunta adicional é feita.

O limiar varia com a separação entre as cidades líderes: disputas próximas
aceitam ganhos menores; lideranças claras exigem ganho maior. O motor encerra o
refinamento com `stable`, `low_gain` ou `no_candidates` quando perguntar não
justifica o custo de interação. Como os cenários têm pesos uniformes e não uma
distribuição longitudinal observada, `discriminationGain` não representa
probabilidade de acerto.

## Observabilidade e feedback

Eventos de recomendação dependem do consentimento de diagnóstico do usuário.
São enviados apenas:

- nome do evento;
- versão da metodologia;
- faixa de estabilidade;
- faixa de cobertura;
- posição escolhida entre 1 e 3;
- status do refinamento, pergunta selecionada, faixa de ganho e quantidade de
  cenários avaliados;
- horário e token aleatório da instalação.

Não são enviados cidade, respostas, orçamento, localização, documentos,
`recommendationId` ou dados de conta.

Feedback positivo ou negativo serve para avaliação agregada por versão. Ele não
altera pesos automaticamente. Qualquer ajuste de metodologia exige análise
offline, revisão humana, nova versão e testes de regressão.

## Critérios de evolução

Uma nova versão deve:

1. manter uma suíte fixa de perfis e restrições;
2. comparar mudanças de shortlist e filtros;
3. revisar cobertura e atualização das fontes;
4. avaliar aceitação agregada por faixa de estabilidade;
5. documentar mudanças de pesos, sinais ou filtros;
6. impedir promoção automática baseada apenas em popularidade ou cliques.
