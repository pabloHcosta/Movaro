const fs = require('node:fs');
const path = require('node:path');
const { persistCityMarketSource } = require('./lib/city-market-seed-store');

const USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36';

async function main() {
  const metricsPath = path.resolve(
    __dirname,
    '../src/modules/cities/data/seeds/movaro_city_metrics.json',
  );
  const budgetPath = path.resolve(
    __dirname,
    '../src/modules/cities/data/seeds/city_budget_snapshots.json',
  );
  const opinionPath = path.resolve(
    __dirname,
    '../src/modules/cities/data/seeds/city_public_opinions.json',
  );

  const cities = JSON.parse(fs.readFileSync(metricsPath, 'utf8'));
  const budgetSnapshots = [];
  const publicOpinions = [];

  for (const city of cities) {
    const citySlug = toNumbeoSlug(city.displayName || city.name);
    const costUrl = `https://www.numbeo.com/cost-of-living/in/${citySlug}`;
    const qualityUrl = `https://www.numbeo.com/quality-of-life/in/${citySlug}`;

    try {
      const costHtml = await fetchHtml(costUrl);
      const budget = parseBudgetPage(costHtml, city, costUrl);
      if (budget) {
        budgetSnapshots.push(budget);
      }
    } catch (error) {
      console.warn(`[numbeo-budget] ${city.id}: ${String(error)}`);
    }
    await sleep(1200);

    try {
      const qualityHtml = await fetchHtml(qualityUrl);
      const opinion = parseQualityOfLifePage(qualityHtml, city, qualityUrl);
      if (opinion) {
        publicOpinions.push(opinion);
      }
    } catch (error) {
      console.warn(`[numbeo-opinion] ${city.id}: ${String(error)}`);
    }
    await sleep(1200);
  }

  const { mergedBudgets, mergedOpinions } = persistCityMarketSource({
    sourceKey: 'numbeo',
    budgetSnapshots,
    publicOpinions,
  });

  console.log(
    `Wrote ${budgetSnapshots.length} numbeo budget snapshots and merged ${mergedBudgets.length} total records to ${path.relative(process.cwd(), budgetPath)}`,
  );
  console.log(
    `Wrote ${publicOpinions.length} numbeo public opinion snapshots and merged ${mergedOpinions.length} total records to ${path.relative(process.cwd(), opinionPath)}`,
  );
}

async function fetchHtml(url) {
  for (let attempt = 1; attempt <= 4; attempt += 1) {
    const response = await fetch(url, {
      headers: {
        'user-agent': USER_AGENT,
        'accept-language': 'en-US,en;q=0.9',
      },
    });

    if (response.ok) {
      return response.text();
    }

    if (response.status !== 429 || attempt === 4) {
      throw new Error(`HTTP ${response.status}`);
    }

    await sleep(1500 * attempt);
  }
}

function parseBudgetPage(html, city, sourceUrl) {
  const singlePersonExcludingRent = parseBrlFromText(
    html,
    /single person are\s*([0-9.,]+)R\$, excluding rent/i,
  );
  const oneBedroomCityCentre = parseBrlFromRow(
    html,
    '1 Bedroom Apartment in City Centre',
  );
  const oneBedroomOutsideCentre = parseBrlFromRow(
    html,
    '1 Bedroom Apartment Outside of City Centre',
  );
  const averageMonthlyNetSalary = parseBrlFromRow(
    html,
    'Average Monthly Net Salary (After Tax)',
  );
  const monthlyTransportPass = parseBrlFromRow(
    html,
    'Monthly Public Transport Pass (Regular Price)',
  );
  const utilities = parseBrlFromRow(
    html,
    'Basic Utilities for 85 m^{2} Apartment (Electricity, Heating, Cooling, Water, Garbage)',
  );

  if (
    [
      singlePersonExcludingRent,
      oneBedroomCityCentre,
      oneBedroomOutsideCentre,
      averageMonthlyNetSalary,
      monthlyTransportPass,
      utilities,
    ].some((value) => value == null)
  ) {
    return null;
  }

  return {
    cityId: city.id,
    cityLabel: city.displayName || city.name,
    singlePersonExcludingRent,
    oneBedroomOutsideCentre,
    oneBedroomCityCentre,
    averageMonthlyNetSalary,
    monthlyTransportPass,
    utilities,
    updatedAt: new Date().toISOString().slice(0, 10),
    sourceLabel: 'Numbeo Cost of Living',
    sourceUrl,
    sourceType: 'community',
  };
}

function parseQualityOfLifePage(html, city, sourceUrl) {
  const safety = parseIndexRow(html, 'Safety Index', false);
  const health = parseIndexRow(html, 'Health Care Index', false);
  const climate = parseIndexRow(html, 'Climate Index', false);
  const traffic = parseIndexRow(html, 'Traffic Commute Time Index', true);
  const pollution = parseIndexRow(html, 'Pollution Index', true);
  const purchasingPower = parseIndexRow(html, 'Purchasing Power Index', false);

  const points = [
    safety &&
      scorePoint(
        safety.value,
        { high: 65, medium: 50 },
        ['sensação de segurança', 'segurança razoável'],
      ),
    health &&
      scorePoint(
        health.value,
        { high: 65, medium: 50 },
        ['saúde e acesso a atendimento', 'saúde aceitável'],
      ),
    climate &&
      scorePoint(
        climate.value,
        { high: 80, medium: 65 },
        ['clima e conforto ao ar livre', 'clima relativamente confortável'],
      ),
    traffic &&
      reverseScorePoint(
        traffic.value,
        { high: 35, medium: 50 },
        ['deslocamento diário', 'trânsito administrável'],
      ),
    pollution &&
      reverseScorePoint(
        pollution.value,
        { high: 35, medium: 55 },
        ['qualidade ambiental', 'poluição moderada'],
      ),
    purchasingPower &&
      scorePoint(
        purchasingPower.value,
        { high: 80, medium: 60 },
        ['poder de compra local', 'poder de compra mediano'],
      ),
  ].filter(Boolean);

  if (points.length === 0) {
    return null;
  }

  const positivePoints = points
    .filter((item) => item.kind === 'positive')
    .map((item) => item.label)
    .slice(0, 3);
  const criticalPoints = points
    .filter((item) => item.kind === 'critical')
    .map((item) => item.label)
    .slice(0, 3);

  const summary = buildOpinionSummary(city.displayName || city.name, {
    safety,
    health,
    climate,
    traffic,
    pollution,
    purchasingPower,
    positivePoints,
    criticalPoints,
  });

  return {
    cityId: city.id,
    provider: 'Numbeo Quality of Life',
    placeName: city.displayName || city.name,
    placeUrl: sourceUrl,
    rating: null,
    userRatingCount: null,
    summary,
    positivePoints,
    criticalPoints,
    collectedAt: new Date().toISOString(),
  };
}

function parseIndexRow(html, label, lowerIsBetter) {
  const escaped = label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(
    `${escaped}<\\/a>\\s*<\\/td><td[^>]*>\\s*([0-9.]+)\\s*<\\/td>.*?<span[^>]*>\\s*([^<]+)`,
    'i',
  );
  const match = html.match(regex);
  if (!match) {
    return null;
  }
  return {
    value: Number(match[1]),
    band: match[2].trim(),
    lowerIsBetter,
  };
}

function scorePoint(value, thresholds, labels) {
  if (value >= thresholds.high) {
    return { kind: 'positive', label: labels[0] };
  }
  if (value < thresholds.medium) {
    return { kind: 'critical', label: labels[0] };
  }
  return { kind: 'positive', label: labels[1] };
}

function reverseScorePoint(value, thresholds, labels) {
  if (value <= thresholds.high) {
    return { kind: 'positive', label: labels[0] };
  }
  if (value > thresholds.medium) {
    return { kind: 'critical', label: labels[0] };
  }
  return { kind: 'positive', label: labels[1] };
}

function buildOpinionSummary(cityName, data) {
  const strengths = data.positivePoints.length
    ? data.positivePoints.slice(0, 2).join(' e ')
    : 'alguns sinais comunitários positivos';
  const watchouts = data.criticalPoints.length
    ? data.criticalPoints.slice(0, 2).join(' e ')
    : 'sem um alerta comunitário dominante';
  return `${cityName} aparece na leitura comunitária da Numbeo com sinais melhores em ${strengths}. Os principais pontos de atenção hoje ficam em ${watchouts}.`;
}

function parseBrlFromText(html, regex) {
  const match = html.match(regex);
  return match ? toIntBrl(match[1]) : null;
}

function parseBrlFromRow(html, label) {
  const escaped = label.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const regex = new RegExp(
    `${escaped}[\\s\\S]{0,180}?([0-9.,]+)&nbsp;R\\$`,
    'i',
  );
  const match = html.match(regex);
  return match ? toIntBrl(match[1]) : null;
}

function toIntBrl(raw) {
  const normalized = raw.replace(/\./g, '').replace(',', '.');
  return Math.round(Number(normalized));
}

function toNumbeoSlug(value) {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^A-Za-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
