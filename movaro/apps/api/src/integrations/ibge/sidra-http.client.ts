import { Injectable } from '@nestjs/common';

import { AppConfigService } from '../../common/config/app-config.service';
import { AppErrorFactory } from '../../common/errors/app-error.factory';

@Injectable()
export class SidraHttpClient {
  constructor(private readonly appConfigService: AppConfigService) {}

  private readonly baseUrl = 'https://apisidra.ibge.gov.br';

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
          `SIDRA request failed with status ${response.status}.`,
        );
      }

      return (await response.json()) as T;
    } catch (error) {
      if (error instanceof Error && 'getPayload' in error) {
        throw error;
      }

      if (error instanceof Error && error.name === 'AbortError') {
        throw AppErrorFactory.networkError('SIDRA request timed out.');
      }

      throw AppErrorFactory.networkError(
        error instanceof Error
          ? error.message
          : 'Unable to reach SIDRA data source.',
      );
    } finally {
      clearTimeout(timeout);
    }
  }
}
