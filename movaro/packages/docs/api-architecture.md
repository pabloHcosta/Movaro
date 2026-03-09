# API Architecture - Movaro

## Visao Geral

A API do Movaro foi inicializada com NestJS e TypeScript, adotando uma arquitetura modular desde o primeiro passo. A base foi preparada para crescer com clareza estrutural, configuracao por ambiente e baixo acoplamento, sem introduzir complexidade de dominio antes da hora.

## Arquitetura Escolhida

O projeto usa NestJS como framework principal e o Fastify como HTTP adapter. Essa combinacao oferece:

- organizacao modular nativa
- boa separacao entre bootstrap, modulos e componentes compartilhados
- produtividade alta com TypeScript
- adapter HTTP performatico e adequado para crescimento futuro

A estrutura inicial em `src/` foi organizada em:

- `common/`: recursos transversais, como configuracao, constantes e pontos de extensao para filtros, interceptors, decorators e logger
- `modules/`: modulos funcionais da aplicacao, comecando por `health`
- `shared/`: espaco reservado para componentes compartilhados de nivel mais amplo, quando surgirem necessidades reais

## Estrategia de Ambientes

A API nasce preparada para `development`, `staging` e `production`.

A estrategia adotada combina:

- `NODE_ENV` como seletor do ambiente atual
- arquivos `.env` especificos por ambiente
- resolucao centralizada de arquivos via `getEnvFilePaths`
- validacao obrigatoria de variaveis via `validateEnvironment`
- acesso tipado a configuracao via `AppConfigService`

Essa abordagem evita espalhar `process.env` pelo codigo e centraliza a interpretacao de configuracao em um unico ponto.

## Organizacao de Modulos

NestJS foi usado no formato modular para manter responsabilidade clara por contexto.

Neste passo existe apenas:

- `HealthModule`: exposto em `GET /api/v1/health`

Os modulos de dominio ainda nao foram criados de proposito. Isso preserva a fundacao limpa enquanto produto, regras de negocio e integracoes ainda nao foram definidos.

## Decisao por NestJS + Fastify

NestJS foi escolhido pela maturidade do ecossistema, padrao arquitetural consistente e facilidade de evolucao em times maiores.

Fastify foi adotado como adapter por tres motivos principais:

- desempenho superior em cenarios HTTP
- ecossistema maduro e integracao oficial com NestJS
- boa base para observabilidade, middlewares e extensoes futuras

## OpenAPI e Observabilidade no Futuro

A base foi preparada para receber OpenAPI e observabilidade depois, sem refatoracao estrutural relevante.

Os pontos que facilitam essa evolucao sao:

- bootstrap centralizado em `main.ts`
- configuracao global isolada em `common/config`
- estrutura reservada para `logger`, `filters` e `interceptors`
- modularidade pronta para instrumentacao por contexto

## Resultado

O resultado deste passo e uma API inicial profissional, enxuta e pronta para crescer, sem antecipar banco, autenticacao, Swagger, Docker ou regras de negocio antes do momento certo.
