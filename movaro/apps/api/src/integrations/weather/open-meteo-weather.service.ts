import { Injectable } from '@nestjs/common';

import { AppConfigService } from '../../common/config/app-config.service';
import { AppErrorFactory } from '../../common/errors/app-error.factory';

type OpenMeteoForecastResponse = {
  current?: {
    temperature_2m?: number;
    weather_code?: number;
    is_day?: number;
    wind_speed_10m?: number;
    time?: string;
  };
};

export type CurrentCityWeather = {
  temperatureCelsius: number;
  weatherCode: number | null;
  isDay: boolean | null;
  windSpeedKmh: number | null;
  fetchedAt: string;
};

@Injectable()
export class OpenMeteoWeatherService {
  constructor(private readonly appConfigService: AppConfigService) {}

  private readonly baseUrl = 'https://api.open-meteo.com/v1/forecast';

  async getCurrentWeather(
    latitude: number,
    longitude: number,
  ): Promise<CurrentCityWeather> {
    const controller = new AbortController();
    const timeout = setTimeout(
      () => controller.abort(),
      this.appConfigService.outboundRequestTimeoutMs,
    );

    try {
      const url = new URL(this.baseUrl);
      url.searchParams.set('latitude', latitude.toString());
      url.searchParams.set('longitude', longitude.toString());
      url.searchParams.set(
        'current',
        'temperature_2m,weather_code,is_day,wind_speed_10m',
      );
      url.searchParams.set('timezone', 'auto');
      url.searchParams.set('forecast_days', '1');

      const response = await fetch(url, {
        headers: {
          accept: 'application/json',
        },
        signal: controller.signal,
      });

      if (!response.ok) {
        throw AppErrorFactory.networkError(
          `Open-Meteo request failed with status ${response.status}.`,
        );
      }

      const payload = (await response.json()) as OpenMeteoForecastResponse;
      if (payload.current?.temperature_2m == null) {
        throw AppErrorFactory.networkError(
          'Open-Meteo response does not include current weather.',
        );
      }

      return {
        temperatureCelsius: payload.current.temperature_2m,
        weatherCode: payload.current.weather_code ?? null,
        isDay:
          payload.current.is_day == null ? null : payload.current.is_day === 1,
        windSpeedKmh: payload.current.wind_speed_10m ?? null,
        fetchedAt: payload.current.time ?? new Date().toISOString(),
      };
    } catch (error) {
      if (error instanceof Error && 'getPayload' in error) {
        throw error;
      }

      if (error instanceof Error && error.name === 'AbortError') {
        throw AppErrorFactory.networkError('Open-Meteo request timed out.');
      }

      throw AppErrorFactory.networkError(
        error instanceof Error
          ? error.message
          : 'Unable to reach Open-Meteo data source.',
      );
    } finally {
      clearTimeout(timeout);
    }
  }
}
