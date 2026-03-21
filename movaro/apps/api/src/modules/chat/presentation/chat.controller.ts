import { Body, Controller, Post } from '@nestjs/common';

import { ChatContextBuilderService } from '../application/services/chat-context-builder.service';
import { BuildChatContextDto } from './dto/build-chat-context.dto';

@Controller({
  path: 'chat',
  version: '1',
})
export class ChatController {
  constructor(
    private readonly chatContextBuilderService: ChatContextBuilderService,
  ) {}

  /**
   * Build and return the AI context block for the requesting user.
   *
   * The Flutter app calls this endpoint before opening the chat, injects the
   * returned `appDataBlock` into the Gemini system prompt, and uses
   * `coverageLevel` to decide whether to allow the chat at all.
   *
   * POST /v1/chat/context
   */
  @Post('context')
  buildContext(@Body() body: BuildChatContextDto) {
    return this.chatContextBuilderService.buildContext(body);
  }
}
