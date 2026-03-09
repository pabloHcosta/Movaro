import {
  ArgumentsHost,
  BadRequestException,
  HttpException,
  HttpStatus,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { randomUUID } from 'node:crypto';

import { ApiError } from '../api/api-error.interface';
import { AppException } from './app-exception';
import { AppErrorFactory } from './app-error.factory';
import { ErrorCode } from './error-code.enum';

export class HttpExceptionMapper {
  static toApiError(exception: unknown, host: ArgumentsHost): ApiError {
    const traceId = this.getTraceId(host);

    if (exception instanceof AppException) {
      const payload = exception.getPayload();

      return {
        code: payload.code,
        message: payload.message,
        userMessage: payload.userMessage,
        status: payload.status,
        traceId,
      };
    }

    if (exception instanceof BadRequestException) {
      return {
        code: ErrorCode.ValidationError,
        message: this.extractMessage(exception),
        userMessage: 'Revise os dados enviados e tente novamente.',
        status: exception.getStatus(),
        traceId,
      };
    }

    if (exception instanceof UnauthorizedException) {
      return {
        code: ErrorCode.Unauthorized,
        message: this.extractMessage(exception),
        userMessage: 'Voce precisa entrar para continuar essa acao.',
        status: exception.getStatus(),
        traceId,
      };
    }

    if (exception instanceof NotFoundException) {
      return {
        code: ErrorCode.ResourceNotFound,
        message: this.extractMessage(exception),
        userMessage: 'Nao encontramos o recurso solicitado.',
        status: exception.getStatus(),
        traceId,
      };
    }

    if (exception instanceof HttpException) {
      return {
        code: ErrorCode.InternalError,
        message: this.extractMessage(exception),
        userMessage: 'Nao foi possivel concluir a solicitacao agora.',
        status: exception.getStatus(),
        traceId,
      };
    }

    const fallback = AppErrorFactory.internal(
      this.internalMessage(exception),
    ).getPayload();

    return {
      code: fallback.code,
      message: fallback.message,
      userMessage: fallback.userMessage,
      status: fallback.status,
      traceId,
    };
  }

  private static extractMessage(exception: HttpException): string {
    const response = exception.getResponse();

    if (typeof response === 'string') {
      return response;
    }

    if (
      response &&
      typeof response === 'object' &&
      'message' in response &&
      typeof response.message === 'string'
    ) {
      return response.message;
    }

    if (
      response &&
      typeof response === 'object' &&
      'message' in response &&
      Array.isArray(response.message)
    ) {
      return response.message.join(', ');
    }

    return exception.message ?? HttpStatus[exception.getStatus()];
  }

  private static getTraceId(host: ArgumentsHost): string | undefined {
    const request = host.switchToHttp().getRequest<{
      traceId?: string;
      id?: string;
      raw?: { traceId?: string; id?: string };
    }>();

    return (
      request.traceId ??
      request.raw?.traceId ??
      request.id ??
      request.raw?.id ??
      randomUUID()
    );
  }

  private static internalMessage(exception: unknown): string {
    const isDevelopment = process.env.NODE_ENV === 'development';
    if (!isDevelopment) {
      return 'Unexpected internal error.';
    }

    return exception instanceof Error
      ? exception.message
      : 'Unexpected internal error.';
  }
}
