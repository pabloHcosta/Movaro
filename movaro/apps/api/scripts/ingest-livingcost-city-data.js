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
  const fx = await fetchUsdToBrlRate();
  const budgetSnapshots = [];
  const publicOpinions = [];

  for (const city of cities) {
    const slug = resolveLivingcostSlug(city);
    if (!slug) {
      continue;
    }

    const url = `https://livingcost.org/cost/brazil/${slug}`;
    try {
      const html = await fetchHtml(url);
      const budget = parseBudgetPage(html, city, url, fx);
      if (budget) {
        budgetSnapshots.push(budget);
      }

      const opinion = parsePublicOpinion(html, city, url);
      if (opinion) {
        publicOpinions.push(opinion);
      }
    } catch (error) {
      console.warn(`[livingcost] ${city.id}: ${String(error)}`);
    }

    await sleep(450);
  }

  const { mergedBudgets, mergedOpinions } = persistCityMarketSource({
    sourceKey: 'livingcost',
    budgetSnapshots,
    publicOpinions,
  });

  console.log(
    `Wrote ${budgetSnapshots.length} livingcost budget snapshots and merged ${mergedBudgets.length} total records to ${path.relative(process.cwd(), budgetPath)}`,
  );
  console.log(
    `Wrote ${publicOpinions.length} livingcost public opinions and merged ${mergedOpinions.length} total records to ${path.relative(process.cwd(), opinionPath)}`,
  );
}

function resolveLivingcostSlug(city) {
  const aliases = {
    'tibau-do-sul-rn': 'pipa-tibau-do-sul',
    'jijoca-de-jericoacoara-ce': 'jericoacoara',
    'cairu-ba': 'morro-de-sao-paulo-cairu',
  };
  return (
    aliases[city.id] ??
    toSlug(city.displayName || city.name)
  );
}

function toSlug(value) {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

async function fetchUsdToBrlRate() {
  const response = await fetch('https://open.er-api.com/v6/latest/USD', {
    headers: {
      'user-agent': USER_AGENT,
      'accept': 'application/json',
    },
    signal: AbortSignal.timeout(12_000),
  });
  if (!response.ok) {
    throw new Error(`FX HTTP ${response.status}`);
  }
  const payload = await response.json();
  const rate = payload?.rates?.BRL;
  if (!Number.isFinite(rate) || rate <= 0) {
    throw new Error('FX BRL rate missing');
  }
  return {
    brlPerUsd: rate,
    provider:
      typeof payload.provider === 'string' &&
      payload.provider.includes('exchangerate-api.com')
        ? 'ExchangeRate-API'
        : payload.provider || 'ExchangeRate-API',
    updatedAt:
      typeof payload.time_last_update_utc === 'string'
        ? new Date(payload.time_last_update_utc).toISOString().slice(0, 10)
        : new Date().toISOString().slice(0, 10),
  };
}

async function fetchHtml(url) {
  const response = await fetch(url, {
    headers: {
      'user-agent': USER_AGENT,
      'accept-language': 'en-US,en;q=0.9',
    },
    signal: AbortSignal.timeout(15_000),
  });
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}`);
  }
  const html = await response.text();
  if (/Page not found|Not Found/i.test(html)) {
    throw new Error('not found');
  }
  return html;
}

function parseBudgetPage(html, city, sourceUrl, fx) {
  const withoutRentUsd = parseRowUsd(html, 'without-rent');
  const rentUsd = parseRowUsd(html, 'rent');
  const salaryUsd = parseRowUsd(html, 'salary');
  const transportUsd = parseRowUsd(html, 'transport');
  const centreRentUsd = parsePriceUsd(
    html,
    '1 bedroom apartment in city Center',
  );
  const outsideRentUsd = parsePriceUsd(
    html,
    'Cheap 1 bedroom apartment',
  );
  const utilitiesUsd = parsePriceUsd(
    html,
    'Utility Bill one person',
  );
  const updatedAt = parseUpdatedAt(html) ?? fx.updatedAt;

  const values = [
    withoutRentUsd,
    rentUsd,
    salaryUsd,
    transportUsd,
    centreRentUsd,
    outsideRentUsd,
    utilitiesUsd,
  ];
  if (values.some((value) => value == null)) {
    return null;
  }

  return {
    cityId: city.id,
    cityLabel: city.displayName || city.name,
    singlePersonExcludingRent: toBrl(withoutRentUsd, fx.brlPerUsd),
    oneBedroomOutsideCentre: toBrl(outsideRentUsd, fx.brlPerUsd),
    oneBedroomCityCentre: toBrl(centreRentUsd, fx.brlPerUsd),
    averageMonthlyNetSalary: toBrl(salaryUsd, fx.brlPerUsd),
    monthlyTransportPass: toBrl(transportUsd, fx.brlPerUsd),
    utilities: toBrl(utilitiesUsd, fx.brlPerUsd),
    updatedAt,
    sourceLabel: `Livingcost cost data + ${fx.provider} USD/BRL`,
    sourceUrl,
    sourceType: 'derived',
  };
}

function parsePublicOpinion(html, city, sourceUrl) {
  const quality = parsePlainNumberRow(html, 'quality');
  const salaryUsd = parseRowUsd(html, 'salary');
  const totalUsd = parseRowUsd(html, 'total');
  const airQuality = parseTableValue(html, 'Air quality');
  const updatedAt = parseUpdatedAt(html) ?? new Date().toISOString().slice(0, 10);

  if (quality == null && salaryUsd == null && totalUsd == null && !airQuality) {
    return null;
  }

  const salaryCoverage =
    Number.isFinite(salaryUsd) && Number.isFinite(totalUsd) && totalUsd > 0
      ? salaryUsd / totalUsd
      : null;

  const positivePoints = [];
  const criticalPoints = [];

  if (quality != null) {
    if (quality >= 65) {
      positivePoints.push('qualidade de vida percebida');
    } else if (quality < 50) {
      criticalPoints.push('qualidade de vida no dia a dia');
    }
  }

  if (salaryCoverage != null) {
    if (salaryCoverage >= 1) {
      positivePoints.push('salário médio cobre o custo mensal');
    } else {
      criticalPoints.push('pressão entre salário médio e custo mensal');
    }
  }

  if (airQuality) {
    if (/good/i.test(airQuality)) {
      positivePoints.push('qualidade do ar');
    } else if (/moderate|poor|bad/i.test(airQuality)) {
      criticalPoints.push('qualidade do ar');
    }
  }

  const summaryParts = [];
  if (quality != null) {
    summaryParts.push(
      `Livingcost coloca ${city.displayName || city.name} com quality of life ${quality.toFixed(0)}.`,
    );
  }
  if (salaryCoverage != null) {
    summaryParts.push(
      salaryCoverage >= 1
        ? 'O salário líquido mediano cobre o custo mensal estimado.'
        : 'O salário líquido mediano não cobre sozinho o custo mensal estimado.',
    );
  }
  if (airQuality) {
    summaryParts.push(`Leitura pública de ar: ${airQuality}.`);
  }

  return {
    cityId: city.id,
    provider: 'Livingcost Quality of Life',
    placeName: city.displayName || city.name,
    placeUrl: sourceUrl,
    rating: null,
    userRatingCount: null,
    summary: summaryParts.join(' '),
    positivePoints: unique(positivePoints).slice(0, 3),
    criticalPoints: unique(criticalPoints).slice(0, 3),
    collectedAt: new Date().toISOString(),
  };
}

function parseUpdatedAt(html) {
  const match = html.match(/<time datetime="([^"]+)">/i);
  if (!match) {
    return null;
  }
  const iso = new Date(match[1]);
  return Number.isNaN(iso.getTime())
    ? null
    : iso.toISOString().slice(0, 10);
}

function parseRowUsd(html, rowId) {
  const regex = new RegExp(
    `<th id="${rowId}"[\\s\\S]*?<span data-usd="([0-9.]+)"`,
    'i',
  );
  const match = html.match(regex);
  return match ? Number(match[1]) : null;
}

function parsePriceUsd(html, label) {
  const escaped = escapeRegex(label);
  const regex = new RegExp(
    `<th[^>]*>[\\s\\S]*?${escaped}[\\s\\S]*?<span data-usd="([0-9.]+)"`,
    'i',
  );
  const match = html.match(regex);
  return match ? Number(match[1]) : null;
}

function parsePlainNumberRow(html, rowId) {
  const regex = new RegExp(
    `<th id="${rowId}"[\\s\\S]*?<div class="bar-table[^"]*">\\s*([0-9.]+)\\s*<span`,
    'i',
  );
  const match = html.match(regex);
  return match ? Number(match[1]) : null;
}

function parseTableValue(html, label) {
  const escaped = escapeRegex(label);
  const regex = new RegExp(
    `<th[^>]*>[\\s\\S]*?${escaped}[\\s\\S]*?<td>([^<]+)<\\/td>`,
    'i',
  );
  const match = html.match(regex);
  return match ? match[1].trim() : null;
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function toBrl(valueUsd, brlPerUsd) {
  return Math.round(valueUsd * brlPerUsd);
}

function unique(values) {
  return [...new Set(values.filter(Boolean))];
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
