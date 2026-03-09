import { ArgumentsHost } from '@nestjs/common';
import { ApiError } from '../api/api-error.interface';
export declare class HttpExceptionMapper {
    static toApiError(exception: unknown, host: ArgumentsHost): ApiError;
    private static extractMessage;
    private static getTraceId;
    private static internalMessage;
}
