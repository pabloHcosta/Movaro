# Loading patterns v1

## Diagnostico atual

Antes desta refatoracao, o app concentrava o loading em estados bloqueantes:

- `lib/core/widgets/loading_state_widget.dart` usava `CircularProgressIndicator` centralizado como padrao.
- `lib/features/cities/presentation/pages/cities_explore_page.dart` escondia a tela inteira enquanto carregava destaques.
- `lib/features/cities/presentation/pages/city_search_page.dart` trocava toda a area de resultados por loading simples.
- `lib/features/cities/presentation/pages/city_detail_page.dart` bloqueava o detalhe completo ate cidade e metodologia carregarem.
- `lib/features/explore/presentation/pages/countries_page.dart` e `lib/features/auth/presentation/pages/onboarding_page.dart` dependiam de `FutureBuilder` com tela de loading unica.
- `lib/features/migration_questionnaire/presentation/pages/question_page.dart`, `lib/features/migration_questionnaire/presentation/pages/migration_plan_result_page.dart` e `lib/features/migration_questionnaire/presentation/pages/migration_plan_save_page.dart` tinham loading bloqueante em etapas importantes do fluxo.

## Plano adotado

1. Criar infraestrutura compartilhada de skeletons e transicoes suaves.
2. Preservar layout, header, filtros e navegacao sempre que possivel.
3. Diferenciar loading inicial de refresh discreto.
4. Manter dados ja renderizados durante refetch quando o contexto nao muda.
5. Prefetchar dados de rota onde o stack permitir.

## Componentes base

- `SkeletonBox`: bloco base animado com fallback estatico quando `disableAnimations` estiver ativo.
- `PageSkeleton`: estrutura de pagina pronta para compor placeholders maiores.
- `ListSkeleton`: repeticao padronizada para listas/cards.
- `CardSkeleton`: placeholder base para cards.
- `TableSkeleton`: placeholder para grades e tabelas.
- `DetailSkeleton`: placeholder para telas de detalhe.
- `FormSkeleton`: placeholder para fluxos guiados e formularios.
- `AnimatedStateSwitcher`: transicao suave entre loading, success, empty e error.
- `SectionLoadingOverlay`: refresh discreto sem apagar o conteudo existente.

## Quando usar

### Skeleton

Use quando a estrutura da tela for conhecida e o dado principal ainda nao tiver chegado:

- paginas iniciais
- detalhes
- listas
- passos de formulario

Regra: o layout final deve continuar reconhecivel durante o loading.

### Loading inline discreto

Use quando o usuario ja tem contexto visual e apenas uma secao esta atualizando:

- refetch de lista
- atualizacao de metodologia
- salvamento em segundo plano

Regra: prefira `SectionLoadingOverlay` ou `LoadingStateWidget(compact: true)`.

### Optimistic UI

Use quando a acao do usuario for local, reversivel e de baixo risco:

- favoritos locais
- marcacoes visuais

Nao use optimistic UI para dados dependentes de confirmacao remota critica sem estrategia de rollback.

### Prefetch

Use quando a proxima rota for previsivel:

- navegacao principal para cidades, busca, paises e onboarding
- clique em card que abre detalhe

Regra: prefetchar sem bloquear a interacao e aproveitar cache local/in-flight dedupe.

## Boas praticas para novas telas

- nunca troque a tela inteira por spinner se a moldura da pagina ja for conhecida
- preserve altura e espacamento dos blocos para evitar layout shift
- diferencie `initial load`, `refresh`, `empty` e `error`
- mantenha retry proximo do erro
- respeite `MediaQuery.disableAnimations`
- adicione `Semantics` e `liveRegion` nos estados de loading relevantes
- prefira cache local ou dedupe de requests antes de introduzir novas bibliotecas
