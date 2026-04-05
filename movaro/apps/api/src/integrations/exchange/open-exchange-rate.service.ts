import { Injectable } from '@nestjs/common';

import { AppConfigService } from '../../common/config/app-config.service';
import { AppErrorFactory } from '../../common/errors/app-error.factory';

type CurrencyApiResponse = {
  date?: string;
  usd?: Record<string, number>;
};

export type MultiCurrencyRatesSnapshot = {
  usdToEur: number;
  usdToClp: number;
  usdToUyu: number;
  usdToCop: number;
  usdToPen: number;
  usdToPyg: number;
  usdToBob: number;
  referenceDate: string;
};

@Injectable()
export class OpenExchangeRateService {
  constructor(private readonly appConfigService: AppConfigService) {}

  // Free, no-auth currency API backed by Cloudflare Workers.
  // Provides daily rates for all major currencies relative to USD.
  private readonly ratesUrl =
    'https://latest.currency-api.pages.dev/v1/currencies/usd.json';

  async getUsdRates(): Promise<MultiCurrencyRatesSnapshot> {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      this.appConfigService.outboundRequestTimeoutMs,
    );

    try {
      const response = await fetch(this.ratesUrl, {
        headers: { accept: 'application/json' },
        signal: controller.signal,
      });

      if (!response.ok) {
        throw AppErrorFactory.networkError(
          `Open exchange rate request failed with status ${response.status}.`,
        );
      }

      const payload = (await response.json()) as CurrencyApiResponse;
      const rates = payload.usd;

      if (!rates || typeof rates !== 'object') {
        throw AppErrorFactory.networkError(
          'Open exchange rate response does not contain USD rates.',
        );
      }

      const get = (code: string, fallback: number): number => {
        const value = rates[code.toLowerCase()];
        return typeof value === 'number' && value > 0 ? value : fallback;
      };

      return {
        usdToEur: get('eur', 0.92),
        usdToClp: get('clp', 940.0),
        usdToUyu: get('uyu', 41.0),
        usdToCop: get('cop', 4200.0),
        usdToPen: get('pen', 3.75),
        usdToPyg: get('pyg', 7800.0),
        usdToBob: get('bob', 6.9),
        referenceDate: payload.date ?? new Date().toISOString().slice(0, 10),
      };
    } catch (error) {
      if (error instanceof Error && 'getPayload' in error) {
        throw error;
      }

      if (error instanceof Error && error.name === 'AbortError') {
        throw AppErrorFactory.networkError(
          'Open exchange rate request timed out.',
        );
      }

      throw AppErrorFactory.networkError(
        error instanceof Error
          ? error.message
          : 'Unable to reach the open exchange rate data source.',
      );
    } finally {
      clearTimeout(timeout);
    }
  }
}
