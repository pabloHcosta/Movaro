import { AppEnvironment } from '../environment.enum';

export type AppConfiguration = {
  app: {
    name: string;
    nodeEnv: AppEnvironment;
  };
  server: {
    host: string;
    port: number;
    globalPrefix: string;
    allowedOrigins: string[];
    bodyLimitBytes: number;
    rateLimitMax: number;
    rateLimitWindowMs: number;
    trustProxy: boolean;
    outboundRequestTimeoutMs: number;
  };
  supabase: {
    url: string | null;
    secretKey: string | null;
    configured: boolean;
  };
  googlePlaces: {
    apiKey: string | null;
    configured: boolean;
  };
  gemini: {
    apiKey: string | null;
    configured: boolean;
  };
};
