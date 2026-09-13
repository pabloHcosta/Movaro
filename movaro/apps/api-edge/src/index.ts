interface WorkerEnv extends Env {
  SUPABASE_URL: string;
  SUPABASE_SECRET_KEY: string;
}

type Locale = 'pt' | 'es' | 'en';

interface LaunchInterestRequest {
  email?: unknown;
  locale?: unknown;
}

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const LOCALES = new Set<Locale>(['pt', 'es', 'en']);

function json(body: unknown, status = 200, headers?: HeadersInit): Response {
  return Response.json(body, {
    status,
    headers: {
      'Cache-Control': 'no-store',
      ...headers,
    },
  });
}

function corsHeaders(request: Request, env: WorkerEnv): HeadersInit | null {
  const origin = request.headers.get('Origin');
  if (!origin) return {};

  const allowedOrigins = env.ALLOWED_ORIGINS.split(',').map((value) => value.trim());
  if (!allowedOrigins.includes(origin)) return null;

  return {
    'Access-Control-Allow-Headers': 'Content-Type, X-Mudavi-Client',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Max-Age': '86400',
    Vary: 'Origin',
  };
}

async function registerLaunchInterest(request: Request, env: WorkerEnv): Promise<Response> {
  const headers = corsHeaders(request, env);
  if (headers === null) return json({ message: 'Origin not allowed.' }, 403);

  if (request.headers.get('X-Mudavi-Client') !== 'landing-page') {
    return json({ message: 'Invalid client.' }, 403, headers);
  }

  let body: LaunchInterestRequest;
  try {
    body = await request.json<LaunchInterestRequest>();
  } catch {
    return json({ message: 'Invalid JSON body.' }, 400, headers);
  }

  const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : '';
  const locale = typeof body.locale === 'string' ? body.locale : '';
  if (email.length > 254 || !EMAIL_PATTERN.test(email) || !LOCALES.has(locale as Locale)) {
    return json({ message: 'Invalid submission.' }, 400, headers);
  }

  const now = new Date().toISOString();
  const endpoint = new URL('/rest/v1/launch_interests', env.SUPABASE_URL);
  endpoint.searchParams.set('on_conflict', 'email');

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      apikey: env.SUPABASE_SECRET_KEY,
      Authorization: `Bearer ${env.SUPABASE_SECRET_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'resolution=merge-duplicates,return=minimal',
    },
    body: JSON.stringify({
      email,
      locale,
      source: 'landing_page',
      status: 'interested',
      last_submitted_at: now,
      updated_at: now,
    }),
  });

  if (!response.ok) {
    console.error(JSON.stringify({
      event: 'launch_interest_failed',
      status: response.status,
      requestId: response.headers.get('sb-request-id'),
    }));
    return json({ message: 'Interest storage is unavailable.' }, 503, headers);
  }

  console.log(JSON.stringify({ event: 'launch_interest_registered', locale }));
  return json({ accepted: true }, 202, headers);
}

export default {
  async fetch(request, env): Promise<Response> {
    const url = new URL(request.url);
    const headers = corsHeaders(request, env);

    if (request.method === 'OPTIONS') {
      return headers === null ? new Response(null, { status: 403 }) : new Response(null, { status: 204, headers });
    }

    if (request.method === 'GET' && url.pathname === '/health') {
      return json({ status: 'ok', service: 'mudavi-public-api' });
    }

    if (request.method === 'POST' && url.pathname === '/api/v1/launch-interests') {
      return registerLaunchInterest(request, env);
    }

    return json({ message: 'Not found.' }, 404);
  },
} satisfies ExportedHandler<WorkerEnv>;
