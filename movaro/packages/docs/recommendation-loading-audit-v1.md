# Auditoria do loading de recomendacao v1

## Escopo

Fluxo auditado: conclusao do questionario de perfil, geracao do plano e entrada
na tela de cidades sugeridas.

A auditoria combina leitura da implementacao atual com validacao visual do
fluxo Flutter Web em ambiente local.

## Resumo executivo

O momento de maior expectativa do questionario ainda nao tem uma experiencia
unica. Dependendo do caminho, o usuario recebe:

- um painel central com `CircularProgressIndicator` e um titulo;
- a ultima pergunta novamente, com spinner apenas dentro do botao;
- uma espera adicional fixa de 700 ms depois que o plano ja terminou;
- ou uma entrada quase vazia na tela de resultado enquanto sinais secundarios
  de voo sao carregados antes da animacao de reveal.

O problema principal nao e somente estetico. O loading nao comunica o valor do
trabalho que a Movaro esta realizando, nao possui duracao minima real, muda de
comportamento entre rotas e pode ficar preso sem recuperacao visivel em caso de
erro.

Recomendacao: transformar esse trecho em um unico `RecommendationRevealLoader`
de tela inteira, com duracao minima entre 2,4 s e 2,8 s, progresso narrativo por
etapas, movimento ambiental da marca e transicao compartilhada para a cidade
recomendada.

## Evidencias encontradas

### P0 — caminhos diferentes exibem loadings diferentes

No caminho normal da ultima pergunta, `_showProcessingScreen` pode ativar o
`_ProcessingState`. No caminho `skipRefine`, a geracao e aguardada diretamente
e esse estado nao e ativado. Na validacao visual, a interface retornou para a
ultima pergunta e mostrou somente o spinner do CTA.

Impacto:

- quebra de continuidade entre formulario e resultado;
- aparencia de regressao para a pergunta anterior;
- experiencia diferente para respostas equivalentes;
- o hero planejado nao cobre o caminho curto, que tende a ser o mais usado.

### P0 — falha de geracao nao tem estado de erro recuperavel

`_generatePlan` garante apenas a liberacao de `isGeneratingPlan` em `finally`.
Os chamadores aguardam a operacao sem tratamento de excecao local. Se a
geracao falhar, o usuario pode permanecer no estado visual de processamento ou
receber uma falha sem CTA de nova tentativa.

O componente novo deve modelar explicitamente `processing`, `slow`, `error` e
`success`, preservando as respostas para retry.

### P1 — os 700 ms atuais nao sao uma duracao minima

O atraso fixo acontece somente depois que `controller.goNext()` termina. Logo,
o tempo total e `tempo real da geracao + 700 ms`, e nao `max(tempo real, minimo)`.

Consequencias:

- respostas muito rapidas ainda produzem uma transicao curta e pouco legivel;
- respostas lentas recebem 700 ms adicionais sem beneficio;
- o tempo artificial nao e usado para prefetch ou coreografia do reveal.

O contrato recomendado e:

```text
tempo_visivel = max(tempo_da_geracao, 2600 ms)
```

O resultado deve abrir assim que as duas condicoes forem satisfeitas: plano
pronto e duracao minima concluida. Nao adicionar espera depois disso.

### P1 — prefetch secundario bloqueia a animacao principal do resultado

A tela de resultado aguarda `_prefetchRecommendationSignals()` antes de chamar
`_anim.forward()`. Esse prefetch inclui a cidade principal e alternativas. Como
o plano ja pode existir, o build sai do skeleton e monta o conteudo com
`FadeTransition` em opacidade zero.

Assim, sinais secundarios de voo podem atrasar ou esvaziar o reveal da cidade.
Eles devem carregar em paralelo e preencher somente os seus proprios blocos. A
cidade recomendada e seus motivos sao o conteudo critico da primeira pintura.

### P1 — o visual atual e generico para o valor entregue

`_ProcessingState` e composto por painel fosco, spinner de 36 px e o texto
"Montando seu primeiro plano". Ele nao demonstra comparacao, territorio,
prioridades nem descoberta. A sensacao e de espera tecnica, nao de uma decisao
sendo preparada.

### P2 — falta narrativa de progresso

Uma unica frase permanece estatica independentemente da duracao. Em conexoes
mais lentas, nao ha confirmacao de que o processo continua vivo.

Usar etapas baseadas em tempo, sem porcentagem falsa:

1. `Entendendo suas prioridades`
2. `Comparando cidades com o seu perfil`
3. `Encontrando os melhores encaixes`
4. `Preparando sua shortlist`

Se ultrapassar aproximadamente 6 s, trocar a ultima linha por uma mensagem
honesta: `Ainda estamos comparando alguns sinais. Isso pode levar mais alguns segundos.`

### P2 — acessibilidade e movimento reduzido nao estao cobertos

O loading relevante nao possui `Semantics`/`liveRegion` proprio e o conceito
atual nao define comportamento para `MediaQuery.disableAnimations`.

O novo componente deve:

- anunciar somente mudancas de etapa, evitando repeticao a cada frame;
- ter uma versao estatica com fades discretos quando animacoes estiverem
  desativadas;
- manter contraste, escala de texto e leitura correta em PT, ES e EN;
- nao depender apenas de cor ou movimento para comunicar progresso.

### P2 — nao existem testes especificos para a transicao

Os testes atuais cobrem geracao e abertura da rota de resultado, mas nao
validam o loading intermediario, sua duracao minima, o caminho `skipRefine`,
falhas ou movimento reduzido.

## Direcao criativa recomendada

### Conceito: constelacao de caminhos

Usar o fundo ambiental escuro da Movaro como palco. No centro, um marcador
abstrato representa o perfil do usuario. Pequenos pontos surgem como cidades e
linhas curvas formam rotas entre eles. A cada etapa, opcoes menos aderentes
perdem intensidade e tres destinos permanecem em destaque.

O movimento deve ser elegante e calmo, nao uma gamificacao:

- gradiente azul profundo com halos sutis;
- particulas/pontos em baixa densidade;
- rotas desenhadas progressivamente;
- chips das prioridades respondidas entrando brevemente na composicao;
- pulso final no destino principal;
- o ponto vencedor expande ou faz crossfade para a imagem hero da cidade.

Essa composicao pode ser feita com `CustomPainter` e animacoes nativas do
Flutter, sem depender de video pesado. Ela tambem pode reutilizar
`AmbientBackground` e os tokens atuais da marca.

## Coreografia proposta

| Janela | Visual | Texto |
| --- | --- | --- |
| 0–500 ms | formulario dissolve; ponto do perfil permanece | `Entendendo suas prioridades` |
| 500–1200 ms | pontos de cidades e rotas aparecem | `Comparando cidades com o seu perfil` |
| 1200–2000 ms | alternativas se reorganizam; tres ganham foco | `Encontrando os melhores encaixes` |
| 2000–2600 ms | destino principal pulsa e prepara o reveal | `Preparando sua shortlist` |
| acima de 2600 ms | loop ambiental leve ate a resposta chegar | manter a etapa atual; mensagem de demora apos ~6 s |

O tempo minimo recomendado e 2,6 s. Em dispositivos com movimento reduzido,
usar aproximadamente 1,2 s com tres estados estaticos e fades curtos. Se o
resultado chegar antes do minimo, usar o restante para prefetch da imagem hero
da cidade principal. Se chegar depois, revelar imediatamente quando estiver
pronto.

## Arquitetura sugerida

Centralizar a transicao em um unico orquestrador, usado por todos os caminhos:

```text
submit final / skip refine / skip optional
                  |
                  v
      RecommendationRevealLoader
       |           |             |
       |           |             +-- estado de erro + retry
       |           +-- relogio de duracao minima
       +-- geracao do plano
                  |
                  v
       prefetch apenas do hero principal
                  |
                  v
       MigrationResultRevealPage
       (voos e alternativas carregam inline)
```

Responsabilidades:

- a controller continua responsavel por gerar e persistir o plano;
- a pagina/orquestrador controla duracao minima, etapas visuais, erro e
  navegacao;
- a pagina de resultado nao bloqueia sua animacao por sinais secundarios;
- o componente recebe dados seguros de apresentacao, como prioridades e
  contagem de cidades, sem expor informacao sensivel em logs.

## Criterios de aceite

1. Todos os caminhos finais entram no mesmo hero de processamento.
2. O loading fica visivel por no minimo 2,4 s e alvo de 2,6 s, sem somar atraso
   quando a geracao real ja ultrapassou esse tempo.
3. Nenhum spinner aparece sobre a ultima pergunta depois do usuario confirmar a
   geracao.
4. Falha oferece retry e retorno, mantendo todas as respostas.
5. A cidade principal aparece sem aguardar dados de voo das alternativas.
6. O reveal inicia com continuidade visual entre o loader e o hero da cidade.
7. Movimento reduzido, escala de texto, PT/ES/EN e leitores de tela possuem
   cobertura.
8. Testes cobrem resposta rapida, resposta lenta, erro, `skipRefine`, caminho
   estrategico e descarte da pagina durante a geracao.

## Ordem de implementacao

1. Unificar os pontos de saida e corrigir erro/duracao minima.
2. Desbloquear o reveal dos prefetches secundarios.
3. Implementar a coreografia da constelacao com fallback de movimento reduzido.
4. Fazer a transicao compartilhada para o hero da cidade.
5. Adicionar testes de widget e tempos com relogio controlado.

