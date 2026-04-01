import { Injectable } from '@nestjs/common';

import { CityBudgetSnapshotEntity } from '../../domain/entities/city-budget-snapshot.entity';

@Injectable()
export class CityBudgetSnapshotService {
  findByCityId(_cityId: string): CityBudgetSnapshotEntity | null {
    return null;
  }
}
