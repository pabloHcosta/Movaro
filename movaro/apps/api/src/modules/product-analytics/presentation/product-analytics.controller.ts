import { Body, Controller, Post } from '@nestjs/common';

import { ProductAnalyticsService } from '../application/product-analytics.service';
import { IngestProductEventsDto } from './dto/ingest-product-events.dto';

@Controller({
  path: 'product-analytics',
  version: '1',
})
export class ProductAnalyticsController {
  constructor(private readonly analytics: ProductAnalyticsService) {}

  @Post('events')
  ingest(@Body() body: IngestProductEventsDto) {
    return this.analytics.ingest(body);
  }
}
