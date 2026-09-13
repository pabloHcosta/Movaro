# Supabase Foundation

Estado atual deste workspace:

- a API ja esta conectada ao projeto Supabase por `SUPABASE_URL` + `SUPABASE_SECRET_KEY`
- a conectividade basica foi validada
- as migrations do workspace estao aplicadas ao projeto remoto

## Migration inicial

Arquivo:

- `infra/supabase/migrations/20260326144540_assistant_foundation.sql`

Essa migration historica criou uma base normalizada para:

- planos e progresso de migracao
- sessoes, mensagens e feedback do assistente

Essa modelagem nunca foi ligada ao runtime e foi removida posteriormente por:

- `infra/supabase/migrations/20260913104500_remove_unused_foundation_tables.sql`

O estado de migracao realmente usado pelo app e sincronizado em
`app_state_snapshots`. A API usa as tabelas de conhecimento do assistente,
cache de insights, analytics e interesses de lancamento.

## Como aplicar no projeto Supabase

As migrations podem ser aplicadas pelo Supabase MCP configurado no Codex ou,
quando a CLI estiver disponivel, com:

```bash
supabase db push
```

## Como validar depois

Na API:

```bash
npm run supabase:check
```

Esse script verifica se todas as tabelas usadas pelo runtime existem no projeto
configurado no `.env.local` da API.

## Observacao de arquitetura

O schema atual combina duas formas de acesso:

- o app escreve diretamente apenas em `app_state_snapshots`, protegido por RLS
- a API usa a service key para conhecimento, cache, analytics e leads
