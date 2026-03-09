import { CreateMigrationPlanModel } from '../../data/models/create-migration-plan.model';
import { MigrationPlanEntity } from '../../domain/entities/migration-plan.entity';
import { SeedCatalogRepository } from '../../domain/repositories/seed-catalog.repository';
export declare class MigrationPlanService {
    private readonly seedCatalogRepository;
    constructor(seedCatalogRepository: SeedCatalogRepository);
    generatePlan(input: CreateMigrationPlanModel): MigrationPlanEntity;
    private validateInput;
}
