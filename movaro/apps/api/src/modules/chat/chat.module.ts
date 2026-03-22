import { Module } from '@nestjs/common';

import { CitiesModule } from '../cities/cities.module';
import { ReferenceModule } from '../reference/reference.module';
import { ChatContextBuilderService } from './application/services/chat-context-builder.service';
import { GeminiFallbackService } from './application/services/gemini-fallback.service';
import { IntentDetectorService } from './application/services/intent-detector.service';
import { OrchestratorService } from './application/services/orchestrator.service';
import { CityResolverService } from './application/services/resolvers/city-resolver.service';
import { CostResolverService } from './application/services/resolvers/cost-resolver.service';
import { DocResolverService } from './application/services/resolvers/doc-resolver.service';
import { ChatController } from './presentation/chat.controller';

@Module({
  imports: [CitiesModule, ReferenceModule],
  controllers: [ChatController],
  providers: [
    ChatContextBuilderService,
    IntentDetectorService,
    CityResolverService,
    CostResolverService,
    DocResolverService,
    GeminiFallbackService,
    OrchestratorService,
  ],
})
export class ChatModule {}
