# Arquitetura do Monorepo Movaro

## Visao Geral

O projeto Movaro foi estruturado como um monorepo para organizar aplicacoes, contratos compartilhados, documentacao tecnica e infraestrutura em um unico lugar. Esta abordagem facilita evolucao incremental, padronizacao e escalabilidade conforme o produto cresce.

## Organizacao de Pastas

### `apps/app`

Reservado para a aplicacao Flutter. Esta pasta concentrara a experiencia cliente e a camada de apresentacao do produto.

### `apps/api`

Reservado para a API Node.js. Esta camada sera responsavel por expor servicos, coordenar regras de negocio e integrar com a infraestrutura.

### `packages/contracts`

Espaco destinado aos contratos compartilhados entre aplicacoes e servicos. Aqui devem viver definicoes comuns, como esquemas, tipos, convencoes de payload e acordos de integracao.

### `packages/docs`

Repositorio da documentacao tecnica do projeto. A intencao e centralizar decisoes arquiteturais, guias operacionais e referencias importantes para o time.

### `infra/supabase`

Base da infraestrutura relacionada ao banco de dados e servicos associados do Supabase.

- `migrations`: scripts versionados de evolucao do schema
- `seeds`: dados iniciais ou de apoio para ambientes
- `policies`: definicoes de politicas de acesso e seguranca

## Principios da Fundacao

- Separacao clara entre aplicacoes, compartilhamento de contratos, documentacao e infraestrutura
- Estrutura preparada para crescimento sem acoplamento prematuro
- Base simples o suficiente para permitir a inicializacao futura de Flutter, Node.js e banco de forma controlada
- Documentacao desde o inicio para apoiar consistencia arquitetural

## Escalabilidade Esperada

Com esta estrutura, o projeto pode evoluir adicionando automacao, pipelines, testes, ferramentas de qualidade e novos pacotes compartilhados sem necessidade de reorganizacao estrutural significativa.
