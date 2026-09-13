#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const citiesSeedPath = path.join(
  root,
  'src/modules/cities/data/seeds/movaro_city_metrics.json',
);
const officialSeedPath = path.join(
  root,
  'src/modules/cities/data/seeds/official_city_metrics.json',
);
const developmentInputPath = path.join(
  root,
  'src/modules/cities/data/imports/development_official.json',
);
const employmentInputPath = path.join(
  root,
  'src/modules/cities/data/imports/employment_official.json',
);
const safetyInputPath = path.join(
  root,
  'src/modules/cities/data/imports/safety_official.json',
);

function readJson(filePath, fallback = []) {
  if (!fs.existsSync(filePath)) {
    return fallback;
  }
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function normalizeCityId(value) {
  return String(value ?? '')
    .trim()
    .toLowerCase();
}

function keyFor(record) {
  return normalizeCityId(record.cityId) || String(record.ibgeCode ?? '');
}

function mergeDomain(base, patch, domainKey) {
  if (!patch?.[domainKey]) {
    return base;
  }

  return {
    ...base,
    cityId: patch.cityId ?? base.cityId,
    ibgeCode: patch.ibgeCode ?? base.ibgeCode,
    [domainKey]: patch[domainKey],
  };
}

const citySeed = readJson(citiesSeedPath, []);
const development = readJson(developmentInputPath, []);
const employment = readJson(employmentInputPath, []);
const safety = readJson(safetyInputPath, []);

const merged = new Map();

for (const item of citySeed) {
  const record = {
    cityId: item.id,
    ibgeCode: item.ibgeCode,
  };
  merged.set(keyFor(record), record);
}

for (const item of development) {
  const key = keyFor(item);
  const current = merged.get(key) ?? {
    cityId: item.cityId,
    ibgeCode: item.ibgeCode,
  };
  merged.set(key, mergeDomain(current, item, 'development'));
}

for (const item of employment) {
  const key = keyFor(item);
  const current = merged.get(key) ?? {
    cityId: item.cityId,
    ibgeCode: item.ibgeCode,
  };
  merged.set(key, mergeDomain(current, item, 'employment'));
}

for (const item of safety) {
  const key = keyFor(item);
  const current = merged.get(key) ?? {
    cityId: item.cityId,
    ibgeCode: item.ibgeCode,
  };
  merged.set(key, mergeDomain(current, item, 'safety'));
}

const result = [...merged.values()]
  .filter(
    (item) => item.development || item.employment || item.safety,
  )
  .sort((a, b) => String(a.cityId).localeCompare(String(b.cityId)));

writeJson(officialSeedPath, result);

console.log(
  `Wrote ${result.length} official city metric records to ${officialSeedPath}`,
);
