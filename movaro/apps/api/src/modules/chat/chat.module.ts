import { Module } from '@nestjs/common';

import { SupabaseAdminService } from '../../common/supabase/supabase-admin.service';
import { AssistantKnowledgeService } from './application/services/assistant-knowledge.service';
import { AssistantLanguageService } from './application/services/assistant-language.service';
import { CitiesModule } from '../cities/cities.module';
import { ReferenceModule } from '../reference/reference.module';
import { ChatContextBuilderService } from './application/services/chat-context-builder.service';
import { ChatPromptsService } from './application/services/chat-prompts.service';
import { GuideAnswersService } from './application/services/guide-answers.service';
import { IntentDetectorService } from './application/services/intent-detector.service';
import { OrchestratorService } from './application/services/orchestrator.service';
import { QuickGuideService } from './application/services/quick-guide.service';
import { QuickHelpQueryPlannerService } from './application/services/quick-help-query-planner.service';
import { CityResolverService } from './application/services/resolvers/city-resolver.service';
import { CorridorGuidanceResolverService } from './application/services/resolvers/corridor-guidance-resolver.service';
import { CostResolverService } from './application/services/resolvers/cost-resolver.service';
import { DocResolverService } from './application/services/resolvers/doc-resolver.service';
import { FaqResolverService } from './application/services/resolvers/faq-resolver.service';
import { ChatController } from './presentation/chat.controller';
import { QuickGuideController } from './presentation/quick-guide.controller';

@Module({
  imports: [CitiesModule, ReferenceModule],
  controllers: [ChatController, QuickGuideController],
  providers: [
    SupabaseAdminService,
    AssistantKnowledgeService,
    AssistantLanguageService,
    ChatPromptsService,
    GuideAnswersService,
    ChatContextBuilderService,
    IntentDetectorService,
    CityResolverService,
    CorridorGuidanceResolverService,
    CostResolverService,
    DocResolverService,
    FaqResolverService,
    OrchestratorService,
    QuickHelpQueryPlannerService,
    QuickGuideService,
  ],
})
export class ChatModule {}
