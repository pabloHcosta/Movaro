const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');

const ENV_CANDIDATES = [
  '.env.development.local',
  '.env.production.local',
  '.env',
];

const FOUNDATION_TABLES = [
  'migration_plans',
  'migration_plan_progress',
  'assistant_chat_sessions',
  'assistant_chat_messages',
  'assistant_message_feedback',
];

function loadEnv() {
  for (const candidate of ENV_CANDIDATES) {
    const filePath = path.join(__dirname, '..', candidate);
    if (!fs.existsSync(filePath)) {
      continue;
    }

    const values = Object.fromEntries(
      fs
        .readFileSync(filePath, 'utf8')
        .split(/\r?\n/)
        .filter(Boolean)
        .filter((line) => !line.trim().startsWith('#'))
        .map((line) => {
          const separatorIndex = line.indexOf('=');
          return [
            line.slice(0, separatorIndex).trim(),
            line.slice(separatorIndex + 1).trim(),
          ];
        }),
    );

    return {
      source: filePath,
      url: values.SUPABASE_URL ?? null,
      key:
        values.SUPABASE_SECRET_KEY ??
        values.SUPABASE_SERVICE_ROLE_KEY ??
        null,
    };
  }

  return { source: null, url: null, key: null };
}

async function checkTable(supabase, table) {
  const { error } = await supabase.from(table).select('*', { head: true, count: 'exact' });
  return {
    table,
    exists: !error,
    error: error?.message ?? null,
    code: error?.code ?? null,
  };
}

async function main() {
  const env = loadEnv();
  if (!env.url || !env.key) {
    console.error(
      JSON.stringify(
        {
          ok: false,
          reason: 'Supabase credentials not found in local API env files.',
        },
        null,
        2,
      ),
    );
    process.exit(1);
  }

  const supabase = createClient(env.url, env.key, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const results = [];
  for (const table of FOUNDATION_TABLES) {
    results.push(await checkTable(supabase, table));
  }

  const projectHost = new URL(env.url).host;
  const missingTables = results.filter((result) => !result.exists).map((result) => result.table);

  console.log(
    JSON.stringify(
      {
        ok: missingTables.length === 0,
        sourceEnv: path.basename(env.source),
        projectHost,
        tables: results,
      },
      null,
      2,
    ),
  );

  if (missingTables.length > 0) {
    process.exitCode = 2;
  }
}

main().catch((error) => {
  console.error(
    JSON.stringify(
      {
        ok: false,
        reason: error instanceof Error ? error.message : String(error),
      },
      null,
      2,
    ),
  );
  process.exit(1);
});
