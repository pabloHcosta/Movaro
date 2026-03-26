# Supabase Foundation

Estado atual deste workspace:

- a API ja esta conectada ao projeto Supabase por `SUPABASE_URL` + `SUPABASE_SECRET_KEY`
- a conectividade basica foi validada
- o schema publico ainda nao tinha as tabelas operacionais do Movaro

## Migration inicial

Arquivo:

- `infra/supabase/migrations/20260326144540_assistant_foundation.sql`

Essa migration cria a base para:

- `migration_plans`
- `migration_plan_progress`
- `assistant_chat_sessions`
- `assistant_chat_messages`
- `assistant_message_feedback`

Tambem inclui:

- `updated_at` trigger
- sincronizacao de `owner_user_id` no progresso
- indices principais
- RLS para usuarios autenticados

## Como aplicar no projeto Supabase

Como este ambiente nao tem `supabase` CLI nem token de Management API, aplique de um destes jeitos:

1. Abrir o SQL Editor do projeto Supabase
2. Colar o conteudo da migration
3. Executar

Ou, quando a CLI estiver disponivel:

```bash
supabase db push
```

## Como validar depois

Na API:

```bash
npm run supabase:check
```

Esse script verifica se as tabelas-base do Movaro existem no projeto configurado no `.env.local` da API.

## Observacao de arquitetura

Esse schema foi pensado para um backend server-first:

- o app nao precisa escrever direto no Supabase
- a API pode usar a service key e persistir com controle
- quando auth entrar de verdade, as policies ja suportam `auth.uid()`
