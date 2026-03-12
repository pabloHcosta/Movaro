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
  fetchedAt: string;
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
      this.bcraExchangeRateService.getBrlToArs(),
    ]);

    const usdToBrl = bcb.usdToBrl;
    const brlToArs = bcra.brlToArs;
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
      fetchedAt: new Date().toISOString(),
      source: 'official',
      sources: [
        `BCB SGS 1 ${bcb.referenceDate}`,
        `BCRA Cotizaciones ${bcra.referenceDate}`,
      ],
    };

    this.cache = snapshot;
    this.cacheExpiresAt = now + this.cacheTtlMs;
    return snapshot;
  }
}
