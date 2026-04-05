import { Injectable } from '@nestjs/common';

import { BcbExchangeRateService } from '../../../../integrations/exchange/bcb-exchange-rate.service';
import { BcraExchangeRateService } from '../../../../integrations/exchange/bcra-exchange-rate.service';
import { OpenExchangeRateService } from '../../../../integrations/exchange/open-exchange-rate.service';

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
  source: 'official';
  sources: string[];
};

@Injectable()
export class ExchangeRatesService {
  constructor(
    private readonly bcbExchangeRateService: BcbExchangeRateService,
    private readonly bcraExchangeRateService: BcraExchangeRateService,
    private readonly openExchangeRateService: OpenExchangeRateService,
  ) {}

  private cache: ExchangeRatesSnapshot | null = null;
  private cacheExpiresAt = 0;
  private readonly cacheTtlMs = 1000 * 60 * 60 * 6;

  async getCurrentRates(): Promise<ExchangeRatesSnapshot> {
    const now = Date.now();
    if (this.cache != null && now < this.cacheExpiresAt) {
      return this.cache;
    }

    const [bcb, bcra, open] = await Promise.all([
      this.bcbExchangeRateService.getUsdToBrl(),
      this.bcraExchangeRateService.getBrlToArs(),
      this.openExchangeRateService.getUsdRates(),
    ]);

    const usdToBrl = bcb.usdToBrl;
    const brlToArs = bcra.brlToArs;
    const brlToUsd = 1 / usdToBrl;
    const arsToBrl = 1 / brlToArs;
    const usdToArs = usdToBrl * brlToArs;
    const arsToUsd = 1 / usdToArs;

    // Derive BRL-based rates from USD-based rates
    const brlToEur = brlToUsd * open.usdToEur;
    const brlToClp = brlToUsd * open.usdToClp;
    const brlToUyu = brlToUsd * open.usdToUyu;
    const brlToCop = brlToUsd * open.usdToCop;
    const brlToPen = brlToUsd * open.usdToPen;
    const brlToPyg = brlToUsd * open.usdToPyg;
    const brlToBob = brlToUsd * open.usdToBob;

    const snapshot: ExchangeRatesSnapshot = {
      usdToBrl,
      brlToUsd,
      brlToArs,
      arsToBrl,
      usdToArs,
      arsToUsd,
      brlToEur,
      brlToClp,
      brlToUyu,
      brlToCop,
      brlToPen,
      brlToPyg,
      brlToBob,
      fetchedAt: new Date().toISOString(),
      source: 'official',
      sources: [
        `BCB SGS 1 ${bcb.referenceDate}`,
        `BCRA Cotizaciones ${bcra.referenceDate}`,
        `CurrencyAPI ${open.referenceDate}`,
      ],
    };

    this.cache = snapshot;
    this.cacheExpiresAt = now + this.cacheTtlMs;
    return snapshot;
  }
}
