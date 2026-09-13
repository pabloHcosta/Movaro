import { Module } from '@nestjs/common';

import { SupabaseAdminService } from '../../common/supabase/supabase-admin.service';
import { LaunchInterestsService } from './application/launch-interests.service';
import { LaunchInterestsController } from './presentation/launch-interests.controller';

@Module({
  controllers: [LaunchInterestsController],
  providers: [LaunchInterestsService, SupabaseAdminService],
})
export class LaunchInterestsModule {}
