# Cities Feature V1 - Movaro

## Fluxo da Feature

A feature de cidades foi desenhada para exploracao publica e rapida.

Fluxo principal:

1. `CitiesExplorePage`
2. seções de destaque por intencao
3. `CitySearchPage`
4. `CityDetailPage`
5. tentativa de salvar cidade
6. se guest, redirecionamento para login
7. se autenticado, salvamento temporario em memoria

## Integracao com a API

O app consome:

- `GET /api/v1/cities/highlights`
- `GET /api/v1/cities`
- `GET /api/v1/cities/:id`
- `GET /api/v1/cities/search?q=...`
- `GET /api/v1/cities/metadata/methodology`

A UI nao consome JSON diretamente. A feature foi separada em:

- `data/`: datasource remoto e models
- `domain/`: entities e repository contract
- `application/`: controller da feature
- `presentation/`: pages e widgets

## Como a UI evita promessas absolutas

A experiencia evita linguagem como "melhor cidade" ou "cidade perfeita".

Em vez disso, usa formulacoes como:

- boa opcao para quem prioriza custo
- popular entre argentinos
- boa para quem busca mais oportunidades de trabalho
- entre as cidades analisadas pelo Movaro

Tambem existe banner de metodologia para reforcar que os rankings usam dados publicos e metodologia propria do produto.

## Evolucao futura

Esta base foi preparada para crescer sem refatoracao estrutural:

- favoritos persistidos em backend
- cache offline
- filtros adicionais
- ranking por perfil migratorio
- comparacao entre cidades

Nesta fase, o salvamento de cidade autenticada ocorre apenas em memoria local da sessao para validar o fluxo sem criar banco nem Supabase.
