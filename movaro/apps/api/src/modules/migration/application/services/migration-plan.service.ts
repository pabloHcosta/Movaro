import { Injectable } from '@nestjs/common';

import { AppErrorFactory } from '../../../../common/errors/app-error.factory';
import { CreateMigrationPlanModel } from '../../data/models/create-migration-plan.model';
import { MigrationPlanEntity } from '../../domain/entities/migration-plan.entity';
import { MigrationStepEntity } from '../../domain/entities/migration-step.entity';
import { SeedCatalogRepository } from '../../domain/repositories/seed-catalog.repository';

@Injectable()
export class MigrationPlanService {
  constructor(private readonly seedCatalogRepository: SeedCatalogRepository) {}

  generatePlan(input: CreateMigrationPlanModel): MigrationPlanEntity {
    this.validateInput(input);

    if (input.destinationCountry === 'Brasil') {
      return new MigrationPlanEntity(
        input.originCountry,
        input.destinationCountry,
        input.goal,
        input.timeline,
        [
          new MigrationStepEntity(
            'Verificar tipo de residencia ou visto',
            'Mapear a base migratoria adequada para a motivacao principal da mudanca.',
            'documentation',
            7,
          ),
          new MigrationStepEntity(
            'Obter CPF',
            'Organizar o registro fiscal necessario para servicos e transacoes no Brasil.',
            'documentation',
            3,
          ),
          new MigrationStepEntity(
            'Abrir conta bancaria',
            'Preparar uma conta local para movimentacao financeira inicial.',
            'financial',
            5,
          ),
          new MigrationStepEntity(
            'Buscar moradia',
            'Pesquisar bairros, contratos e custos para uma instalacao segura.',
            'housing',
            14,
          ),
          new MigrationStepEntity(
            'Regularizar documentacao local',
            'Conferir registros adicionais, comprovantes e etapas administrativas locais.',
            'settlement',
            10,
          ),
        ],
      );
    }

    return new MigrationPlanEntity(
      input.originCountry,
      input.destinationCountry,
      input.goal,
      input.timeline,
      [
        new MigrationStepEntity(
          'Mapear destinos possiveis',
          'Comparar opcoes de pais com base no objetivo e janela de mudanca.',
          'research',
          7,
        ),
        new MigrationStepEntity(
          'Definir criterio de decisao',
          'Organizar prioridades como custo, documentacao e qualidade de vida.',
          'planning',
          5,
        ),
      ],
    );
  }

  private validateInput(input: CreateMigrationPlanModel): void {
    if (
      input.originCountry.trim().length == 0 ||
      input.destinationCountry.trim().length == 0 ||
      input.goal.trim().length == 0 ||
      input.timeline.trim().length == 0
    ) {
      throw AppErrorFactory.validationError(
        'originCountry, destinationCountry, goal and timeline are required.',
        'Preencha origem, destino, objetivo e momento da mudanca.',
      );
    }

    const supportedCountries = this.seedCatalogRepository.getCountryNames();

    if (!supportedCountries.includes(input.originCountry)) {
      throw AppErrorFactory.validationError(
        'Unsupported originCountry.',
        'O pais de origem ainda nao esta disponivel neste MVP.',
      );
    }

    if (
      input.destinationCountry != 'Ainda nao sei' &&
      !supportedCountries.includes(input.destinationCountry)
    ) {
      throw AppErrorFactory.validationError(
        'Unsupported destinationCountry.',
        'O pais de destino ainda nao esta disponivel neste MVP.',
      );
    }
  }
}
