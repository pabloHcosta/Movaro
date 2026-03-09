import { HttpException } from '@nestjs/common';

import { ErrorCode } from './error-code.enum';

export interface AppExceptionPayload {
  code: ErrorCode;
  message: string;
  userMessage: string;
  status: number;
}

export class AppException extends HttpException {
  constructor(private readonly payload: AppExceptionPayload) {
    super(
      {
        code: payload.code,
        message: payload.message,
        userMessage: payload.userMessage,
        status: payload.status,
      },
      payload.status,
    );
  }

  getPayload(): AppExceptionPayload {
    return this.payload;
  }
}
