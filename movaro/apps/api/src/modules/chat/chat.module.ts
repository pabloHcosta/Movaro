import { Module } from '@nestjs/common';

import { CitiesModule } from '../cities/cities.module';
import { ChatContextBuilderService } from './application/services/chat-context-builder.service';
import { ChatController } from './presentation/chat.controller';

@Module({
  imports: [CitiesModule],
  controllers: [ChatController],
  providers: [ChatContextBuilderService],
})
export class ChatModule {}
