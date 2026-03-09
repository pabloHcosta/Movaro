# UX Review V1 - Movaro

## Problemas Encontrados

- a splash ainda ocupava atencao com texto desnecessario para a funcao que ela cumpre
- a home publica mostrava os caminhos principais, mas ainda tinha elementos de apoio competindo com a decisao inicial
- as telas de cidades tinham boa base funcional, porem com muito texto hardcoded e pouca centralizacao de microcopy
- o detalhe de cidade entregava informacao util, mas com pouca contextualizacao sobre leitura dos indicadores
- a busca de cidades ainda carecia de introducao curta e labels mais claros
- o fluxo de perguntas estava funcional, porem ainda podia melhorar o estado de carregamento e a previsibilidade da leitura

## Ajustes Feitos

- splash reduzida ao minimo: apenas simbolo e cor de fundo, sem mensagem de marketing
- home publica simplificada para reforcar apenas tres caminhos:
  - descobrir cidades
  - gerar meu plano
  - experiencias de quem ja mudou
- texto de apoio da home foi condensado para diminuir carga cognitiva
- exploracao de cidades ganhou introducao curta, nota metodologica consistente e secoes com intencao mais explicita
- busca de cidades ganhou headline, descricao curta e labels centralizados para internacionalizacao
- detalhe da cidade passou a contextualizar melhor os indicadores, reforcando leitura cuidadosa e nao absoluta
- questionario ganhou estado de carregamento consistente com o restante do app
- microcopy foi centralizada nas ARBs das telas revisadas para sustentar escala global

## Principios de UX Adotados

- guest-first desde a entrada
- valor do produto visivel em poucos segundos
- uma acao principal clara por tela
- linguagem humana e direta
- baixa carga cognitiva
- contexto antes de pedir autenticacao
- menos explicacao e mais orientacao
- estrutura pronta para escalar sem reescrever o fluxo

## Decisoes de Acessibilidade

- hierarquia visual mais clara entre titulo, apoio e acao principal
- splash sem ruido visual desnecessario
- alvos de toque mais previsiveis no questionario
- linguagem simples e menos tecnica
- manutencao da internacionalizacao nas principais mensagens
- reforco textual de metodologia e contexto para reduzir interpretacoes erradas de ranking
- telas com foco em uma tarefa principal por vez

## Como o Fluxo Foi Simplificado

- o splash apenas prepara o app e sai rapidamente da frente
- a home publica orienta a descoberta em tres caminhos explicitos e com menos ruido secundario
- a exploracao de cidades introduz contexto antes de listar opcoes
- o detalhe da cidade separa visao rapida, setores fortes e motivos de recomendacao
- o questionario comunica esforco curto e mostra uma pergunta por vez
- o login aparece apenas quando a intencao exige salvar ou continuar uma acao pessoal
- a area autenticada permanece como ponto de continuidade, sem competir com a exploracao publica
