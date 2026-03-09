import { Injectable, Logger } from '@nestjs/common';

import { AppConfigService } from '../config/app-config.service';
import { AppEnvironment } from '../config/environment.enum';

type RequestLike = {
  method?: string;
  url?: string;
  query?: unknown;
  params?: unknown;
  body?: unknown;
  traceId?: string;
  ip?: string;
  headers?: Record<string, string | string[] | undefined>;
};

@Injectable()
export class HttpDebugLoggerService {
  private readonly logger = new Logger('HttpDebug');

  constructor(private readonly appConfig: AppConfigService) {}

  get isEnabled(): boolean {
    return (
      this.appConfig.nodeEnv === AppEnvironment.Development ||
      this.appConfig.nodeEnv === AppEnvironment.Staging
    );
  }

  logRequest(request: RequestLike): void {
    if (!this.isEnabled) {
      return;
    }

    const source = this.resolveSource(request);
    const healthCheck = this.resolveHealthCheck(request);

    this.logger.log(
      [
        healthCheck != null ? `[APP_HEALTH:${healthCheck}]` : '[REQUEST]',
        `${request.method ?? 'UNKNOWN'} ${request.url ?? '-'}`,
        `source=${source}`,
        `traceId=${request.traceId ?? '-'}`,
        `ip=${request.ip ?? '-'}`,
        `query=${this.stringify(request.query)}`,
        `params=${this.stringify(request.params)}`,
        `body=${this.stringify(request.body)}`,
      ].join(' | '),
    );
  }

  logResponse(
    request: RequestLike,
    statusCode: number,
    durationMs: number,
    payload: unknown,
  ): void {
    if (!this.isEnabled) {
      return;
    }

    const source = this.resolveSource(request);
    const healthCheck = this.resolveHealthCheck(request);

    this.logger.log(
      [
        healthCheck != null ? '[APP_CONNECTED]' : '[RESPONSE]',
        `${request.method ?? 'UNKNOWN'} ${request.url ?? '-'} -> ${statusCode}`,
        `source=${source}`,
        `traceId=${request.traceId ?? '-'}`,
        `duration=${durationMs}ms`,
        `response=${this.stringify(payload)}`,
      ].join(' | '),
    );
  }

  logError(
    request: RequestLike,
    statusCode: number,
    durationMs: number,
    error: unknown,
  ): void {
    if (!this.isEnabled) {
      return;
    }

    const source = this.resolveSource(request);
    const healthCheck = this.resolveHealthCheck(request);

    this.logger.error(
      [
        healthCheck != null ? '[APP_HEALTH_ERROR]' : '[ERROR]',
        `${request.method ?? 'UNKNOWN'} ${request.url ?? '-'} -> ${statusCode}`,
        `source=${source}`,
        `traceId=${request.traceId ?? '-'}`,
        `duration=${durationMs}ms`,
        `error=${this.stringify(this.normalizeError(error))}`,
      ].join(' | '),
    );
  }

  private normalizeError(error: unknown): Record<string, unknown> {
    if (error instanceof Error) {
      return {
        name: error.name,
        message: error.message,
        stack: error.stack?.split('\n').slice(0, 6).join(' | '),
      };
    }

    if (typeof error === 'object' && error !== null) {
      return error as Record<string, unknown>;
    }

    return { value: error };
  }

  private stringify(value: unknown): string {
    if (value === undefined) {
      return '-';
    }

    try {
      const seen = new WeakSet<object>();
      const serialized = JSON.stringify(
        value,
        (_key, currentValue: unknown) => {
          if (
            typeof currentValue === 'string' &&
            currentValue.length > 500
          ) {
            return `${currentValue.slice(0, 500)}…`;
          }

          if (
            typeof currentValue === 'object' &&
            currentValue !== null
          ) {
            if (seen.has(currentValue as object)) {
              return '[Circular]';
            }
            seen.add(currentValue as object);
          }

          return currentValue;
        },
      );

      if (serialized == null) {
        return String(value);
      }

      return serialized.length > 2000
          ? `${serialized.slice(0, 2000)}…`
          : serialized;
    } catch {
      return '[Unserializable]';
    }
  }

  private resolveSource(request: RequestLike): string {
    const clientHeader = request.headers?.['x-movaro-client'];
    const source = Array.isArray(clientHeader) ? clientHeader[0] : clientHeader;

    if (typeof source === 'string' && source.trim().length > 0) {
      return source;
    }

    return 'unknown';
  }

  private resolveHealthCheck(request: RequestLike): string | undefined {
    const healthHeader = request.headers?.['x-movaro-health-check'];
    const value = Array.isArray(healthHeader) ? healthHeader[0] : healthHeader;

    if (typeof value === 'string' && value.trim().length > 0) {
      return value;
    }

    return undefined;
  }
}
