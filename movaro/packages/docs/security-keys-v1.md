# Security — API keys & secrets (v1)

## Current status (verified)

- **No secret was ever committed to git.** History check returned `0 commits`
  for every secret file:
  - `apps/app/.env.development.json`, `.env.production.json`, `.env.production.local.json`
  - `apps/api/.env.development.local`, `.env.production.local`
- `apps/app/lib/core/config/api_keys.dart` is safe: it reads keys via
  `String.fromEnvironment` (dart-define), it does **not** hard-code secrets.
- The app `.gitignore` already ignored `.env.*.json`. The **API and root
  `.gitignore` were empty** — now fixed (see below), so the API `.env*.local`
  files can no longer be committed by accident.

## What was changed in this pass

- Added `apps/api/.gitignore` and a root `.gitignore` that ignore all real
  `.env*` files and keep only `*.example` templates tracked.
- Added `apps/app/.env.example.json` so new contributors get a template with
  placeholders instead of copying real keys around.

## Residual risks & required actions

### 1. Client-embedded keys are extractable (architectural)
`YOUTUBE_API_KEY`, `PEXELS_API_KEY` and `GEMINI_API_KEY` are injected into the
Flutter build via dart-define and used by client-side services
(`youtube_service`, `places_photo_service`, `gemini_chat_service`). **Any key
shipped inside a mobile/web build can be extracted** from the bundle, no matter
how it is stored in the repo.

Recommended fix: **proxy these calls through the Movaro API** (which already has
a Gemini integration and the `/chat` endpoint, plus Google Places server-side).
The app should call the backend, and the third-party keys should live only as
server-side env vars. Until then, keep the keys **restricted** (see below).

### 2. Keys were surfaced in tooling/chat
The key values were printed while inspecting the `.env` files during
development. Treat them as **potentially exposed** and rotate them.

### 3. Rotation & restriction — do this in the provider consoles
These are account actions; perform them yourself (do not paste keys into tools):

- **Google Cloud** (YouTube Data API, Gemini/Generative Language, Places):
  - Regenerate the affected API keys.
  - Add **Application restrictions** (Android app signing SHA-1, iOS bundle id,
    or HTTP referrers for web) and **API restrictions** (limit each key to the
    single API it serves).
  - Set **quotas / budget alerts** to cap abuse cost.
- **Pexels**: regenerate the API key in the dashboard.
- **Supabase**: the `anon`/publishable key is safe to ship; never expose the
  `service_role`/secret key in the app — it stays server-side only.

After rotating, update your **local** `apps/app/.env.*.json` and
`apps/api/.env*.local` (which are now git-ignored) — never the `.example` files.

## Quick verification

```sh
# No secret files should be tracked:
git ls-files | grep -E '\.env' | grep -v example   # -> (empty)

# Real env files should be ignored:
git check-ignore movaro/apps/api/.env.production.local \
  movaro/apps/app/.env.production.json               # -> both listed
```
