import { AppEnvironment } from './environment.enum';

export function getEnvFilePaths(): string[] {
  const nodeEnv =
    (process.env.NODE_ENV as AppEnvironment) ?? AppEnvironment.Development;

  return [`.env.${nodeEnv}.local`, `.env.local`, `.env.${nodeEnv}`, '.env'];
}
