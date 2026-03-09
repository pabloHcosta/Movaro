import { Module } from '@nestjs/common';

import { MigrationPlanService } from './application/services/migration-plan.service';
import { ContractsSeedRepository } from './data/repositories/contracts-seed.repository';
import { SeedCatalogRepository } from './domain/repositories/seed-catalog.repository';
import { MigrationController } from './presentation/migration.controller';

@Module({
  controllers: [MigrationController],
  providers: [
    MigrationPlanService,
    ContractsSeedRepository,
    {
      provide: SeedCatalogRepository,
      useExisting: ContractsSeedRepository,
    },
  ],
})
export class MigrationModule {}
