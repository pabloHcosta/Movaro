import { Body, Controller, Post } from '@nestjs/common';

import { SiteAnalyticsService } from '../application/site-analytics.service';
import { RecordSiteIntentDto } from './dto/record-site-intent.dto';
import { UpsertSiteAnalyticsDto } from './dto/upsert-site-analytics.dto';

@Controller({ path: 'site-analytics', version: '1' })
export class SiteAnalyticsController {
  constructor(private readonly analytics: SiteAnalyticsService) {}

  @Post('session')
  upsert(@Body() body: UpsertSiteAnalyticsDto) {
    return this.analytics.upsert(body);
  }

  @Post('intent')
  recordIntent(@Body() body: RecordSiteIntentDto) {
    return this.analytics.recordIntent(body);
  }
}
