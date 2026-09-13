#!/usr/bin/env node

'use strict';

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const citySeedPath = path.join(
  root,
  'src/modules/cities/data/seeds/movaro_city_metrics.json',
);
const outputPath = path.join(
  root,
  'src/modules/cities/data/imports/safety_official.json',
);

const SERIES_ID = 20;
const SERIES_URL = `https://www.ipea.gov.br/atlasviolencia/dados-series/${SERIES_ID}/`;
const VALUES_URL = `https://www.ipea.gov.br/dados-api/series-values/${SERIES_ID}/4`;
const METADATA_URL = `https://www.ipea.gov.br/cms/api/series/${SERIES_ID}`;
const METHODOLOGY_VERSION = 'ipea-homicide-3y-blend-v1';

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function ibgeMunicipalityRegionId(ibgeCode) {
  return Math.floor(Number(ibgeCode) / 10);
}

function yearOf(period) {
  return new Date(period).getUTCFullYear();
}

function round(value, decimals = 2) {
  const factor = 10 ** decimals;
  return Math.round(value * factor) / factor;
}

function calculateSafetyScore(homicideRatePer100k, previousScore) {
  // A lower registered homicide rate produces a stronger lethal-violence
  // signal. The cap avoids presenting zero events as perfect safety,
  // especially in small municipalities where annual rates are volatile.
  const lethalViolenceSignal = clamp(
    Math.round(100 - homicideRatePer100k * 1.6),
    15,
    95,
  );

  // Homicides do not describe theft, harassment, neighborhood variation, or
  // the lived experience of safety. Preserve a smaller share of the broader
  // curated signal instead of pretending the official rate covers everything.
  return clamp(
    Math.round(lethalViolenceSignal * 0.75 + previousScore * 0.25),
    15,
    95,
  );
}

async function fetchJson(url) {
  const response = await fetch(url, {
    headers: { Accept: 'application/json' },
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    throw new Error(`${url} returned HTTP ${response.status}`);
  }
  return response.json();
}

async function main() {
  const cities = JSON.parse(fs.readFileSync(citySeedPath, 'utf8'));
  const [values, metadataEnvelope] = await Promise.all([
    fetchJson(VALUES_URL),
    fetchJson(METADATA_URL),
  ]);

  if (!Array.isArray(values) || values.length === 0) {
    throw new Error('Ipea returned no municipal safety values');
  }

  const availableYears = [...new Set(values.map((item) => yearOf(item.periodo)))]
    .filter(Number.isFinite)
    .sort((a, b) => b - a);
  const referenceEndYear = availableYears[0];
  const referenceStartYear = referenceEndYear - 2;
  const sourceUpdatedAt = String(
    metadataEnvelope?.data?.updatedAt ?? `${referenceEndYear}-12-31`,
  ).slice(0, 10);

  const byMunicipality = new Map();
  for (const item of values) {
    const year = yearOf(item.periodo);
    if (year < referenceStartYear || year > referenceEndYear) {
      continue;
    }
    const current = byMunicipality.get(item.regiao_id) ?? [];
    current.push({ year, value: Number(item.valor) });
    byMunicipality.set(item.regiao_id, current);
  }

  const missing = [];
  const output = cities.map((city) => {
    const regionId = ibgeMunicipalityRegionId(city.ibgeCode);
    const observations = (byMunicipality.get(regionId) ?? []).filter(
      (item) => Number.isFinite(item.value),
    );
    if (observations.length < 2) {
      missing.push(city.id);
      return null;
    }

    const homicideRatePer100k = round(
      observations.reduce((sum, item) => sum + item.value, 0) /
        observations.length,
    );

    return {
      cityId: city.id,
      ibgeCode: city.ibgeCode,
      safety: {
        safetyScore: calculateSafetyScore(
          homicideRatePer100k,
          city.safetyScore,
        ),
        homicideRatePer100k,
        referenceStartYear,
        referenceEndYear,
        methodologyVersion: METHODOLOGY_VERSION,
        sourceLabel: 'Atlas da Violência / Ipea (SIM/MS)',
        sourceUrl: SERIES_URL,
        sourceType: 'derived',
        updatedAt: sourceUpdatedAt,
      },
    };
  });

  if (missing.length > 0) {
    throw new Error(
      `No stable Ipea municipal series for ${missing.length} cities: ${missing.join(', ')}`,
    );
  }

  fs.writeFileSync(
    outputPath,
    `${JSON.stringify(output.filter(Boolean), null, 2)}\n`,
  );
  console.log(
    `Wrote ${cities.length} safety snapshots using ${referenceStartYear}-${referenceEndYear} Ipea municipal data.`,
  );
}

main().catch((error) => {
  console.error(`Safety sync failed: ${error.message}`);
  process.exit(1);
});
