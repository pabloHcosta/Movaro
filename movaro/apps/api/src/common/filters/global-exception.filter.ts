import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';

import { ApiResponse } from '../api/api-response.interface';
import { HttpExceptionMapper } from '../errors/http-exception.mapper';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost): void {
    const context = host.switchToHttp();
    const response = context.getResponse<{
      raw?: {
        statusCode: number;
        setHeader: (name: string, value: string) => void;
        end: (body: string) => void;
      };
      statusCode: number;
      setHeader: (name: string, value: string) => void;
      end: (body: string) => void;
    }>();
    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;
    const payload: ApiResponse<never> = {
      success: false,
      error: HttpExceptionMapper.toApiError(exception, host),
    };
    const rawResponse = response.raw ?? response;

    rawResponse.statusCode = status;
    rawResponse.setHeader('content-type', 'application/json; charset=utf-8');
    rawResponse.end(JSON.stringify(payload));
  }
}
