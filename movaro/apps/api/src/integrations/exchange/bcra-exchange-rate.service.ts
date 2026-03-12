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

export type BcraBrlArsSnapshot = {
  brlToArs: number;
  referenceDate: string;
};

@Injectable()
export class BcraExchangeRateService {
  constructor(private readonly appConfigService: AppConfigService) {}

  private readonly quotationsUrl =
    'https://api.bcra.gob.ar/estadisticascambiarias/v1.0/Cotizaciones';

  async getBrlToArs(): Promise<BcraBrlArsSnapshot> {
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
      const brlQuote = detail.find((item) => item.codigoMoneda === 'BRL');
      if (brlQuote?.tipoCotizacion == null || !payload.results?.fecha) {
        throw AppErrorFactory.networkError(
          'BCRA exchange response does not include the latest BRL/ARS value.',
        );
      }

      return {
        brlToArs: brlQuote.tipoCotizacion,
        referenceDate: payload.results.fecha,
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
