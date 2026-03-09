import { HttpException } from '@nestjs/common';
import { ErrorCode } from './error-code.enum';
export interface AppExceptionPayload {
    code: ErrorCode;
    message: string;
    userMessage: string;
    status: number;
}
export declare class AppException extends HttpException {
    private readonly payload;
    constructor(payload: AppExceptionPayload);
    getPayload(): AppExceptionPayload;
}
