import { Body, Controller, Post } from '@nestjs/common';

import { LaunchInterestsService } from '../application/launch-interests.service';
import { RegisterLaunchInterestDto } from './dto/register-launch-interest.dto';

@Controller({ path: 'launch-interests', version: '1' })
export class LaunchInterestsController {
  constructor(private readonly launchInterests: LaunchInterestsService) {}

  @Post()
  register(@Body() body: RegisterLaunchInterestDto) {
    return this.launchInterests.register(body);
  }
}
