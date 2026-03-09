export class MigrationStepEntity {
  constructor(
    public readonly title: string,
    public readonly description: string,
    public readonly category: string,
    public readonly estimatedDays: number,
  ) {}
}
