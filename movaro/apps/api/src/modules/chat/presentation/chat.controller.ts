import { Body, Controller, Post } from '@nestjs/common';

import { ChatContextBuilderService } from '../application/services/chat-context-builder.service';
import { OrchestratorService } from '../application/services/orchestrator.service';
import { ChatPromptsService } from '../application/services/chat-prompts.service';
import { GuideAnswersService } from '../application/services/guide-answers.service';
import { AskChatDto } from './dto/ask-chat.dto';
import { BuildChatContextDto } from './dto/build-chat-context.dto';
import { ChatPromptsDto } from './dto/chat-prompts.dto';
import { GuideAnswersDto } from './dto/guide-answers.dto';

@Controller({
  path: 'chat',
  version: '1',
})
export class ChatController {
  constructor(
    private readonly chatContextBuilderService: ChatContextBuilderService,
    private readonly orchestratorService: OrchestratorService,
    private readonly chatPromptsService: ChatPromptsService,
    private readonly guideAnswersService: GuideAnswersService,
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

  /**
   * Ask the AI assistant a question.
   *
   * The orchestrator detects intent, runs the appropriate resolver (city,
   * cost, documents, plan), and falls back to Gemini when confidence is low.
   *
   * POST /v1/chat/ask
   */
  @Post('ask')
  ask(@Body() body: AskChatDto) {
    return this.orchestratorService.ask(body);
  }

  @Post('prompts')
  prompts(@Body() body: ChatPromptsDto) {
    return this.chatPromptsService.buildPrompts(body);
  }

  @Post('guide-answers')
  guideAnswers(@Body() body: GuideAnswersDto) {
    return this.guideAnswersService.list(body);
  }
}
