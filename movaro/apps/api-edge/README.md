# Mudavi Public API

Cloudflare Worker for the landing page's small public API surface. The main NestJS API remains a separate service.

## Secrets

Configure these values with Cloudflare secrets. Never commit them:

```sh
npx wrangler secret put SUPABASE_URL
npx wrangler secret put SUPABASE_SECRET_KEY
```

## Development

```sh
npm install
npm run types
npm run check
npm run dev
```

The Worker exposes:

- `GET /health`
- `POST /api/v1/launch-interests`
