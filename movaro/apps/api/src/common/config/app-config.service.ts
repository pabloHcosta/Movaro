import { Inject, Injectable } from '@nestjs/common';

import { AppEnvironment } from './environment.enum';
import type { AppConfiguration } from './types/app-configuration.type';

@Injectable()
export class AppConfigService {
  constructor(
    @Inject('APP_CONFIGURATION')
    private readonly config: AppConfiguration,
  ) {}

  get appName(): string {
    return this.config.app.name;
  }

  get nodeEnv(): AppEnvironment {
    return this.config.app.nodeEnv;
  }

  get host(): string {
    return this.config.server.host;
  }

  get port(): number {
    return this.config.server.port;
  }

  get globalPrefix(): string {
    return this.config.server.globalPrefix;
  }

  get allowedOrigins(): string[] {
    return this.config.server.allowedOrigins;
  }

  get bodyLimitBytes(): number {
    return this.config.server.bodyLimitBytes;
  }

  get rateLimitMax(): number {
    return this.config.server.rateLimitMax;
  }

  get rateLimitWindowMs(): number {
    return this.config.server.rateLimitWindowMs;
  }

  get trustProxy(): boolean {
    return this.config.server.trustProxy;
  }

  get outboundRequestTimeoutMs(): number {
    return this.config.server.outboundRequestTimeoutMs;
  }

  get supabaseUrl(): string | null {
    return this.config.supabase.url;
  }

  get supabaseSecretKey(): string | null {
    return this.config.supabase.secretKey;
  }

  get isSupabaseConfigured(): boolean {
    return this.config.supabase.configured;
  }

  get googlePlacesApiKey(): string | null {
    return this.config.googlePlaces.apiKey;
  }

  get isGooglePlacesConfigured(): boolean {
    return this.config.googlePlaces.configured;
  }

  get geminiApiKey(): string | null {
    return this.config.gemini.apiKey;
  }

  get isGeminiConfigured(): boolean {
    return this.config.gemini.configured;
  }

  get groqApiKey(): string | null {
    return this.config.groq.apiKey;
  }

  get isGroqConfigured(): boolean {
    return this.config.groq.configured;
  }
}
