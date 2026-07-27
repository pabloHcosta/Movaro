Official city metric imports

These files feed `official_city_metrics.json`, which is the backend override layer
used by the app for official or externally-audited domain snapshots.

Files:
- `development_official.json`
- `employment_official.json`
- `safety_official.json`

Each record may use either `cityId` or `ibgeCode` and a single domain payload:

```json
{
  "cityId": "rio-de-janeiro-rj",
  "ibgeCode": 3304557,
  "employment": {
    "unemploymentRate": 7.3,
    "jobMarketScore": 74,
    "economicActivityScore": 83,
    "topIndustries": ["Serviços", "Turismo", "Energia"],
    "sourceLabel": "Novo Caged / MTE",
    "sourceUrl": "https://www.gov.br/trabalho-e-emprego/pt-br/servicos/empregador/caged",
    "sourceType": "official",
    "updatedAt": "2026-03-31"
  }
}
```

After updating the import files, run:

```bash
npm run ingest:official-city-metrics
```

That script regenerates:
- `src/modules/cities/data/seeds/official_city_metrics.json`

## Safety

Safety uses the municipal registered-homicide series from Atlas da Violencia /
Ipea (SIM/MS). Refresh it with:

```bash
npm run sync:ipea-safety
```

The importer uses the latest three-year municipal window to reduce annual
volatility. It converts that rate into a bounded lethal-violence signal and
blends it with a smaller share of the broader curated score. The result is a
derived comparison signal, not an official safety ranking. It does not cover
property crime, harassment, neighborhood differences, or personal routine.
