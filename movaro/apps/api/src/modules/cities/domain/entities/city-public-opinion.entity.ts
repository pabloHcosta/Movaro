export class CityPublicOpinionEntity {
  constructor(
    public readonly provider: string,
    public readonly placeName: string | null,
    public readonly placeUrl: string | null,
    public readonly rating: number | null,
    public readonly userRatingCount: number | null,
    public readonly summary: string | null,
    public readonly positivePoints: string[],
    public readonly criticalPoints: string[],
    public readonly collectedAt: string,
  ) {}
}
