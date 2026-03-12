export class CurrentCityWeatherEntity {
  constructor(
    public readonly temperatureCelsius: number,
    public readonly weatherCode: number | null,
    public readonly isDay: boolean | null,
    public readonly windSpeedKmh: number | null,
    public readonly fetchedAt: string,
  ) {}
}
