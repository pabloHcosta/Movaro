import { Injectable } from '@nestjs/common';

import { BcbExchangeRateService } from '../../../../integrations/exchange/bcb-exchange-rate.service';
import { BcraExchangeRateService } from '../../../../integrations/exchange/bcra-exchange-rate.service';

type ExchangeRatesSnapshot = {
  usdToBrl: number;
  brlToUsd: number;
  brlToArs: number;
  arsToBrl: number;
  usdToArs: number;
  arsToUsd: number;
  brlToEur: number;
  brlToClp: number;
  brlToUyu: number;
  brlToCop: number;
  brlToPen: number;
  brlToPyg: number;
  brlToBob: number;
  fetchedAt: string;
  referenceDate: string;
  isIndicative: true;
  source: 'official';
  sources: string[];
};

@Injectable()
export class ExchangeRatesService {
  constructor(
    private readonly bcbExchangeRateService: BcbExchangeRateService,
    private readonly bcraExchangeRateService: BcraExchangeRateService,
  ) {}

  private cache: ExchangeRatesSnapshot | null = null;
  private cacheExpiresAt = 0;
  private readonly cacheTtlMs = 1000 * 60 * 60 * 6;

  async getCurrentRates(): Promise<ExchangeRatesSnapshot> {
    const now = Date.now();
    if (this.cache != null && now < this.cacheExpiresAt) {
      return this.cache;
    }

    const [bcb, bcra] = await Promise.all([
      this.bcbExchangeRateService.getUsdToBrl(),
      this.bcraExchangeRateService.getRegionalRates(),
    ]);

    const usdToBrl = bcb.usdToBrl;
    const brlToArs = bcra.brlToArs;
    this.assertRecentReference(bcb.referenceDate, 'BCB', true);
    this.assertRecentReference(bcra.referenceDate, 'BCRA');
    this.assertCrossRateConsistency(
      usdToBrl,
      bcra.usdReferenceToArs / brlToArs,
    );
    const brlToUsd = 1 / usdToBrl;
    const arsToBrl = 1 / brlToArs;
    const usdToArs = usdToBrl * brlToArs;
    const arsToUsd = 1 / usdToArs;

    const snapshot: ExchangeRatesSnapshot = {
      usdToBrl,
      brlToUsd,
      brlToArs,
      arsToBrl,
      usdToArs,
      arsToUsd,
      brlToEur: bcra.brlToEur,
      brlToClp: bcra.brlToClp,
      brlToUyu: bcra.brlToUyu,
      brlToCop: bcra.brlToCop,
      brlToPen: bcra.brlToPen,
      brlToPyg: bcra.brlToPyg,
      brlToBob: bcra.brlToBob,
      fetchedAt: new Date().toISOString(),
      referenceDate: bcra.referenceDate,
      isIndicative: true,
      source: 'official',
      sources: [
        `Banco Central do Brasil · SGS 1 · ${bcb.referenceDate}`,
        `Banco Central de la República Argentina · Estadísticas Cambiarias · ${bcra.referenceDate}`,
      ],
    };

    this.cache = snapshot;
    this.cacheExpiresAt = now + this.cacheTtlMs;
    return snapshot;
  }

  private assertRecentReference(
    value: string,
    source: string,
    dayFirst = false,
  ): void {
    const parsed = dayFirst
      ? this.parseDayFirstDate(value)
      : new Date(`${value}T12:00:00Z`);
    if (Number.isNaN(parsed.getTime())) {
      throw new Error(`${source} returned an invalid reference date.`);
    }
    const ageDays = (Date.now() - parsed.getTime()) / 86_400_000;
    if (ageDays < -1 || ageDays > 8) {
      throw new Error(`${source} exchange reference is stale.`);
    }
  }

  private parseDayFirstDate(value: string): Date {
    const [day, month, year] = value.split('/').map(Number);
    return new Date(Date.UTC(year, month - 1, day, 12));
  }

  private assertCrossRateConsistency(
    bcbUsdToBrl: number,
    bcraImpliedUsdToBrl: number,
  ): void {
    const divergence =
      Math.abs(bcbUsdToBrl - bcraImpliedUsdToBrl) / bcbUsdToBrl;
    if (!Number.isFinite(divergence) || divergence > 0.05) {
      throw new Error('Official exchange sources diverge beyond 5%.');
    }
  }
}
