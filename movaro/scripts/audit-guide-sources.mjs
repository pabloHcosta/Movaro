import { readFile } from "node:fs/promises";

const sourceFile = new URL(
  "../apps/app/lib/features/migration_questionnaire/application/services/preparation_resource_links.dart",
  import.meta.url,
);
const source = await readFile(sourceFile, "utf8");
const extractedUrls = [...new Set(source.match(/https:\/\/[^'"]+/g) ?? [])];
const skippedTemplates = extractedUrls.filter((url) => url.includes("$"));
const urls = extractedUrls.filter((url) => !url.includes("$")).sort();

if (urls.length === 0) {
  throw new Error("No HTTPS guide sources were found.");
}

async function check(url) {
  try {
    const headers = {
      accept:
        "text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8",
      "accept-language": "pt-BR,pt;q=0.9,en;q=0.7",
      "user-agent":
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/126 Safari/537.36 MovaroSourceAudit/2.0",
    };
    let response = await fetch(url, {
      method: "HEAD",
      redirect: "follow",
      signal: AbortSignal.timeout(10_000),
      headers,
    });
    // Several official Brazilian services reject HEAD or serve a false 404
    // for it even though the same public page is healthy with GET.
    if (response.status >= 400) {
      response = await fetch(url, {
        method: "GET",
        redirect: "follow",
        signal: AbortSignal.timeout(10_000),
        headers: {
          ...headers,
          range: "bytes=0-256",
        },
      });
    }
    return {
      url,
      finalUrl: response.url,
      status: response.status,
      ok: response.status < 400,
    };
  } catch (error) {
    return {
      url,
      status: null,
      ok: false,
      error: error instanceof Error ? error.message : String(error),
    };
  }
}

const results = [];
for (let index = 0; index < urls.length; index += 6) {
  results.push(...(await Promise.all(urls.slice(index, index + 6).map(check))));
}

const blockedOrUnreachable = results.filter(
  (result) =>
    !result.ok &&
    (result.status === null ||
      result.status === 401 ||
      result.status === 403 ||
      result.status === 429),
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
