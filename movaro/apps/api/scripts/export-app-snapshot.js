#!/usr/bin/env node
/**
 * Exports the enriched city catalog from a running Mudavi API into the Flutter
 * app's bundled snapshot. That snapshot powers the app's offline-first fallback
 * (network -> persistent cache -> bundled snapshot), so the catalog, city
 * detail, search and plan generation keep working with zero backend.
 *
 * Usage:
 *   1. Start the API:   npm run start:dev      (here, in apps/api)
 *   2. Export snapshot: npm run export:snapshot
 *
 * Re-run whenever you change city data (e.g. movaro_city_metrics.json) and want
 * the offline build to reflect it. Then rebuild the Flutter app.
 *
 * Env:
 *   SNAPSHOT_API_BASE  API base URL (default http://127.0.0.1:3000)
 */
'use strict';

const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const BASE = (process.env.SNAPSHOT_API_BASE || 'http://127.0.0.1:3000').replace(
  /\/$/,
  '',
);
const OUT_DIR = path.resolve(__dirname, '../../app/assets/seed/snapshots');

const ENDPOINTS = [
  { path: '/api/v1/cities?countryCode=BR', file: 'cities_br.json', expect: 'list' },
  { path: '/api/v1/cities/highlights', file: 'cities_highlights.json', expect: 'object' },
  {
    path: '/api/v1/cities/metadata/methodology',
    file: 'cities_methodology.json',
    expect: 'object',
  },
];

function fetchJson(url) {
  const lib = url.startsWith('https') ? https : http;
  return new Promise((resolve, reject) => {
    const req = lib.get(url, (res) => {
      const status = res.statusCode || 0;
      let data = '';

      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        if (status < 200 || status >= 300) {
          reject(new Error(`HTTP ${status} from ${url}: ${data.slice(0, 160)}`));
          return;
        }

        try {
          resolve(JSON.parse(data));
        } catch (_) {
          reject(new Error(`Invalid JSON from ${url}: ${data.slice(0, 120)}`));
        }
      });
    });
    req.on('error', reject);
    req.setTimeout(15000, () => req.destroy(new Error(`Timeout: ${url}`)));
  });
}

function normalizePayload(payload, { expect, path: endpointPath }) {
  const isEnvelope =
    payload != null &&
    typeof payload === 'object' &&
    !Array.isArray(payload) &&
    'data' in payload;

  const data = isEnvelope ? payload.data : payload;

  if (isEnvelope && payload.success !== true) {
    throw new Error(`${endpointPath} returned unsuccessful envelope`);
  }

  const expectedType = expect === 'list' ? 'array' : 'object';
  const hasValidShape =
    expect === 'list' ? Array.isArray(data) : data != null && typeof data === 'object' && !Array.isArray(data);

  if (!hasValidShape) {
    throw new Error(`${endpointPath} expected ${expectedType} payload, received ${data === null ? 'null' : Array.isArray(data) ? 'array' : typeof data}`);
  }

  return data;
}

(async () => {
  // Preflight: confirm the API is reachable before touching any files.
  try {
    const health = await fetchJson(`${BASE}/api/v1/health`);
    const healthPayload = normalizePayload(health, {
      expect: 'object',
      path: '/api/v1/health',
    });
    if (healthPayload.success !== true) {
      throw new Error('health endpoint did not return success');
    }
  } catch (error) {
    console.error(`\n✖ Could not reach the Mudavi API at ${BASE}.`);
    console.error('  Start it first:  npm run start:dev   (in apps/api)');
    console.error('  Or set SNAPSHOT_API_BASE to the correct URL.');
    console.error(`  (${error.message})\n`);
    process.exit(1);
  }

  fs.mkdirSync(OUT_DIR, { recursive: true });

  let cityCount = 0;
  for (const endpoint of ENDPOINTS) {
    try {
      const payload = await fetchJson(`${BASE}${endpoint.path}`);
      const data = normalizePayload(payload, endpoint);

      const outPath = path.join(OUT_DIR, endpoint.file);
      fs.writeFileSync(outPath, `${JSON.stringify(data, null, 2)}\n`);
      if (endpoint.expect === 'list') {
        cityCount = data.length;
      }
      const shape = endpoint.expect === 'list' ? `${data.length} items` : 'object';
      console.log(`✔ ${endpoint.file}  (${shape}, ${fs.statSync(outPath).size} bytes)`);
    } catch (error) {
      console.error(`✖ ${endpoint.path} -> ${error.message}`);
      process.exit(1);
    }
  }

  console.log(`\n✓ Offline snapshot updated: ${cityCount} cities written to`);
  console.log(`  ${OUT_DIR}`);
  console.log('  Rebuild the Flutter app to bundle the refreshed data.\n');
})().catch((error) => {
  console.error('✖ Export failed:', error.message);
  process.exit(1);
});
