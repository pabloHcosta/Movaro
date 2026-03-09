import { CallHandler, ExecutionContext, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { HttpDebugLoggerService } from '../logging/http-debug-logger.service';
export declare class HttpDebugLoggingInterceptor implements NestInterceptor {
    private readonly debugLogger;
    constructor(debugLogger: HttpDebugLoggerService);
    intercept(context: ExecutionContext, next: CallHandler): Observable<unknown>;
}
