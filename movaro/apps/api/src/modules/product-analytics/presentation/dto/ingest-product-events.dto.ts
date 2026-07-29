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
  'recommendationViewed',
  'primaryCityExplored',
  'alternativeCityExplored',
  'comparisonOpened',
  'recommendationAccepted',
  'recommendationFeedbackPositive',
  'recommendationFeedbackNegative',
  'taskSelected',
  'taskSheetOpened',
  'taskSheetClosedIncomplete',
  'taskBlocked',
  'taskStarted',
  'taskWaiting',
  'taskResumed',
  'taskDismissed',
  'taskCompleted',
  'officialLinkOpened',
  'officialLinkReturned',
  'officialLinkFailed',
  'detailsExpanded',
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

  @IsOptional()
  @IsString()
  @Length(3, 64)
  methodologyVersion?: string;

  @IsOptional()
  @IsIn(['robust', 'moderate', 'sensitive', 'insufficient_data'])
  stabilityBand?: string;

  @IsOptional()
  @IsIn(['broad', 'partial', 'limited'])
  coverageBand?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(3)
  rankPosition?: number;
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
