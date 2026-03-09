import {
  CallHandler,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, catchError, tap, throwError } from 'rxjs';

import { HttpDebugLoggerService } from '../logging/http-debug-logger.service';

type HttpRequest = {
  method?: string;
  url?: string;
  query?: unknown;
  params?: unknown;
  body?: unknown;
  traceId?: string;
  ip?: string;
  headers?: Record<string, string | string[] | undefined>;
};

type HttpResponse = {
  statusCode?: number;
};

@Injectable()
export class HttpDebugLoggingInterceptor implements NestInterceptor {
  constructor(private readonly debugLogger: HttpDebugLoggerService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    if (context.getType() !== 'http' || !this.debugLogger.isEnabled) {
      return next.handle();
    }

    const http = context.switchToHttp();
    const request = http.getRequest<HttpRequest>();
    const response = http.getResponse<HttpResponse>();
    const startedAt = Date.now();

    this.debugLogger.logRequest(request);

    return next.handle().pipe(
      tap((payload) => {
        this.debugLogger.logResponse(
          request,
          response.statusCode ?? HttpStatus.OK,
          Date.now() - startedAt,
          payload,
        );
      }),
      catchError((error: unknown) => {
        const statusCode =
          error instanceof HttpException
            ? error.getStatus()
            : HttpStatus.INTERNAL_SERVER_ERROR;

        this.debugLogger.logError(
          request,
          statusCode,
          Date.now() - startedAt,
          error,
        );

        return throwError(() => error);
      }),
    );
  }
}
