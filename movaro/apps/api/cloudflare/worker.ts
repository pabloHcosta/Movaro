import { Container, getContainer } from '@cloudflare/containers';

declare global {
  namespace Cloudflare {
    interface Env {
      SUPABASE_URL: string;
      SUPABASE_SECRET_KEY: string;
      GOOGLE_PLACES_API_KEY: string;
      GEMINI_API_KEY: string;
      GROQ_API_KEY: string;
    }
  }
}

export class MudaviApiContainer extends Container {
  defaultPort = 8080;
  sleepAfter = '10m';
  enableInternet = true;
  envVars: Record<string, string> = {
    NODE_ENV: 'production',
    APP_NAME: 'Mudavi API',
    HOST: '0.0.0.0',
    PORT: '8080',
    TRUST_PROXY: 'true',
    ALLOWED_ORIGINS: this.env.ALLOWED_ORIGINS,
    SUPABASE_URL: this.env.SUPABASE_URL,
    SUPABASE_SECRET_KEY: this.env.SUPABASE_SECRET_KEY,
    GOOGLE_PLACES_API_KEY: this.env.GOOGLE_PLACES_API_KEY,
    GEMINI_API_KEY: this.env.GEMINI_API_KEY,
    GROQ_API_KEY: this.env.GROQ_API_KEY,
  };
}

export default {
  async fetch(request, env): Promise<Response> {
    return getContainer(env.API_CONTAINER, 'production').fetch(request);
  },
} satisfies ExportedHandler<Cloudflare.Env>;
