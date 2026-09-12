export class MudaviScoresEntity {
  constructor(
    public readonly economical: number,
    public readonly popularForArgentinians: number,
    public readonly languageAdaptation: number,
    public readonly workOpportunity: number,
    public readonly overall: number,
  ) {}
}
