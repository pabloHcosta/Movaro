import { Injectable } from '@nestjs/common';

import { AppConfigService } from '../../common/config/app-config.service';
import { AppErrorFactory } from '../../common/errors/app-error.factory';

type BcbSeriesItem = {
  data?: string;
  valor?: string;
};

export type BcbUsdBrlSnapshot = {
  usdToBrl: number;
  referenceDate: string;
};

@Injectable()
export class BcbExchangeRateService {
  constructor(private readonly appConfigService: AppConfigService) {}

  private readonly usdToBrlUrl =
    'https://api.bcb.gov.br/dados/serie/bcdata.sgs.1/dados/ultimos/1?formato=json';

  async getUsdToBrl(): Promise<BcbUsdBrlSnapshot> {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      this.appConfigService.outboundRequestTimeoutMs,
    );

    try {
      const response = await fetch(this.usdToBrlUrl, {
        headers: {
          accept: 'application/json',
        },
        signal: controller.signal,
      });

      if (!response.ok) {
        throw AppErrorFactory.networkError(
          `BCB exchange request failed with status ${response.status}.`,
        );
      }

      const payload = (await response.json()) as BcbSeriesItem[];
      const latest = payload[0];
      if (!latest?.valor || !latest.data) {
        throw AppErrorFactory.networkError(
          'BCB exchange response does not include the latest USD/BRL value.',
        );
      }

      return {
        usdToBrl: Number(latest.valor),
        referenceDate: latest.data,
      };
    } catch (error) {
      if (error instanceof Error && 'getPayload' in error) {
        throw error;
      }

      if (error instanceof Error && error.name === 'AbortError') {
        throw AppErrorFactory.networkError('BCB exchange request timed out.');
      }

      throw AppErrorFactory.networkError(
        error instanceof Error
          ? error.message
          : 'Unable to reach the BCB exchange data source.',
      );
    } finally {
      clearTimeout(timeout);
    }
  }
}
