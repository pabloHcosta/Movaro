import { IsIn, IsInt, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class GetCityInsightExploreQueryDto {
  @IsString()
  @MaxLength(120)
  cityId!: string;

  @IsOptional()
  @IsString()
  @IsIn([
    'neighborhoods',
    'beaches',
    'parks',
    'nightlife',
    'food_and_cafes',
    'culture_and_events',
    'viewpoints',
    'local_routine',
  ])
  theme?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  locale?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  seedPlace?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(8)
  limit?: number;
}
