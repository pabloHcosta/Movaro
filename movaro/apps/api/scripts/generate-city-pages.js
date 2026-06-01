#!/usr/bin/env node
/**
 * Generates static, SEO-friendly HTML pages (one per city) from the enriched
 * city snapshot. Flutter web is a poor SEO surface, so these static pages give
 * crawlers real content for "vivir en <ciudad> Brasil / costo / trabajo"
 * searches — the acquisition funnel for the economic-migrant ICP.
 *
 * Output: apps/web/public/{index.html, cidades/<id>.html, sitemap.xml, robots.txt}
 * Run:    npm run generate:city-pages   (in apps/api)
 *
 * Env:
 *   SITE_BASE_URL  canonical base (default https://movaro.app)
 */
'use strict';

const fs = require('fs');
const path = require('path');

const BASE_URL = (process.env.SITE_BASE_URL || 'https://movaro.app').replace(
  /\/$/,
  '',
);
const SNAPSHOT = path.resolve(
  __dirname,
  '../../app/assets/seed/snapshots/cities_br.json',
);
const OUT_DIR = path.resolve(__dirname, '../../web/public');
const CITIES_DIR = path.join(OUT_DIR, 'cidades');

function esc(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function brl(value) {
  if (!Number.isFinite(value)) return null;
  return `R$ ${Math.round(value).toLocaleString('pt-BR')}`;
}

// Industry (work-area) labels localized to Spanish for the ES SEO pages.
// Mirrors the in-app workAreaLabel map. Falls back to the raw catalog label.
const INDUSTRY_ES = {
  servicos: 'Servicios',
  turismo: 'Turismo',
  comercio: 'Comercio',
  tecnologia: 'Tecnología',
  hospedagem: 'Hospedaje',
  porto: 'Puerto',
  saude: 'Salud',
  agronegocio: 'Agronegocio',
  logistica: 'Logística',
  industria: 'Industria',
  energia: 'Energía',
  construcao: 'Construcción',
  gastronomia: 'Gastronomía',
  'transporte maritimo': 'Transporte marítimo',
  agroindustria: 'Agroindustria',
  frigorificos: 'Frigoríficos',
  'industria metal-mecanica': 'Industria metalmecánica',
  autopecas: 'Autopartes',
  educacao: 'Educación',
  financas: 'Finanzas',
  'administracao publica': 'Administración pública',
  universidades: 'Universidades',
  biotecnologia: 'Biotecnología',
};

function industryLabel(raw) {
  const key = String(raw ?? '')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .trim();
  return INDUSTRY_ES[key] ?? raw;
}

function fairLiving(budget) {
  if (!budget) return null;
  const rent = Math.min(
    budget.oneBedroomOutsideCentre,
    budget.oneBedroomCityCentre,
  );
  return budget.singlePersonExcludingRent + rent;
}

function pageShell({ title, description, canonical, body }) {
  return `<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<meta name="description" content="${esc(description)}">
<link rel="canonical" href="${esc(canonical)}">
<meta name="robots" content="index,follow">
<meta property="og:type" content="article">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(description)}">
<meta property="og:url" content="${esc(canonical)}">
<meta property="og:site_name" content="Movaro">
<style>
:root{color-scheme:dark}
*{box-sizing:border-box}
body{margin:0;font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;
  background:#09111f;color:#eef2f8;line-height:1.55}
a{color:#7fb0ff}
.wrap{max-width:760px;margin:0 auto;padding:32px 20px 64px}
header a{color:#cfe0ff;text-decoration:none;font-weight:700}
h1{font-size:1.9rem;line-height:1.15;margin:24px 0 6px}
.sub{color:#9fb2cc;margin:0 0 20px}
h2{font-size:1.15rem;margin:28px 0 8px}
.grid{display:flex;flex-wrap:wrap;gap:10px;margin:10px 0}
.chip{background:rgba(255,255,255,.08);border-radius:999px;padding:6px 12px;font-size:.9rem}
.stat{background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.08);
  border-radius:12px;padding:14px 16px;margin:8px 0}
.cta{display:inline-block;margin-top:20px;background:#1e63d6;color:#fff;
  text-decoration:none;padding:12px 18px;border-radius:12px;font-weight:700}
.muted{color:#8aa0bd;font-size:.85rem;margin-top:32px}
ul{padding-left:18px}
nav.cities{columns:2;gap:18px}
@media(max-width:520px){nav.cities{columns:1}}
</style>
</head>
<body>
<div class="wrap">
<header><a href="/">Movaro</a></header>
${body}
<p class="muted">Datos de referencia con fuentes oficiales (IBGE) y estimaciones
de costo de vida. No es asesoría legal; es un punto de partida práctico.</p>
</div>
</body>
</html>
`;
}

function cityPage(city) {
  const stateName = city.stateName || city.stateCode || '';
  const region = city.regionName ? ` · ${city.regionName}` : '';
  const canonical = `${BASE_URL}/cidades/${city.id}.html`;
  const budget = city.budgetSnapshot;
  const fair = fairLiving(budget);
  const industries = (city.topIndustries || []).slice(0, 5).map(industryLabel);

  const title = `Vivir en ${city.name}, ${stateName} (Brasil): costo, trabajo y trámites | Movaro`;
  const descParts = [
    `Mudarte a ${city.name} (${city.stateCode}) desde Argentina`,
  ];
  if (budget && fair) {
    descParts.push(
      `costo de vida típico ~${brl(fair)}/mes, sueldo promedio ${brl(budget.averageMonthlyNetSalary)}`,
    );
  }
  if (industries.length) {
    descParts.push(`empleo en ${industries.slice(0, 3).join(', ')}`);
  }
  const description = `${descParts.join('. ')}.`;

  const scores = city.movaroScores || {};
  const costSection = budget
    ? `<h2>Costo de vida</h2>
<div class="stat">Costo de vida típico (1 persona, incl. alquiler): <strong>${esc(brl(fair))}/mes</strong></div>
<div class="stat">Sueldo promedio neto local: <strong>${esc(brl(budget.averageMonthlyNetSalary))}/mes</strong></div>
<div class="stat">Alquiler 1 ambiente (fuera del centro): <strong>${esc(brl(budget.oneBedroomOutsideCentre))}/mes</strong></div>
<p>${
        budget.averageMonthlyNetSalary >= fair
          ? 'Con el sueldo promedio local, el costo de vida típico queda cubierto (con poco margen).'
          : 'Ojo: el sueldo promedio local no cubre por sí solo el costo de vivir solo en 1 ambiente — conviene llegar con reserva o compartir gastos.'
      }</p>`
    : `<h2>Costo de vida</h2><p>Estamos sumando datos de costo verificados para ${esc(city.name)}.</p>`;

  const body = `
<h1>Vivir en ${esc(city.name)}</h1>
<p class="sub">${esc(stateName)}${esc(region)} · Brasil${
    Number.isFinite(city.population)
      ? ` · ${city.population.toLocaleString('es')} hab.`
      : ''
  }</p>

${costSection}

<h2>Trabajo</h2>
<p>Señal de mercado laboral: <strong>${esc(scores.workOpportunity ?? city.jobMarketScore ?? '—')}/100</strong>.</p>
${
  industries.length
    ? `<div class="grid">${industries.map((i) => `<span class="chip">${esc(i)}</span>`).join('')}</div>`
    : ''
}

<h2>¿Por qué ${esc(city.name)}?</h2>
<ul>
<li>Adaptación de idioma (español): ${esc(scores.languageAdaptation ?? '—')}/100</li>
<li>Costo / accesibilidad: ${esc(scores.economical ?? '—')}/100</li>
<li>Popularidad entre argentinos: ${esc(scores.popularForArgentinians ?? '—')}/100</li>
</ul>

<h2>Trámites para argentinos</h2>
<ul>
<li>Residencia por el Acuerdo Mercosur (hasta 2 años, renovable): iniciar dentro de los 90 días.</li>
<li>CPF, cuenta bancaria y comprobante de domicilio.</li>
<li>Convalidación de la licencia de conducir y revalidación de título.</li>
</ul>

<a class="cta" href="${esc(BASE_URL)}">Planificá tu mudanza con Movaro</a>
`;

  return pageShell({ title, description, canonical, body });
}

function indexPage(cities) {
  const byRegion = new Map();
  for (const c of cities) {
    const key = c.regionName || 'Brasil';
    if (!byRegion.has(key)) byRegion.set(key, []);
    byRegion.get(key).push(c);
  }
  const sections = [...byRegion.entries()]
    .sort((a, b) => a[0].localeCompare(b[0]))
    .map(([region, list]) => {
      list.sort((a, b) => a.name.localeCompare(b.name));
      const links = list
        .map(
          (c) =>
            `<li><a href="/cidades/${esc(c.id)}.html">${esc(c.name)} (${esc(c.stateCode)})</a></li>`,
        )
        .join('');
      return `<h2>${esc(region)}</h2><nav class="cities"><ul>${links}</ul></nav>`;
    })
    .join('');

  const body = `
<h1>Vivir en Brasil siendo argentino</h1>
<p class="sub">Costo de vida, trabajo y trámites por ciudad — para decidir con
claridad y empezar con el pie derecho.</p>
${sections}
<a class="cta" href="${esc(BASE_URL)}">Abrir Movaro</a>
`;
  return pageShell({
    title: 'Vivir en Brasil siendo argentino: ciudades, costo y trabajo | Movaro',
    description:
      'Guía por ciudad para mudarte de Argentina a Brasil: costo de vida, mercado laboral y trámites (Mercosur, CPF, CNH).',
    canonical: `${BASE_URL}/`,
    body,
  });
}

function sitemap(cities) {
  const urls = [
    `${BASE_URL}/`,
    ...cities.map((c) => `${BASE_URL}/cidades/${c.id}.html`),
  ];
  const items = urls
    .map((u) => `  <url><loc>${esc(u)}</loc></url>`)
    .join('\n');
  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${items}
</urlset>
`;
}

function main() {
  const cities = JSON.parse(fs.readFileSync(SNAPSHOT, 'utf8'));
  fs.mkdirSync(CITIES_DIR, { recursive: true });

  for (const city of cities) {
    fs.writeFileSync(
      path.join(CITIES_DIR, `${city.id}.html`),
      cityPage(city),
    );
  }
  fs.writeFileSync(path.join(OUT_DIR, 'index.html'), indexPage(cities));
  fs.writeFileSync(path.join(OUT_DIR, 'sitemap.xml'), sitemap(cities));
  fs.writeFileSync(
    path.join(OUT_DIR, 'robots.txt'),
    `User-agent: *\nAllow: /\nSitemap: ${BASE_URL}/sitemap.xml\n`,
  );

  console.log(
    `Generated ${cities.length} city pages + index + sitemap to ${path.relative(process.cwd(), OUT_DIR)}`,
  );
}

main();
