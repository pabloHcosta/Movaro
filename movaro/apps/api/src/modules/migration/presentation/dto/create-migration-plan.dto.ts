import { IsIn, IsString, MaxLength } from 'class-validator';

export class CreateMigrationPlanDto {
  @IsString()
  @MaxLength(100)
  @IsIn(['Argentina'])
  originCountry!: string;

  @IsString()
  @MaxLength(100)
  @IsIn(['Brasil', 'Ainda nao sei'])
  destinationCountry!: string;

  @IsString()
  @MaxLength(100)
  @IsIn([
    'Trabalhar',
    'Trabalhar remoto',
    'Estudar',
    'Empreender',
    'Aposentar',
    'Qualidade de vida',
  ])
  goal!: string;

  @IsString()
  @MaxLength(100)
  @IsIn([
    'So estou pesquisando',
    'Nos proximos 12 meses',
    'Nos proximos 6 meses',
    'O mais rapido possivel',
  ])
  timeline!: string;
}
