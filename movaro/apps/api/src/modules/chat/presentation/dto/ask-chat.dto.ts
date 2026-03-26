import { Type } from 'class-transformer';
import {
  IsArray,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';

export class ChatHistoryItemDto {
  @IsString()
  @IsIn(['user', 'assistant'])
  role: 'user' | 'assistant';

  @IsString()
  @MaxLength(4000)
  text: string;
}

export class AskChatDto {
  @IsString()
  @MaxLength(2000)
  message: string;

  @IsString()
  @MaxLength(100)
  originCountry: string;

  @IsString()
  @MaxLength(100)
  destinationCountry: string;

  @IsOptional()
  @IsString()
  @IsIn(['pt', 'es', 'en'])
  locale?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  recommendedCityId?: string;

  @IsOptional()
  @IsString()
  currentPhase?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  migrationGoal?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  planTimeline?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  completedItemIds?: string[];

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ChatHistoryItemDto)
  history?: ChatHistoryItemDto[];
}
