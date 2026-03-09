import { NestMiddleware } from '@nestjs/common';
export declare class TraceIdMiddleware implements NestMiddleware {
    use(req: {
        headers: Record<string, string | string[] | undefined>;
        traceId?: string;
    }, res: {
        setHeader: (name: string, value: string) => void;
    }, next: () => void): void;
}
