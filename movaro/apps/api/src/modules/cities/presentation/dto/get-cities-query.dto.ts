import { Transform } from 'class-transformer';
import {
  IsIn,
  IsISO31661Alpha2,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export const cityCategories = [
  'economical',
  'popular_argentina',
  'language',
  'work',
] as const;

export type CityCategory = (typeof cityCategories)[number];

export class GetCitiesQueryDto {
  @IsOptional()
  @IsIn(cityCategories)
  category?: CityCategory;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().replace(/\s+/g, ' ') : value,
  )
  search?: string;

  @IsOptional()
  @IsISO31661Alpha2()
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toUpperCase() : value,
  )
  countryCode?: string;
}
