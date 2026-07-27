import { readFile } from 'node:fs/promises';

const sourceFile = new URL(
  '../apps/app/lib/features/migration_questionnaire/application/services/preparation_resource_links.dart',
  import.meta.url,
);
const source = await readFile(sourceFile, 'utf8');
const extractedUrls = [...new Set(source.match(/https:\/\/[^'"]+/g) ?? [])];
const skippedTemplates = extractedUrls.filter((url) => url.includes('$'));
const urls = extractedUrls.filter((url) => !url.includes('$')).sort();

if (urls.length === 0) {
  throw new Error('No HTTPS guide sources were found.');
}

async function check(url) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 10_000);
  try {
    let response = await fetch(url, {
      method: 'HEAD',
      redirect: 'follow',
      signal: controller.signal,
      headers: { 'user-agent': 'Movaro-Source-Audit/1.0' },
    });
    if (response.status === 405 || response.status === 403) {
      response = await fetch(url, {
        method: 'GET',
        redirect: 'follow',
        signal: controller.signal,
        headers: {
          'user-agent': 'Movaro-Source-Audit/1.0',
          range: 'bytes=0-256',
        },
      });
    }
    return { url, status: response.status, ok: response.status < 400 };
  } catch (error) {
    return {
      url,
      status: null,
      ok: false,
      error: error instanceof Error ? error.message : String(error),
    };
  } finally {
    clearTimeout(timer);
  }
}

const results = [];
for (let index = 0; index < urls.length; index += 6) {
  results.push(...(await Promise.all(urls.slice(index, index + 6).map(check))));
}

const blockedOrUnreachable = results.filter(
  (result) =>
    !result.ok &&
    (result.status === null || result.status === 401 || result.status === 403),
);
const broken = results.filter(
  (result) => !result.ok && !blockedOrUnreachable.includes(result),
);
console.log(
  JSON.stringify(
    {
      checkedAt: new Date().toISOString(),
      checked: results.length,
      healthy: results.filter((result) => result.ok).length,
      skippedTemplates,
      blockedOrUnreachable,
      broken,
    },
    null,
    2,
  ),
);

if (broken.length > 0) {
  process.exitCode = 1;
}
