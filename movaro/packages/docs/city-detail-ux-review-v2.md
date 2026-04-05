# City Detail UX Review V2 - 2026-04-04

## Escopo

- Revisao tecnica e de UX da feature de detalhes de cidade.
- Base local: `apps/app/lib/features/cities/presentation/pages/city_detail_page.dart` e `apps/app/lib/features/cities/application/cities_controller.dart`.
- Base externa: benchmark de padroes atuais de mercado e referencias de usabilidade.
- Este documento e um expert review. Nao substitui teste com usuarios reais.

## Resumo Executivo

A feature de detalhes nao sofre porque "tem informacao demais". Ela sofre porque a informacao relevante esta empilhada em uma pagina longa, com muitas secoes de peso visual parecido, muitos textos narrativos e uma navegacao de secoes que existe, mas nao fica sustentada ao longo do uso.

Hoje a tela mistura tres papeis ao mesmo tempo:

1. resumo executivo para tomar decisao rapida
2. relatorio analitico para comparar criterios
3. apendice de evidencias e contexto

O mercado atual nao resolve isso removendo conteudo. Resolve em camadas:

- header com highlights e contexto chave
- navegacao persistente por secoes ou tabs
- secoes primarias curtas com preview
- contexto secundario em paines colapsaveis, tabs ou side panels
- importancia adaptativa por tipo de dado e por tamanho de tela

Inferencia minha a partir do benchmark: para a Movaro, o melhor caminho nao e "resumir a cidade", e sim reorganizar a pagina como uma experiencia em camadas, onde a primeira dobra responde "vale seguir com esta cidade?" e as camadas seguintes respondem "por que?" e "qual evidencia sustenta isso?".

## O Que Esta Bom Hoje

- A pagina ja tenta criar hierarquia com snapshot, resumo rapido, criterios, comparacao e uma area secundaria expansivel.
- A feature tem bons sinais de confianca: fontes, datas e sheets de detalhe para metricas.
- O codigo ja esta modularizado por contexto de dados, o que facilita refatorar a experiencia sem desmontar o backend:
  - `cities_controller.dart:326-520` separa `socialProof`, `climateSummary`, `arrivalStory` e `comparison` em chaves e caches independentes.
- Ja existe alguma forma de progressive disclosure:
  - acesso rapido por secoes em `city_detail_page.dart:1547-1738`
  - secoes secundarias colapsadas em `city_detail_page.dart:1826-1945`
  - analise detalhada em `city_detail_page.dart:826-870`

Conclusao: o problema principal e de informacao e apresentacao, nao de falta de dado nem de incapacidade tecnica.

## Achados Principais

### 1. A pagina continua longa demais para o papel de "decisao"

Trecho principal:

- `city_detail_page.dart:554-905`

Antes mesmo da area secundaria, a tela pode exibir:

- decision snapshot
- quick summary
- criteria
- cost of living
- arrival viability
- city narrative
- climate
- people like you
- neighborhoods
- strengths
- comparison
- CTA principal

Isso cria uma tela com muitos blocos "obrigatorios" antes do usuario entender claramente onde esta o nucleo da decisao.

Impacto:

- aumenta carga cognitiva
- alonga o tempo ate a primeira resposta util
- faz o usuario entrar em leitura sequencial em vez de leitura orientada por objetivo

### 2. A navegacao por secoes existe, mas nao escala

Trechos:

- `city_detail_page.dart:1547-1738`
- `city_detail_page.dart:4530-4635`

A tela monta ate 18 atalhos de navegacao. Eles sao exibidos em uma lista horizontal de 40px de altura, com chips compactos, sem persistencia ao longo do scroll, e com `TextOverflow.ellipsis`.

Problemas:

- o usuario precisa lembrar que a navegacao existia la em cima
- labels podem ser truncados
- horizontal scroll em lista longa reduz descoberta
- a navegacao nao permanece visivel como referencia estrutural

Resultado pratico: a pagina tem "acesso rapido", mas nao tem "orientacao continua".

### 3. O progressive disclosure atual tem baixa informacao de destino

Trecho:

- `city_detail_page.dart:1826-1945`

A segunda camada inteira da experiencia fica atras de um unico toggle: `Ver mais sobre {cidade}`.

Problema:

- o CTA nao informa o que exatamente sera revelado
- isso enfraquece information scent
- o usuario nao sabe se ali existem mapas, opiniao publica, sazonalidade, fontes ou analise detalhada

Em outras palavras: existe disclosure, mas falta previsibilidade.

### 4. Muitos cards trabalham como texto narrativo longo

Trechos mais relevantes:

- `city_detail_page.dart:4753-4922`
- `city_detail_page.dart:5175-5267`
- `city_detail_page.dart:5331-5398`
- `city_detail_page.dart:5405-5506`
- `city_detail_page.dart:5513-5602`

A tela usa varios cards com:

- titulo
- paragrafo de contexto
- paragrafo de explicacao
- bloco complementar colorido
- chips ou bullets

Cada card isoladamente parece razoavel. O problema e o efeito acumulado. O usuario deixa de escanear e passa a enfrentar uma sequencia de mini-artigos.

Impacto:

- baixa densidade de insight por dobra
- maior fadiga de leitura
- queda da comparabilidade entre secoes

### 5. O topo ainda entrega mais interpretacao do que evidencia

Trechos:

- `city_detail_page.dart:4753-5077`
- `city_detail_page.dart:3342-3491`
- `city_detail_page.dart:3495-3666`

O topo tem boa intencao: snapshot, resumo e criterios. Mas a experiencia ainda puxa o usuario rapido para leitura interpretativa, nao para sinais comparaveis e acionaveis.

Exemplo:

- o snapshot usa titulo, resumo, next step, motivos e watchouts
- o quick summary tem tres sinais
- os criterios abrem sheets

Falta um painel mais objetivo de highlights com 3-5 fatos que respondam imediatamente:

- custo mensal
- pressao de chegada
- nivel de seguranca
- facilidade de rotina
- melhor proximo passo

### 6. O deep dive continua sendo uma segunda pagina comprimida dentro da primeira

Trechos:

- `city_detail_page.dart:826-870`
- `city_detail_page.dart:6764-7588`

A analise detalhada ja esta colapsada, o que e bom. Mas quando aberta, ela ainda concentra:

- 6 score bars
- varias linhas financeiras
- faixa de cobertura salarial
- desemprego
- atividade economica
- industrias
- contexto populacional
- popularidade
- suporte ao espanhol
- codigo IBGE
- regiao
- razoes de recomendacao

Impacto:

- continua pesada quando expandida
- repete parte do que a pagina ja disse antes
- mistura indicadores de decisao com contexto de referencia

### 7. Ha risco de perda de confianca entre prioridade do usuario e logica apresentada

Trecho:

- `city_detail_page.dart:4991-5000`

O `weightedDecisionScore()` usa um mapa de prioridades para compor o veredito do topo. Um ponto chama atencao:

- `warm_climate` esta mapeado para `city.movaroScores.economical`

Mesmo que isso tenha sido usado como proxy temporario, a leitura final da tela pode parecer personalizada sem realmente respeitar o criterio declarado pelo usuario.

Impacto:

- reduz confianca no veredito
- enfraquece transparencia da decisao
- torna mais arriscado usar linguagem forte como "boa escolha para seguir"

### 8. A hierarquia visual ainda nao separa com clareza o que e primario do que e complementar

Boa parte dos blocos usa containers visualmente parecidos:

- `FrostedPanel`
- cards com padding semelhante
- titulos de peso parecido
- espacos verticais regulares

Isso da consistencia, mas reduz contraste de importancia. O usuario percebe muitos blocos "igualmente importantes".

## O Que O Mercado Faz Hoje

### 1. Header com contexto forte e highlights

SAP Fiori Object Page recomenda um `dynamic page header` com informacao chave do objeto, contexto e navegao por secoes. O header concentra o que o usuario precisa para se orientar antes de mergulhar no conteudo.

### 2. Navegacao persistente por secoes ou tabs

SAP tambem recomenda:

- anchor bar para navegar por secoes e subsecoes longas
- tab bar quando os topicos sao complexos e cada bloco tem muito conteudo

O ponto central aqui e: em paginas densas, a estrutura precisa continuar visivel durante a leitura.

### 3. Fim da pagina unica longa como padrao

Salesforce Lightning mudou a experiencia de records justamente para evitar "tons of scrolling":

- highlights panel no topo
- detalhes agrupados em tabs
- related lists em cards condensados
- quick views para expandir sem sair do contexto

### 4. Informacao secundaria em paines de contexto

Jira trata informacao secundaria com `issue context panels` e `glances`:

- um resumo visivel
- detalhe adicional em painel colapsavel
- informacao de apoio ao lado do conteudo principal

Ou seja: o usuario nao e obrigado a pagar o custo de toda a informacao de uma vez.

### 5. Agrupamento por containment e navegacao de apoio

Material 3 organiza componentes em:

- containment
- navigation
- selection

E explicita que tabs, top app bars e outros componentes servem para navegar informacoes e acoes de apoio. Em uma tela longa, isso deixa de ser opcional.

## Base de Usabilidade e Psicologia

### 1. Usuarios escaneiam, nao leem linearmente

Microsoft reforca dois pontos:

- o volume de conteudo disponivel e esmagador
- conteudo acima da dobra e o mais provavel de ser lido

Implica para a Movaro:

- a primeira dobra precisa responder rapido se a cidade merece continuar no funil
- longos blocos narrativos nao podem liderar a tela

### 2. Recognition e melhor do que recall

NNGroup destaca que interfaces melhores reduzem a necessidade de lembrar e aumentam a capacidade de reconhecer o que fazer e onde encontrar algo.

Implica para a Movaro:

- navegacao de secoes precisa ficar visivel
- nomes das secoes precisam ser claros
- esconder muita coisa atras de `Ver mais sobre {cidade}` exige memoria demais

### 3. Information scent precisa ser forte

NNGroup explica que o usuario avalia o valor da informacao versus o custo de acessa-la. Quando o destino nao esta claro, o usuario evita explorar.

Implica para a Movaro:

- CTAs precisam dizer o que existe depois
- blocos colapsados devem ser rotulados por tema
- secoes secundarias precisam ter promessa clara

### 4. Conteudo escaneavel depende de chunking real

Microsoft recomenda:

- organizar em componentes discretos
- oferecer navegacao interna em documentos longos
- usar listas curtas e consistentes

A propria guideline de listas sugere, quando possivel, no maximo 7 itens, com itens curtos o bastante para o leitor ver 2 ou 3 de relance.

Implica para a Movaro:

- cards precisam priorizar 1 conclusao + 2-4 evidencias
- listas, chips e highlights sao melhores do que multiplos paragrafos em sequencia

## Diagnostico Final Da Feature

O problema central da feature de detalhes e este:

- a pagina tenta ser overview, comparador, explicador e arquivo de evidencia ao mesmo tempo

O resultado e uma experiencia pesada porque:

- a informacao principal nao esta claramente isolada
- a navegacao estrutural nao acompanha o usuario
- o disclosure nao comunica bem o que existe
- o custo de leitura de cada bloco esta alto

## Direcao Recomendada Para A Movaro

### Arquitetura de informacao sugerida

Sem remover conteudo, reorganizar a pagina em 5 areas:

1. Overview
2. Custo e chegada
3. Vida na pratica
4. Comparacao
5. Evidencias

### Mapeamento sugerido do conteudo atual

| Conteudo atual | Superficie sugerida |
| --- | --- |
| Decision snapshot + quick summary + category list | Overview |
| Cost of living + arrival viability + flight burden | Custo e chegada |
| Narrative + climate + people like you + neighborhoods | Vida na pratica |
| Strengths + inline comparison | Comparacao |
| Seasonality + map + public opinion + analysis + sources | Evidencias |

### Comportamento sugerido da tela

#### Primeira dobra

- hero mais curto
- highlights panel com 3-5 fatos
- veredito resumido em 1 frase
- CTA principal e CTA de comparar ainda no topo

#### Navegacao

- tabs ou anchor bar persistente
- maximo de 5-6 destinos primarios
- overflow claro para extras

#### Cada secao

- 1 frase de leitura principal
- 2-4 cards ou sinais comparaveis
- explicacao longa apenas sob demanda

#### Evidencia secundaria

- map, opiniao publica, sazonalidade e fontes em tab de evidencia ou painel colapsavel com labels explicitos

### O que nao deve ser feito

- nao transformar tudo em accordion solto
- nao esconder a informacao importante no mesmo nivel que a secundaria
- nao manter 15+ atalhos no topo e chamar isso de IA
- nao resolver o problema apenas cortando texto se a estrutura continuar igual

## Plano Tecnico Recomendado

### Fase 1 - Reorganizacao sem mudar dados

- trocar a lista unica por uma estrutura com navegacao persistente
- promover `Overview` como camada principal
- mover conteudo secundario para secoes nomeadas

Possivel implementacao Flutter:

- `NestedScrollView` + `SliverAppBar` + `TabBar`
- ou `CustomScrollView` + segmented control sticky

### Fase 2 - Lazy loading orientado por secao

Como os dados ja estao separados por payload:

- carregar overview primeiro
- carregar tabs secundarias sob demanda
- manter cache atual do `CitiesController`

### Fase 3 - Reducao de custo cognitivo por card

- limitar cada card a 1 insight principal
- trocar blocos longos por:
  - highlights
  - chips
  - mini-comparacoes
  - bullets curtos
- deixar racional, metodologia e fonte em bottom sheet ou detalhe expansivel

### Fase 4 - Confianca e transparencia

- revisar a logica de personalizacao do veredito
- expor melhor a base da recomendacao
- alinhar criterios declarados do usuario com os sinais mostrados

## Prioridades Mais Importantes

### Prioridade 1

- substituir o scroll linear por navegacao persistente por areas
- reduzir a primeira dobra para decisao + highlights + CTA
- transformar a area secundaria em grupos nomeados, nao em um unico `Ver mais`

### Prioridade 2

- reescrever cards narrativos para formato mais escaneavel
- revisar o quick access para 5-6 destinos maximos
- mover contexto de evidencia para superficie propria

### Prioridade 3

- lazy load por secao
- auditoria da logica do veredito
- teste com usuarios em cima do novo fluxo

## Conclusao

A feature de detalhes tem conteudo valioso e base tecnica suficiente para virar uma experiencia muito melhor. O que esta faltando nao e mais dado nem mais texto. O que falta e uma arquitetura de leitura que respeite como pessoas realmente consomem informacao densa em 2026: por camadas, com navegacao persistente, destaque para o essencial e contexto sob demanda.

## Referencias

- SAP Fiori Object Page: https://www.sap.com/design-system/fiori-design-web/v1-136/page-types/floorplans/object-page/usage
- Microsoft Style Guide - Scannable content: https://learn.microsoft.com/en-us/style-guide/scannable-content/
- Microsoft Style Guide - Lists: https://learn.microsoft.com/it-it/style-guide/scannable-content/lists
- Salesforce Trailhead - Work with Your Data: https://trailhead.salesforce.com/content/learn/modules/lightning-experience-for-salesforce-classic-users/work-with-your-data
- Atlassian Jira issue view: https://developer.atlassian.com/cloud/jira/platform/issue-view/
- Android Developers - Material Components: https://developer.android.com/design/ui/mobile/guides/components/material-overview
- NNGroup - Memory Recognition and Recall in User Interfaces: https://www.nngroup.com/articles/recognition-and-recall/
- NNGroup - Information Foraging: A Theory of How People Navigate on the Web: https://www.nngroup.com/articles/information-foraging/
- NNGroup - Text Scanning Patterns: Eyetracking Evidence: https://www.nngroup.com/articles/text-scanning-patterns-eyetracking/
