import {
  ArrayMaxSize,
  IsArray,
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  Length,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

const allowedEventNames = [
  'questionnaireStarted',
  'questionAnswered',
  'planGenerated',
  'taskSelected',
  'taskStarted',
  'taskWaiting',
  'taskResumed',
  'taskCompleted',
  'fullPlanOpened',
] as const;

class ProductFlowEventDto {
  @IsString()
  @Length(12, 96)
  eventId!: string;

  @IsIn(allowedEventNames)
  eventName!: (typeof allowedEventNames)[number];

  @IsISO8601()
  occurredAt!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  stepIndex?: number;
}

export class IngestProductEventsDto {
  @IsString()
  @Length(24, 96)
  installationToken!: string;

  @IsString()
  @Length(2, 24)
  appEnvironment!: string;

  @IsArray()
  @ArrayMaxSize(40)
  @ValidateNested({ each: true })
  @Type(() => ProductFlowEventDto)
  events!: ProductFlowEventDto[];
}
