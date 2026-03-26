# movaro_app

## API environment switching

The app resolves its backend URL from build-time dart defines.

Primary keys:

- `APP_ENV=development|production|staging`
- `API_SOURCE=local|railway`
- `LOCAL_API_BASE_URL`
- `RAILWAY_API_BASE_URL`

`API_BASE_URL` is still supported as a direct override for backward compatibility,
but the preferred setup is to switch with `API_SOURCE`.

Current checked-in defaults:

- [`.env.production.json`](/Users/pablocosta/Developer/Movaro/movaro/apps/app/.env.production.json) defaults to `API_SOURCE=local`
- [`.env.development.json`](/Users/pablocosta/Developer/Movaro/movaro/apps/app/.env.development.json) defaults to `API_SOURCE=local`
- Railway remains available in `RAILWAY_API_BASE_URL`

To switch production back to Railway, change only this value in
[`.env.production.json`](/Users/pablocosta/Developer/Movaro/movaro/apps/app/.env.production.json):

```json
{
  "API_SOURCE": "railway"
}
```

To update the Cloudflare Tunnel URL, change only `LOCAL_API_BASE_URL` in
[`.env.production.json`](/Users/pablocosta/Developer/Movaro/movaro/apps/app/.env.production.json).

Example build:

```bash
flutter build apk \
  --target lib/main_production.dart \
  --dart-define-from-file=.env.production.json
```
