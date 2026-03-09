import { Body, Controller, Post } from '@nestjs/common';

import { MigrationPlanService } from '../application/services/migration-plan.service';
import { CreateMigrationPlanDto } from './dto/create-migration-plan.dto';

@Controller({
  path: 'migration',
  version: '1',
})
export class MigrationController {
  constructor(private readonly migrationPlanService: MigrationPlanService) {}

  @Post('plan')
  createPlan(@Body() body: CreateMigrationPlanDto) {
    return this.migrationPlanService.generatePlan(body);
  }
}
