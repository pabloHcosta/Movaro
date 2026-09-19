# mudavi_app

## API environment switching

The app resolves its backend URL from build-time dart defines.

Primary keys:

- `APP_ENV=development|production|staging`
- `API_SOURCE=local|railway`
- `LOCAL_API_BASE_URL`
- `RAILWAY_API_BASE_URL`

`API_BASE_URL` is still supported as a direct override for backward compatibility,
but the preferred setup is to switch with `API_SOURCE`.

Recommended defaults:

- `.env.production.json` uses `API_SOURCE=railway`
- `.env.development.json` uses `API_SOURCE=local`
- Railway remains available in `RAILWAY_API_BASE_URL`

Production also defaults to Railway in `AppEnvironment` when `API_SOURCE` is
omitted. To use Railway explicitly, set:

```json
{
  "API_SOURCE": "railway"
}
```

To use a stable Cloudflare Tunnel for local production-like tests, create a
named Tunnel and map a Cloudflare-managed subdomain such as
`api-test.example.com` to `http://localhost:3000`. A named Tunnel keeps the
same hostname when the Mac's public IP or the connector changes. Keep the
origin listening on `127.0.0.1` when it only needs to serve the local Tunnel.
The hostname must be configured in Cloudflare before the steps below.

To activate it, first move the domain's nameservers to Cloudflare if needed.
In the Cloudflare dashboard, create a Tunnel under **Networking > Tunnels**,
publish a hostname such as `api-test.example.com`, and set its service URL to
`http://127.0.0.1:3000`. Install the connector on the Mac with the command
shown by Cloudflare. Keep its token outside this repository. Configure
`cloudflared` to run as a macOS service so it starts after login or boot.
Enable the **Tunnel Health Alert** in Cloudflare Notifications, and monitor
`https://api-test.example.com/api/v1/health` from outside the Mac: tunnel
health alone does not show whether the API process is responding. Alert on
sustained failures of that endpoint, not on IP changes.

Recommended local-production flow:

1. Keep your API running on `http://localhost:3000`
2. Start the named Tunnel as a macOS service (recommended), or run it in a
   terminal with `TUNNEL_NAME=<name> bash scripts/start_cloudflare_tunnel.sh`.
3. Create the local env override file using the stable hostname:

```bash
TUNNEL_PUBLIC_URL=https://api-test.example.com \
  bash scripts/prepare_local_production_env.sh
```

This checks both the local API and the public health endpoint, then creates
`.env.production.local.json`. Subsequent builds reuse that file's stable URL;
they do not restart the Tunnel or require a new app build after an IP change.
The production configuration used by the presentation build is untouched.
If the named Tunnel or API is down, preparation fails before a build.

For a temporary demo without a Cloudflare-managed domain, explicitly use
`TUNNEL_MODE=quick bash scripts/prepare_local_production_env.sh`. That mode
creates a random URL, which changes when the Tunnel is recreated and should
not be embedded in an app intended for ongoing testing.

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
