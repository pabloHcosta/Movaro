import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { Injectable } from '@nestjs/common';

import { SeedCatalogRepository } from '../../domain/repositories/seed-catalog.repository';

type CountrySeedRecord = {
  id: string;
  name: string;
};

@Injectable()
export class ContractsSeedRepository implements SeedCatalogRepository {
  getCountryNames(): string[] {
    const filePath = resolve(
      process.cwd(),
      '../../packages/contracts/seed/countries.json',
    );
    const fileContent = readFileSync(filePath, 'utf-8');
    const countries = JSON.parse(fileContent) as CountrySeedRecord[];

    return countries.map((country) => country.name);
  }
}
