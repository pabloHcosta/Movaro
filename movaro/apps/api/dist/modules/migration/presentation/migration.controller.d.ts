import { MigrationPlanService } from '../application/services/migration-plan.service';
import { CreateMigrationPlanDto } from './dto/create-migration-plan.dto';
export declare class MigrationController {
    private readonly migrationPlanService;
    constructor(migrationPlanService: MigrationPlanService);
    createPlan(body: CreateMigrationPlanDto): import("../domain/entities/migration-plan.entity").MigrationPlanEntity;
}
