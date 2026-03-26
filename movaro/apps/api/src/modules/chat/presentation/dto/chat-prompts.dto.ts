import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export class ChatPromptsDto {
  @IsString()
  @MaxLength(100)
  originCountry!: string;

  @IsString()
  @MaxLength(100)
  destinationCountry!: string;

  @IsOptional()
  @IsString()
  @IsIn(['pt', 'es', 'en'])
  locale?: string;
}
