const fs = require('node:fs');
const path = require('node:path');

const SOURCE_KEYS = ['livingcost', 'numbeo'];
const BUDGET_PRIORITY = ['livingcost', 'numbeo', 'legacy'];
const OPINION_PRIORITY = ['numbeo', 'livingcost', 'legacy'];

function persistCityMarketSource({
  sourceKey,
  budgetSnapshots,
  publicOpinions,
}) {
  if (!SOURCE_KEYS.includes(sourceKey)) {
    throw new Error(`Unsupported source key: ${sourceKey}`);
  }

  const paths = resolvePaths();
  ensureDir(paths.importsDir);

  fs.writeFileSync(
    paths.rawBudgetPath(sourceKey),
    `${JSON.stringify(budgetSnapshots, null, 2)}\n`,
  );
  fs.writeFileSync(
    paths.rawOpinionPath(sourceKey),
    `${JSON.stringify(publicOpinions, null, 2)}\n`,
  );

  const mergedBudgets = mergeRecords({
    kind: 'budget',
    paths,
  });
  const mergedOpinions = mergeRecords({
    kind: 'opinion',
    paths,
  });

  fs.writeFileSync(
    paths.seedBudgetPath,
    `${JSON.stringify(mergedBudgets, null, 2)}\n`,
  );
  fs.writeFileSync(
    paths.seedOpinionPath,
    `${JSON.stringify(mergedOpinions, null, 2)}\n`,
  );

  return {
    mergedBudgets,
    mergedOpinions,
    paths,
  };
}

function mergeRecords({ kind, paths }) {
  const existingSeed = readJson(
    kind === 'budget' ? paths.seedBudgetPath : paths.seedOpinionPath,
    [],
  );
  const byCity = new Map();

  const priorities = kind === 'budget' ? BUDGET_PRIORITY : OPINION_PRIORITY;
  for (const sourceKey of priorities) {
    const records =
      sourceKey === 'legacy'
        ? existingSeed.filter((record) => deriveSourceKey(kind, record) === 'legacy')
        : readJson(
            kind === 'budget'
              ? paths.rawBudgetPath(sourceKey)
              : paths.rawOpinionPath(sourceKey),
            [],
          );

    for (const record of records) {
      const cityId = normalize(record.cityId);
      if (!cityId || byCity.has(cityId)) {
        continue;
      }
      byCity.set(cityId, sanitizeRecord(kind, record));
    }
  }

  return [...byCity.values()].sort((left, right) =>
    String(left.cityId).localeCompare(String(right.cityId)),
  );
}

function sanitizeRecord(kind, record) {
  if (kind === 'budget') {
    return {
      cityId: record.cityId,
      cityLabel: record.cityLabel,
      singlePersonExcludingRent: record.singlePersonExcludingRent,
      oneBedroomOutsideCentre: record.oneBedroomOutsideCentre,
      oneBedroomCityCentre: record.oneBedroomCityCentre,
      averageMonthlyNetSalary: record.averageMonthlyNetSalary,
      monthlyTransportPass: record.monthlyTransportPass,
      utilities: record.utilities,
      updatedAt: record.updatedAt,
      sourceLabel: record.sourceLabel,
      sourceUrl: record.sourceUrl,
      sourceType: record.sourceType,
    };
  }

  return {
    cityId: record.cityId,
    provider: record.provider,
    placeName: record.placeName ?? null,
    placeUrl: record.placeUrl ?? null,
    rating: record.rating ?? null,
    userRatingCount: record.userRatingCount ?? null,
    summary: record.summary ?? null,
    positivePoints: Array.isArray(record.positivePoints)
      ? record.positivePoints
      : [],
    criticalPoints: Array.isArray(record.criticalPoints)
      ? record.criticalPoints
      : [],
    collectedAt: record.collectedAt,
  };
}

function deriveSourceKey(kind, record) {
  const label =
    kind === 'budget'
      ? String(record?.sourceLabel ?? '')
      : String(record?.provider ?? '');
  const normalized = label.toLowerCase();
  if (normalized.includes('livingcost')) {
    return 'livingcost';
  }
  if (normalized.includes('numbeo')) {
    return 'numbeo';
  }
  return 'legacy';
}

function resolvePaths() {
  const root = path.resolve(__dirname, '../..');
  const importsDir = path.join(
    root,
    'src/modules/cities/data/imports/city-market-sources',
  );
  return {
    importsDir,
    seedBudgetPath: path.join(
      root,
      'src/modules/cities/data/seeds/city_budget_snapshots.json',
    ),
    seedOpinionPath: path.join(
      root,
      'src/modules/cities/data/seeds/city_public_opinions.json',
    ),
    rawBudgetPath: (sourceKey) =>
      path.join(importsDir, `budget.${sourceKey}.json`),
    rawOpinionPath: (sourceKey) =>
      path.join(importsDir, `opinion.${sourceKey}.json`),
  };
}

function readJson(filePath, fallback) {
  if (!fs.existsSync(filePath)) {
    return fallback;
  }
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function normalize(value) {
  return String(value ?? '')
    .trim()
    .toLowerCase();
}

module.exports = {
  persistCityMarketSource,
};
