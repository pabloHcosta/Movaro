# Flutter Architecture - Movaro

## Visao Geral

O app Flutter do Movaro foi estruturado para crescer de forma previsivel, com separacao clara entre fundacao da aplicacao, codigo compartilhado e modulos orientados a feature. A base evita complexidade prematura, mas ja nasce preparada para multiplos ambientes, internacionalizacao oficial e expansao do produto sem reestruturacoes profundas.

## Estrutura Adotada

O codigo em `apps/app/lib` foi dividido em tres macro areas:

- `app/`: composicao da aplicacao, bootstrap, configuracao, router, tema e localizacao
- `core/`: elementos transversais e reutilizaveis, como environment, erros, constantes, utilitarios e widgets base
- `features/`: modulos organizados por feature, cada um com separacao por camadas

Dentro de `features/home`, a estrutura segue o padrao:

- `presentation/`: widgets, paginas e adaptacao para UI
- `application/`: casos de uso, coordenacao e orquestracao futura
- `domain/`: entidades e regras centrais da feature
- `data/`: fontes de dados, DTOs e repositorios concretos

Essa organizacao combina feature-first com separacao por camadas, o que reduz acoplamento entre contextos de negocio e facilita manutencao, testes e evolucao incremental.

## Estrategia de Ambientes

O app foi preparado para `development`, `staging` e `production` usando `dart-define`, que e a abordagem oficial do Flutter para injecao de configuracao em tempo de build.

Elementos adotados:

- `main_development.dart`
- `main_staging.dart`
- `main_production.dart`
- `AppEnvironment`, como ponto central de leitura e validacao

As configuracoes sao lidas a partir de defines como:

- `APP_FLAVOR`
- `APP_ENV`
- `APP_NAME`
- `API_BASE_URL`

Essa estrategia evita hardcode de configuracao de ambiente em codigo de negocio e mantem a app pronta para futura integracao com flavors nativos, CI/CD e pipelines de distribuicao.

## Estrategia de Internacionalizacao

A internacionalizacao foi preparada com `gen_l10n`, que e a solucao oficial do Flutter.

Foram adicionados:

- `l10n.yaml`
- ARBs para `pt`, `es` e `en`
- classe gerada `AppLocalizations`
- centralizacao das delegates e locales suportadas em `app/localization`

Com isso, a app pode crescer com seguranca em multiplos idiomas sem espalhar textos fixos pela interface.

## Tema e Design System Base

O tema foi organizado em arquivos separados para:

- `app_colors.dart`
- `app_typography.dart`
- `app_theme.dart`

Essa separacao prepara a fundacao para um design system futuro sem introduzir bibliotecas extras ou abstractions desnecessarias neste momento.

## Router Base

O roteamento foi mantido simples e profissional com `onGenerateRoute`, suficiente para a fase inicial e facil de evoluir para fluxos maiores no futuro. Isso evita introduzir dependencias prematuras antes de existir complexidade real de navegacao.

## Motivo da Arquitetura Escolhida

A arquitetura foi escolhida para equilibrar tres objetivos:

- simplicidade no inicio do projeto
- clareza estrutural para um time crescer com consistencia
- preparacao real para escala, ambientes e manutencao

Em vez de adicionar state management complexo, injecao de dependencia ou frameworks extras cedo demais, a base foi mantida enxuta, oficial e extensivel. O resultado e uma fundacao profissional, limpa e pronta para suportar a evolucao do Movaro com baixo custo de reorganizacao.
