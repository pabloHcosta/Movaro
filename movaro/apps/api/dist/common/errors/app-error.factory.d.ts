import { AppException } from './app-exception';
export declare class AppErrorFactory {
    static cityNotFound(cityId: string): AppException;
    static validationError(message: string, userMessage?: string): AppException;
    static unauthorized(message?: string, userMessage?: string): AppException;
    static resourceNotFound(resource: string, userMessage?: string): AppException;
    static networkError(message: string, userMessage?: string): AppException;
    static internal(message?: string, userMessage?: string): AppException;
}
