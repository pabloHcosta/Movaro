import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export class GuideAnswersDto {
  @IsString()
  @MaxLength(100)
  destinationCountry!: string;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  originCountry?: string;

  @IsOptional()
  @IsString()
  @IsIn(['pt', 'es', 'en'])
  locale?: string;
}
