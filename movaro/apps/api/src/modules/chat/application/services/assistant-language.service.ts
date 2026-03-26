import { Injectable } from '@nestjs/common';

import { AssistantKnowledgeService } from './assistant-knowledge.service';

@Injectable()
export class AssistantLanguageService {
  constructor(
    private readonly assistantKnowledgeService: AssistantKnowledgeService,
  ) {}

  detectResponseLocale(message: string, requestedLocale?: string) {
    return this.assistantKnowledgeService.detectLanguage(message, requestedLocale);
  }
}
