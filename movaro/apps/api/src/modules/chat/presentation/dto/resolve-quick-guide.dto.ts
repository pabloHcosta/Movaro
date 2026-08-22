import { Type } from 'class-transformer';
import {
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from 'class-validator';

import { AskChatDto } from './ask-chat.dto';

export class QuickGuideAnswersDto {
  @IsOptional()
  @IsString()
  @MaxLength(80)
  documentGoal?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  residenceBasis?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  educationLevel?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  drivingGoal?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  migrationProcessStage?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  bankRefusalReason?: string;
}

export class ResolveQuickGuideDto extends AskChatDto {
  @IsOptional()
  @ValidateNested()
  @Type(() => QuickGuideAnswersDto)
  answers?: QuickGuideAnswersDto;
}
