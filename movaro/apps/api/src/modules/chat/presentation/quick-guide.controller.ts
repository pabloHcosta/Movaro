import { Body, Controller, Post } from '@nestjs/common';

import { QuickGuideService } from '../application/services/quick-guide.service';
import { ResolveQuickGuideDto } from './dto/resolve-quick-guide.dto';

@Controller({ path: 'guide', version: '1' })
export class QuickGuideController {
  constructor(private readonly quickGuideService: QuickGuideService) {}

  @Post('resolve')
  resolve(@Body() body: ResolveQuickGuideDto) {
    return this.quickGuideService.resolve(body);
  }
}
