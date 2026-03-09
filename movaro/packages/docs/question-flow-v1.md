# Question Flow V1 - Movaro

## Visao Geral

O Question Flow V1 introduz o nucleo funcional do produto Movaro: uma sequencia curta de perguntas que gera um plano migratorio inicial personalizado. Nesta fase, a geracao ocorre com logica local e estruturada para evoluir no futuro para banco, integracao backend e motores mais sofisticados.

## Fluxo de Perguntas

O fluxo atual possui quatro perguntas, exibidas uma por tela:

1. `De onde voce vem?`
   - Argentina
2. `Para onde voce quer ir?`
   - Brasil
   - Ainda nao sei
3. `O que voce quer fazer no novo pais?`
   - Trabalhar
   - Trabalhar remoto
   - Estudar
   - Empreender
   - Aposentar
   - Qualidade de vida
4. `Quando pretende mudar?`
   - So estou pesquisando
   - Nos proximos 12 meses
   - Nos proximos 6 meses
   - O mais rapido possivel

## Modelo de Dados

O fluxo foi estruturado com modelos explicitos para facilitar expansao:

- `Question`
  - `id`
  - `title`
  - `type`
  - `options`
- `Option`
  - `id`
  - `label`
  - `value`
- `Answer`
  - `questionId`
  - `value`
- `MigrationPlan`
  - `originCountry`
  - `destinationCountry`
  - `goal`
  - `timeline`
  - `steps[]`
- `MigrationStep`
  - `title`
  - `description`
  - `category`
  - `estimatedDays`

## Geracao do Plano Migratorio

Quando o usuario finaliza o questionario, o app gera automaticamente um `MigrationPlan`.

Regra inicial:

- se `destinationCountry = Brasil`, o sistema gera um plano padrao inicial para o contexto de mudanca para o Brasil
- se o destino ainda nao estiver definido, o sistema gera um plano exploratorio mais curto

Seed inicial do plano Brasil:

1. Verificar tipo de residencia ou visto
2. Obter CPF
3. Abrir conta bancaria
4. Buscar moradia
5. Regularizar documentacao local

Cada passo inclui titulo, descricao, categoria e estimativa de dias.

## Uso de Seeds Compartilhados

Os seeds iniciais ficam em `packages/contracts/seed/`:

- `countries.json`
- `cities.json`

Esses arquivos sao consumidos tanto pelo app Flutter quanto pela API NestJS. Isso garante alinhamento de catalogo nesta fase inicial sem introduzir banco de dados.

## Estrutura Arquitetural

No Flutter, a feature `migration_questionnaire` foi separada em:

- `presentation/`
- `application/`
- `domain/`
- `data/`

Na API, o modulo `migration` foi estruturado com:

- `entities`
- `models`
- `services`
- `repositories`

Essa separacao prepara o projeto para:

- trocar seed data por banco
- integrar Supabase no futuro
- adicionar IA para geracao de plano
- ampliar paises, perguntas e regras sem refazer a fundacao

## Evolucao Futura

Os proximos passos naturais dessa base sao:

- suportar novos paises e destinos
- persistir respostas e planos
- integrar a geracao do plano com backend real
- adicionar personalizacao por perfil migratorio
- enriquecer os passos com dados regulatórios e curadoria especialista
