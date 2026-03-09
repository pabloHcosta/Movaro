import { MigrationStepEntity } from './migration-step.entity';

export class MigrationPlanEntity {
  constructor(
    public readonly originCountry: string,
    public readonly destinationCountry: string,
    public readonly goal: string,
    public readonly timeline: string,
    public readonly steps: MigrationStepEntity[],
  ) {}
}
