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

Recommended local-production flow:

1. Keep your API running on `http://localhost:3000`
2. Generate a fresh Cloudflare Tunnel URL and a local env override file:

```bash
bash scripts/prepare_local_production_env.sh
```

This creates [`.env.production.local.json`](/Users/pablocosta/Developer/Movaro/movaro/apps/app/.env.production.local.json) without touching the checked-in production env file.

To build an APK already pointed at the fresh tunnel URL:

```bash
bash scripts/build_production_local_apk.sh
```

To run on iPhone or simulator already pointed at the fresh tunnel URL:

```bash
bash scripts/run_production_local_ios.sh
```

To build iOS with the same local-production tunnel setup:

```bash
bash scripts/build_production_local_ios.sh
```

To run the app locally with the generated tunnel URL:

```bash
flutter run \
  --target lib/main_production.dart \
  --dart-define-from-file=.env.production.local.json
```

Example build:

```bash
flutter build apk \
  --target lib/main_production.dart \
  --dart-define-from-file=.env.production.json
```
