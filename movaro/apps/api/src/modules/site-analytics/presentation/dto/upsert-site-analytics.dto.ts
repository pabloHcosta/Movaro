import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Length,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';

export class SiteSectionEngagementDto {
  @IsString()
  @Length(2, 64)
  sectionKey!: string;

  @IsInt()
  @Min(0)
  @Max(86400)
  activeSeconds!: number;

  @IsInt()
  @Min(0)
  @Max(1000)
  viewCount!: number;

  @IsInt()
  @Min(0)
  @Max(100)
  maxVisibilityPercent!: number;
}

export class UpsertSiteAnalyticsDto {
  @IsUUID()
  sessionId!: string;

  @IsIn(['pt', 'es', 'en'])
  locale!: 'pt' | 'es' | 'en';

  @IsISO8601()
  startedAt!: string;

  @IsISO8601()
  lastSeenAt!: string;

  @IsInt()
  @Min(0)
  @Max(86400)
  activeSeconds!: number;

  @IsInt()
  @Min(0)
  @Max(100)
  maxScrollPercent!: number;

  @IsOptional()
  @IsString()
  @Length(1, 255)
  referrerHost?: string;

  @IsOptional()
  @IsString()
  @Length(1, 120)
  utmSource?: string;

  @IsOptional()
  @IsString()
  @Length(1, 120)
  utmMedium?: string;

  @IsOptional()
  @IsString()
  @Length(1, 120)
  utmCampaign?: string;

  @IsBoolean()
  converted!: boolean;

  @IsOptional()
  @IsISO8601()
  convertedAt?: string;

  @IsArray()
  @ArrayMaxSize(20)
  @ValidateNested({ each: true })
  @Type(() => SiteSectionEngagementDto)
  sections!: SiteSectionEngagementDto[];
}
