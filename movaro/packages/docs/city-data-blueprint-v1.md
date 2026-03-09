# City Data Blueprint V1 - Movaro

## Visao Geral

O catalogo de cidades do Movaro combina dados oficiais publicos com um dataset local curado. O objetivo nao e declarar vencedores absolutos, mas oferecer recomendacoes iniciais com metodologia explicita, separadas por intencao de uso do produto.

## Origem dos Dados

Dados oficiais via IBGE:

- nome oficial da cidade
- estado
- sigla da UF
- codigo IBGE
- regiao, quando disponivel na resposta de localidades

Dados do dataset local curado:

- population
- costOfLivingScore
- rentScore
- safetyScore
- argentinaPopularityScore
- jobMarketScore
- unemploymentRate
- economicActivityScore
- topIndustries
- updatedAt

## Por que misturar IBGE e dataset curado

O IBGE fornece identidade territorial confiavel, mas nao entrega sozinho o conjunto de sinais de produto que o Movaro precisa para ranqueamento orientado por intencao. O dataset local cobre essa lacuna de forma controlada e versionada enquanto ainda nao existe banco, Supabase ou pipeline mais robusto.

## Arquitetura da Camada

O modulo `cities` foi dividido em:

- `integrations/ibge/`: cliente HTTP, normalizador e acesso externo oficial
- `modules/cities/data/`: leitura do dataset local curado
- `modules/cities/application/`: merge, ranking e orquestracao do catalogo
- `modules/cities/domain/`: entidades do city card e contratos de repositorio
- `modules/cities/presentation/`: endpoints REST

## Como evitar ranking como verdade absoluta

A API foi desenhada para:

- separar ranking por categoria e intencao
- retornar `recommendationReasons`
- expor endpoint de metodologia
- manter scores como heuristicas do produto, nao como sentenca objetiva

No app, a leitura recomendada e: "cidade sugerida para este tipo de prioridade", e nao "melhor cidade do Brasil".

## Migracao futura para Supabase/Postgres

Essa arquitetura pode evoluir sem refatoracao profunda:

- o dataset local pode migrar para tabelas versionadas
- o merge pode trocar leitura de arquivo por repositorios SQL
- o cache simples em memoria pode migrar para persistencia ou materializacao
- novos provedores oficiais podem entrar ao lado do IBGE

Enquanto isso, o contrato do `city card` ja nasce estavel o suficiente para o app consumir o catalogo.
