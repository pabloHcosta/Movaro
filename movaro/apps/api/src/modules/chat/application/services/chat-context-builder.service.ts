import { Injectable, Logger } from '@nestjs/common';

import { CitiesCatalogService } from '../../../cities/application/services/cities-catalog.service';
import { CityCardEntity } from '../../../cities/domain/entities/city-card.entity';
import { ChatContextEntity, CoverageLevel } from '../../domain/entities/chat-context.entity';
import { BuildChatContextDto } from '../../presentation/dto/build-chat-context.dto';
import {
  corridorGuidanceProfiles,
  CorridorGuidanceProfile,
} from './resolvers/corridor-guidance-profiles';

@Injectable()
export class ChatContextBuilderService {
  private readonly logger = new Logger(ChatContextBuilderService.name);

  constructor(
    private readonly citiesCatalogService: CitiesCatalogService,
  ) {}

  async buildContext(dto: BuildChatContextDto): Promise<ChatContextEntity> {
    const origin = dto.originCountry.toLowerCase().trim();
    const destination = dto.destinationCountry.toLowerCase().trim();
    const profile = this.resolveProfile(origin, destination);

    const coverageLevel = this.resolveCoverageLevel(profile);
    const corridor = `${this.capitalise(origin)} → ${this.capitalise(destination)}`;

    if (!profile || coverageLevel === 'unsupported') {
      return new ChatContextEntity('', 'unsupported', corridor);
    }

    const sections: string[] = [];

    // ── City data ────────────────────────────────────────────────────────────
    if (dto.recommendedCityId) {
      const citySection = await this.buildCitySection(dto.recommendedCityId, dto.locale);
      if (citySection) sections.push(citySection);
    }

    // ── Current phase guide items ─────────────────────────────────────────
    if (dto.currentPhase) {
      const normalizedCompletedItemIds = this.normalizeCompletedItemIds(
        dto.completedItemIds ?? [],
        profile,
      );
      sections.push(
        this.buildPhaseSection(
          profile,
          dto.currentPhase,
          normalizedCompletedItemIds,
          dto.locale,
        ),
      );
    }

    // ── Upcoming phase preview ────────────────────────────────────────────
    const upcomingPhase = this.resolveUpcomingPhase(profile, dto.currentPhase);
    if (upcomingPhase) {
      sections.push(this.buildUpcomingPhaseSection(profile, upcomingPhase, dto.locale));
    }

    const appDataBlock = sections.join('\n\n');
    return new ChatContextEntity(appDataBlock, coverageLevel, corridor);
  }

  // ── City section ──────────────────────────────────────────────────────────

  private async buildCitySection(
    cityId: string,
    locale?: string,
  ): Promise<string | null> {
    try {
      const resolvedCityId = this.citiesCatalogService.resolveCityId(cityId);
      if (!resolvedCityId) {
        this.logger.warn(`City not found for context: ${cityId}`);
        return null;
      }

      const city = await this.citiesCatalogService.getCityById(resolvedCityId);
      return this.formatCitySection(city, locale);
    } catch {
      this.logger.warn(`City not found for context: ${cityId}`);
      return null;
    }
  }

  private formatCitySection(city: CityCardEntity, locale?: string): string {
    const lang = locale ?? 'pt';
    const header = lang === 'pt'
      ? `### Dados da cidade recomendada: ${city.name} (${city.stateName})`
      : lang === 'es'
        ? `### Datos de la ciudad recomendada: ${city.name} (${city.stateName})`
        : `### Recommended city data: ${city.name} (${city.stateName})`;

    const lines: string[] = [header];

    // Cost of living & rent
    lines.push(this.costLabel(lang, city.costOfLivingScore, city.rentScore));

    // Job market
    lines.push(this.jobLabel(lang, city.jobMarketScore, city.unemploymentRate));

    // IDHM (human development index)
    lines.push(this.idhmLabel(lang, city.idhmScore));

    // Top industries
    if (city.topIndustries.length > 0) {
      lines.push(this.industriesLabel(lang, city.topIndustries));
    }

    // Movaro scores summary
    lines.push(this.scoresLabel(lang, city));

    // Recommendation reasons
    if (city.recommendationReasons.length > 0) {
      lines.push(this.reasonsLabel(lang, city.recommendationReasons));
    }

    // Note about data currency
    lines.push(this.dataNote(lang, city.updatedAt));

    return lines.join('\n');
  }

  private costLabel(lang: string, costScore: number, rentScore: number): string {
    const avg = ((costScore + rentScore) / 2).toFixed(0);
    return lang === 'pt'
      ? `- Custo de vida (score 0-100, maior = mais barato): ${avg}/100 | Custo: ${costScore}/100 | Aluguel: ${rentScore}/100`
      : lang === 'es'
        ? `- Costo de vida (score 0-100, mayor = más barato): ${avg}/100 | Costo: ${costScore}/100 | Alquiler: ${rentScore}/100`
        : `- Cost of living (0-100, higher = cheaper): ${avg}/100 | Cost: ${costScore}/100 | Rent: ${rentScore}/100`;
  }

  private jobLabel(lang: string, jobScore: number, unemployment: number): string {
    return lang === 'pt'
      ? `- Mercado de trabalho: ${jobScore}/100 | Taxa de desemprego: ${unemployment}%`
      : lang === 'es'
        ? `- Mercado laboral: ${jobScore}/100 | Tasa de desempleo: ${unemployment}%`
        : `- Job market: ${jobScore}/100 | Unemployment rate: ${unemployment}%`;
  }

  private idhmLabel(lang: string, idhm: number): string {
    return lang === 'pt'
      ? `- IDHM (Índice de Desenvolvimento Humano): ${idhm}`
      : lang === 'es'
        ? `- IDHM (Índice de Desarrollo Humano): ${idhm}`
        : `- HDI (Human Development Index): ${idhm}`;
  }

  private industriesLabel(lang: string, industries: string[]): string {
    const list = industries.join(', ');
    return lang === 'pt'
      ? `- Principais setores econômicos: ${list}`
      : lang === 'es'
        ? `- Principales sectores económicos: ${list}`
        : `- Top industries: ${list}`;
  }

  private scoresLabel(lang: string, city: CityCardEntity): string {
    const s = city.movaroScores;
    return lang === 'pt'
      ? `- Scores Movaro — Geral: ${s.overall} | Econômico: ${s.economical} | Trabalho: ${s.workOpportunity} | Popular entre argentinos: ${s.popularForArgentinians} | Adaptação ao espanhol: ${s.languageAdaptation}`
      : lang === 'es'
        ? `- Scores Movaro — General: ${s.overall} | Económico: ${s.economical} | Trabajo: ${s.workOpportunity} | Popular entre argentinos: ${s.popularForArgentinians} | Adaptación al español: ${s.languageAdaptation}`
        : `- Movaro Scores — Overall: ${s.overall} | Economical: ${s.economical} | Work: ${s.workOpportunity} | Popular for Argentinians: ${s.popularForArgentinians} | Spanish adaptation: ${s.languageAdaptation}`;
  }

  private reasonsLabel(lang: string, reasons: string[]): string {
    const list = reasons.map((r) => `  • ${r}`).join('\n');
    return lang === 'pt'
      ? `- Motivos da recomendação:\n${list}`
      : lang === 'es'
        ? `- Razones de la recomendación:\n${list}`
        : `- Recommendation reasons:\n${list}`;
  }

  private dataNote(lang: string, updatedAt: string): string {
    return lang === 'pt'
      ? `- Dados atualizados em: ${updatedAt}. Valores são estimativas — confirmar fontes locais.`
      : lang === 'es'
        ? `- Datos actualizados en: ${updatedAt}. Los valores son estimaciones — confirmar con fuentes locales.`
        : `- Data last updated: ${updatedAt}. Values are estimates — verify with local sources.`;
  }

  // ── Phase section ─────────────────────────────────────────────────────────

  private buildPhaseSection(
    profile: CorridorGuidanceProfile,
    phase: string,
    completedItemIds: string[],
    locale?: string,
  ): string {
    const lang = locale ?? 'pt';
    const items = profile.guideItems.filter((item) => item.phase === phase);
    const completedSet = new Set(completedItemIds);

    const pending = items.filter((i) => !completedSet.has(i.id));
    const done = items.filter((i) => completedSet.has(i.id));

    const phaseLabel = this.phaseDisplayName(phase, lang);
    const header = lang === 'pt'
      ? `### Fase atual do guia: ${phaseLabel}`
      : lang === 'es'
        ? `### Fase actual de la guía: ${phaseLabel}`
        : `### Current guide phase: ${phaseLabel}`;

    const lines: string[] = [header];

    if (pending.length > 0) {
      const pendingHeader = lang === 'pt' ? '**Itens pendentes:**'
        : lang === 'es' ? '**Elementos pendientes:**'
        : '**Pending items:**';
      lines.push(pendingHeader);
      pending.forEach((item) => lines.push(this.formatItem(item, false)));
    }

    if (done.length > 0) {
      const doneHeader = lang === 'pt' ? '**Itens concluídos:**'
        : lang === 'es' ? '**Elementos completados:**'
        : '**Completed items:**';
      lines.push(doneHeader);
      done.forEach((item) => lines.push(this.formatItem(item, true)));
    }

    const progress = `${done.length}/${items.length}`;
    const progressLine = lang === 'pt'
      ? `Progresso nesta fase: ${progress}`
      : lang === 'es'
        ? `Progreso en esta fase: ${progress}`
        : `Phase progress: ${progress}`;
    lines.push(progressLine);

    return lines.join('\n');
  }

  private formatItem(
    item: CorridorGuidanceProfile['guideItems'][number],
    completed: boolean,
  ): string {
    const status = completed ? '✓' : '○';
    const base = `${status} [${item.id}] ${item.title}: ${item.summary}`;
    return item.notes && !completed ? `${base}\n  → ${item.notes}` : base;
  }

  // ── Upcoming phase preview ────────────────────────────────────────────────

  private buildUpcomingPhaseSection(
    profile: CorridorGuidanceProfile,
    phase: string,
    locale?: string,
  ): string {
    const lang = locale ?? 'pt';
    const items = profile.guideItems.filter((item) => item.phase === phase);
    if (items.length === 0) return '';

    const phaseLabel = this.phaseDisplayName(phase, lang);
    const header = lang === 'pt'
      ? `### Próxima fase: ${phaseLabel} (prévia)`
      : lang === 'es'
        ? `### Próxima fase: ${phaseLabel} (vista previa)`
        : `### Upcoming phase: ${phaseLabel} (preview)`;

    const lines: string[] = [header];
    items.forEach((item) => {
      lines.push(`○ ${item.title}`);
    });

    return lines.join('\n');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  private resolveCoverageLevel(
    profile: CorridorGuidanceProfile | null,
  ): CoverageLevel {
    return profile ? 'full' : 'unsupported';
  }

  private resolveUpcomingPhase(
    profile: CorridorGuidanceProfile,
    currentPhase?: string,
  ): string | null {
    if (!currentPhase) return null;
    const index = profile.phaseOrder.indexOf(currentPhase);
    if (index === -1 || index >= profile.phaseOrder.length - 1) return null;
    return profile.phaseOrder[index + 1] ?? null;
  }

  private resolveProfile(
    origin: string,
    destination: string,
  ): CorridorGuidanceProfile | null {
    return (
      corridorGuidanceProfiles.find(
        (profile) =>
          profile.key === `${origin.toLowerCase().trim()}->${destination
            .toLowerCase()
            .trim()}`,
      ) ?? null
    );
  }

  private normalizeCompletedItemIds(
    completedItemIds: string[],
    profile: CorridorGuidanceProfile,
  ): string[] {
    if (!profile.completedItemAliases) {
      return completedItemIds;
    }

    return completedItemIds.map(
      (itemId) => profile.completedItemAliases?.[itemId] ?? itemId,
    );
  }

  private phaseDisplayName(phase: string, lang: string): string {
    const names: Record<string, Record<string, string>> = {
      preparation: { pt: 'Preparação', es: 'Preparación', en: 'Preparation' },
      documents:   { pt: 'Documentos', es: 'Documentos',  en: 'Documents' },
      housing:     { pt: 'Moradia',    es: 'Vivienda',    en: 'Housing' },
      work:        { pt: 'Trabalho',   es: 'Trabajo',     en: 'Work' },
      arrival:     { pt: 'Chegada',    es: 'Llegada',     en: 'Arrival' },
    };
    return names[phase]?.[lang] ?? names[phase]?.['en'] ?? phase;
  }

  private capitalise(s: string): string {
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  /** Returns all guide items for a full-catalog response (e.g. for testing). */
  getAllGuideItems() {
    return corridorGuidanceProfiles.flatMap((profile) => profile.guideItems);
  }
}
