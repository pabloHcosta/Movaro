import { Injectable } from '@nestjs/common';

import { AppConfigService } from '../../common/config/app-config.service';
import { AppErrorFactory } from '../../common/errors/app-error.factory';

type BcraQuotationItem = {
  codigoMoneda?: string;
  descripcion?: string;
  tipoCotizacion?: number;
};

type BcraQuotationResponse = {
  results?: {
    fecha?: string;
    detalle?: BcraQuotationItem[];
  };
};

export type BcraRegionalRatesSnapshot = {
  brlToArs: number;
  brlToEur: number;
  brlToClp: number;
  brlToUyu: number;
  brlToCop: number;
  brlToPen: number;
  brlToPyg: number;
  brlToBob: number;
  usdReferenceToArs: number;
  referenceDate: string;
};

@Injectable()
export class BcraExchangeRateService {
  constructor(private readonly appConfigService: AppConfigService) {}

  private readonly quotationsUrl =
    'https://api.bcra.gob.ar/estadisticascambiarias/v1.0/Cotizaciones';

  async getRegionalRates(): Promise<BcraRegionalRatesSnapshot> {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      this.appConfigService.outboundRequestTimeoutMs,
    );

    try {
      const response = await fetch(this.quotationsUrl, {
        headers: {
          accept: 'application/json',
        },
        signal: controller.signal,
      });

      if (!response.ok) {
        throw AppErrorFactory.networkError(
          `BCRA exchange request failed with status ${response.status}.`,
        );
      }

      const payload = (await response.json()) as BcraQuotationResponse;
      const detail = payload.results?.detalle ?? [];
      const quote = (code: string): number => {
        const value = detail.find(
          (item) => item.codigoMoneda === code,
        )?.tipoCotizacion;
        if (
          typeof value !== 'number' ||
          !Number.isFinite(value) ||
          value <= 0
        ) {
          throw AppErrorFactory.networkError(
            `BCRA exchange response does not include a valid ${code} quotation.`,
          );
        }
        return value;
      };
      const referenceDate = payload.results?.fecha;
      if (!referenceDate) {
        throw AppErrorFactory.networkError(
          'BCRA exchange response does not include a reference date.',
        );
      }
      const brlInArs = quote('BRL');

      return {
        brlToArs: brlInArs,
        brlToEur: brlInArs / quote('EUR'),
        brlToClp: brlInArs / quote('CLP'),
        brlToUyu: brlInArs / quote('UYU'),
        brlToCop: brlInArs / quote('COP'),
        brlToPen: brlInArs / quote('PEN'),
        brlToPyg: brlInArs / quote('PYG'),
        brlToBob: brlInArs / quote('BOB'),
        usdReferenceToArs: quote('REF'),
        referenceDate,
      };
    } catch (error) {
      if (error instanceof Error && 'getPayload' in error) {
        throw error;
      }

      if (error instanceof Error && error.name === 'AbortError') {
        throw AppErrorFactory.networkError('BCRA exchange request timed out.');
      }

      throw AppErrorFactory.networkError(
        error instanceof Error
          ? error.message
          : 'Unable to reach the BCRA exchange data source.',
      );
    } finally {
      clearTimeout(timeout);
    }
  }
}
