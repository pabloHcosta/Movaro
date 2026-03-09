import { Injectable, NestMiddleware } from '@nestjs/common';
import { randomUUID } from 'node:crypto';

@Injectable()
export class TraceIdMiddleware implements NestMiddleware {
  use(
    req: {
      headers: Record<string, string | string[] | undefined>;
      traceId?: string;
    },
    res: { setHeader: (name: string, value: string) => void },
    next: () => void,
  ): void {
    const requestTraceId = req.headers['x-trace-id'];
    const traceId =
      typeof requestTraceId === 'string' && isSafeTraceId(requestTraceId)
        ? requestTraceId.trim()
        : randomUUID();

    req.traceId = traceId;
    res.setHeader('x-trace-id', traceId);
    next();
  }
}

function isSafeTraceId(value: string): boolean {
  const trimmed = value.trim();
  return (
    trimmed.length > 0 &&
    trimmed.length <= 128 &&
    /^[a-zA-Z0-9-]+$/.test(trimmed)
  );
}
