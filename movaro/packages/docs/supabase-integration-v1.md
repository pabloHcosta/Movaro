# Supabase Integration v1

Este projeto esta preparado para integrar o Supabase em duas camadas:

## 1. Flutter app

O app usa apenas configuracao publica do projeto:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Essas duas chaves podem ir nos `dart-defines` do build.

Exemplo:

```bash
flutter run \
  --dart-define=APP_FLAVOR=dev \
  --dart-define=APP_ENV=development \
  --dart-define=APP_NAME="Movaro Dev" \
  --dart-define=API_BASE_URL=http://192.168.1.40:3000 \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## 2. Nest API

A API usa chave de servidor e nunca deve expor isso no app.

Use no backend:

- `SUPABASE_URL`
- `SUPABASE_SECRET_KEY`

Se o painel do projeto ainda mostrar `service_role`, tambem aceitamos:

- `SUPABASE_SERVICE_ROLE_KEY`

Crie um arquivo `.env.development.local` em `apps/api/` com:

```env
SUPABASE_URL=https://YOUR_PROJECT.supabase.co
SUPABASE_SECRET_KEY=YOUR_SECRET_KEY
```

## 3. O que o Supabase faz e o que ele nao faz

O Supabase serve bem para:

- banco Postgres
- auth
- storage
- realtime
- edge functions

O Supabase nao hospeda a API Nest inteira como um Railway ou Render.
Se voce quiser manter a API atual, ela continua rodando fora do Supabase e conversa com ele.

## 4. O que voce precisa me passar

Para fechar a integracao real, eu preciso destes valores:

- Project URL
- Anon / publishable key
- Secret key ou service role key

E tambem preciso saber qual sera o uso inicial:

- auth
- banco
- storage
- ou todos

## 5. Recomendacao pratica para o Movaro agora

Para a fase atual, o melhor caminho e:

1. manter a API Nest
2. conectar a API ao Supabase com chave de servidor
3. usar o app com a chave anon apenas se formos ligar auth ou storage direto no Flutter
4. subir o APK apontando para a API publica e nao direto para o Supabase
