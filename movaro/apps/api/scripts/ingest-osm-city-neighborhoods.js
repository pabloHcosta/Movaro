const fs = require('node:fs');
const path = require('node:path');

const OVERPASS_ENDPOINTS = [
  'https://overpass-api.de/api/interpreter',
  'https://lz4.overpass-api.de/api/interpreter',
  'https://overpass.kumi.systems/api/interpreter',
  'https://overpass.private.coffee/api/interpreter',
  'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
];

async function main() {
  const metricsPath = path.resolve(
    __dirname,
    '../src/modules/cities/data/seeds/movaro_city_metrics.json',
  );
  const neighborhoodsPath = path.resolve(
    __dirname,
    '../src/modules/city-insights/data/seeds/city_neighborhoods.json',
  );

  const cities = JSON.parse(fs.readFileSync(metricsPath, 'utf8'));
  const existingRows = fs.existsSync(neighborhoodsPath)
    ? JSON.parse(fs.readFileSync(neighborhoodsPath, 'utf8'))
    : [];
  const rowsByCityId = new Map(existingRows.map((row) => [row.cityId, row]));

  for (const city of cities) {
    if (rowsByCityId.has(city.id)) {
      continue;
    }
    try {
      const places = await fetchNeighborhoods(city);
      if (places.length > 0) {
        rowsByCityId.set(city.id, {
          cityId: city.id,
          cityName: city.displayName || city.name,
          places,
        });
        persistRows(neighborhoodsPath, rowsByCityId);
      }
    } catch (error) {
      console.warn(`[osm-neighborhoods] ${city.id}: ${String(error)}`);
    }
    await sleep(1400);
  }

  const rows = persistRows(neighborhoodsPath, rowsByCityId);
  console.log(
    `Wrote ${rows.length} city neighborhood rows to ${path.relative(process.cwd(), neighborhoodsPath)}`,
  );
}

async function fetchNeighborhoods(city) {
  const radii = city.population >= 1000000 ? [22000, 14000] : [16000, 10000];

  let lastError = null;
  for (const radius of radii) {
    const query = `[out:json][timeout:25];
(
  node["place"~"suburb|neighbourhood|quarter|borough"](around:${radius},${city.latitude},${city.longitude});
  way["place"~"suburb|neighbourhood|quarter|borough"](around:${radius},${city.latitude},${city.longitude});
  relation["place"~"suburb|neighbourhood|quarter|borough"](around:${radius},${city.latitude},${city.longitude});
  way["boundary"="administrative"]["admin_level"~"9|10"](around:${radius},${city.latitude},${city.longitude});
  relation["boundary"="administrative"]["admin_level"~"9|10"](around:${radius},${city.latitude},${city.longitude});
);
out tags center;`;

    for (const endpoint of orderedEndpointsForCity(city.id)) {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'content-type': 'text/plain;charset=UTF-8',
          'user-agent': 'Movaro/1.0 dataset-ingest',
        },
        body: query,
        signal: AbortSignal.timeout(22_000),
      }).catch((error) => {
        lastError = error;
        return null;
      });

      if (!response) {
        continue;
      }

      if (!response.ok) {
        lastError = new Error(`HTTP ${response.status}`);
        await sleep(response.status === 429 || response.status === 504 ? 1600 : 500);
        continue;
      }

      const payload = await response.json();
      const elements = Array.isArray(payload?.elements) ? payload.elements : [];
      const places = dedupe(
        elements
          .map((element, index) => mapElementToPlace(city, element, index))
          .filter(Boolean),
      )
        .sort((left, right) => right.rank - left.rank)
        .slice(0, 4)
        .map(({ rank, ...place }) => place);

      if (places.length > 0) {
        return places;
      }
    }
  }

  throw lastError ?? new Error('All Overpass endpoints failed');
}

function orderedEndpointsForCity(cityId) {
  const offset = stableHash(cityId) % OVERPASS_ENDPOINTS.length;
  return OVERPASS_ENDPOINTS.map(
    (_, index) => OVERPASS_ENDPOINTS[(index + offset) % OVERPASS_ENDPOINTS.length],
  );
}

function mapElementToPlace(city, element, index) {
  const tags = element.tags || {};
  const name = normalizeText(tags.name, 64);
  if (!name || isWeakName(name, city.name)) {
    return null;
  }

  const latitude = element.lat ?? element.center?.lat;
  const longitude = element.lon ?? element.center?.lon;
  if (latitude == null || longitude == null) {
    return null;
  }

  const neighborhood =
    normalizeText(
      tags['addr:suburb'] ||
        tags['addr:neighbourhood'] ||
        tags.neighbourhood ||
        tags.neighborhood ||
        tags.suburb ||
        tags['is_in:suburb'] ||
        tags['addr:city_district'],
      48,
    ) || name;

  const placeType = tags.place || tags.boundary || tags.landuse || 'bairro';
  const rank =
    (tags.place ? 4 : 0) +
    (tags.boundary === 'administrative' ? 2 : 0) +
    (tags.wikidata ? 1 : 0) +
    (tags.wikipedia ? 1 : 0) +
    (name === neighborhood ? 1 : 0);

  return {
    rank,
    id: `${city.id}-osm-neighborhood-${element.type}-${element.id || index + 1}`,
    name,
    neighborhood,
    region: city.displayName || city.name,
    category: mapCategory(placeType),
    shortText: `${name} aparece no OpenStreetMap como área relevante dentro de ${city.displayName || city.name}.`,
    mapUrl: `https://www.openstreetmap.org/?mlat=${latitude}&mlon=${longitude}#map=14/${latitude}/${longitude}`,
    source: 'openstreetmap',
    latitude,
    longitude,
  };
}

function normalizeText(value, max = 64) {
  if (typeof value !== 'string') {
    return null;
  }
  const trimmed = value.replace(/\s+/g, ' ').trim();
  if (!trimmed) {
    return null;
  }
  return trimmed.slice(0, max);
}

function mapCategory(value) {
  if (value === 'quarter' || value === 'borough') {
    return 'bairro';
  }
  if (value === 'administrative') {
    return 'distrito';
  }
  return 'bairro';
}

function isWeakName(name, cityName) {
  const normalizedName = normalizeKey(name);
  const normalizedCity = normalizeKey(cityName);
  if (normalizedName.length < 4) {
    return true;
  }
  if (normalizedName === normalizedCity) {
    return true;
  }
  if (/centro|center|downtown/.test(normalizedName)) {
    return false;
  }
  return /(unknown|unnamed|bairro|district|neighborhood)$/.test(normalizedName);
}

function normalizeKey(value) {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
}

function dedupe(items) {
  const seen = new Set();
  return items.filter((item) => {
    const key = `${normalizeKey(item.name)}::${normalizeKey(item.neighborhood || '')}`;
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
}

function persistRows(filePath, rowsByCityId) {
  const rows = [...rowsByCityId.values()].sort((left, right) =>
    left.cityId.localeCompare(right.cityId),
  );
  fs.writeFileSync(filePath, JSON.stringify(rows, null, 2) + '\n');
  return rows;
}

function stableHash(value) {
  let hash = 0;
  for (const char of String(value)) {
    hash = (hash * 31 + char.charCodeAt(0)) >>> 0;
  }
  return hash;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
