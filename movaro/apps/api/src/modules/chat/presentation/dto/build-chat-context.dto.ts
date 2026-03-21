import {
  IsArray,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class BuildChatContextDto {
  @IsString()
  @MaxLength(100)
  originCountry!: string;

  @IsString()
  @MaxLength(100)
  destinationCountry!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  migrationGoal?: string;

  /** ID used by the cities catalog (e.g. "sao-paulo"). */
  @IsOptional()
  @IsString()
  @MaxLength(100)
  recommendedCityId?: string;

  /**
   * Current copilot phase.
   * One of: preparation | documents | housing | work | arrival
   */
  @IsOptional()
  @IsString()
  @IsIn(['preparation', 'documents', 'housing', 'work', 'arrival'])
  currentPhase?: string;

  /** IDs of guide items the user has already completed. */
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  completedItemIds?: string[];

  @IsOptional()
  @IsString()
  @MaxLength(50)
  planTimeline?: string;

  @IsOptional()
  @IsString()
  @IsIn(['pt', 'es', 'en'])
  locale?: string;
}
