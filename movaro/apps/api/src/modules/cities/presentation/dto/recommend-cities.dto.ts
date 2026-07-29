import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

const intents = [
  'find_job_br',
  'remote_income',
  'study',
  'family_partner',
  'fresh_start',
  'explore_unsure',
] as const;

const workArrangements = ['remote', 'local_job', 'both_open', ''] as const;

export class RecommendCitiesDto {
  @IsString()
  @IsIn(['BR'])
  destinationCountryCode: 'BR';

  @IsString()
  @IsIn(intents)
  intent: (typeof intents)[number];

  @IsOptional()
  @IsString()
  @MaxLength(40)
  funding?: string;

  @IsOptional()
  @IsString()
  @IsIn(workArrangements)
  workArrangement?: (typeof workArrangements)[number];

  @IsOptional()
  @IsString()
  @MaxLength(40)
  travelGroup?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @Max(12)
  childrenCount?: number;

  @IsOptional()
  @IsString()
  @MaxLength(40)
  availableCapital?: string;

  @IsArray()
  @ArrayMaxSize(3)
  @IsString({ each: true })
  priorities: string[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(4)
  @IsString({ each: true })
  constraints?: string[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(5)
  @IsString({ each: true })
  supportNeeds?: string[];

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  originLatitude?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  originLongitude?: number;
}
