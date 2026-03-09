import { MigrationStepEntity } from './migration-step.entity';
export declare class MigrationPlanEntity {
    readonly originCountry: string;
    readonly destinationCountry: string;
    readonly goal: string;
    readonly timeline: string;
    readonly steps: MigrationStepEntity[];
    constructor(originCountry: string, destinationCountry: string, goal: string, timeline: string, steps: MigrationStepEntity[]);
}
