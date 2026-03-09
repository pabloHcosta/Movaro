import { Injectable } from '@nestjs/common';

import { AppErrorFactory } from '../../common/errors/app-error.factory';
import { AppConfigService } from '../../common/config/app-config.service';

@Injectable()
export class IbgeHttpClient {
  constructor(private readonly appConfigService: AppConfigService) {}

  private readonly baseUrl = 'https://servicodados.ibge.gov.br/api/v1';

  async get<T>(path: string): Promise<T> {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      this.appConfigService.outboundRequestTimeoutMs,
    );

    try {
      const response = await fetch(`${this.baseUrl}${path}`, {
        headers: {
          accept: 'application/json',
        },
        signal: controller.signal,
      });

      if (!response.ok) {
        throw AppErrorFactory.networkError(
          `IBGE request failed with status ${response.status}.`,
        );
      }

      return (await response.json()) as T;
    } catch (error) {
      if (error instanceof Error && 'getPayload' in error) {
        throw error;
      }

      if (error instanceof Error && error.name === 'AbortError') {
        throw AppErrorFactory.networkError('IBGE request timed out.');
      }

      throw AppErrorFactory.networkError(
        error instanceof Error
          ? error.message
          : 'Unable to reach IBGE data source.',
      );
    } finally {
      clearTimeout(timeout);
    }
  }
}
