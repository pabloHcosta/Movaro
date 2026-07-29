import 'package:movaro_app/features/home/domain/city_feed_item.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';

/// Static curated feed content for the City Feed.
///
/// V1 is fully curated (no external API). Content is localized using the
/// passed [locale] language code. Each item carries city and stage filters.
class CityFeedDatasource {
  const CityFeedDatasource._();

  static List<CityFeedItem> build({
    required String? cityCode,
    required UserJourneyStage stage,
    required String locale,
    City? city,
    CityWeather? weather,
    CityDetailSocialProof? socialProof,
    CityDetailClimateSummary? climateSummary,
    CityDetailArrivalStory? arrivalStory,
    CityDetailComparison? comparison,
    GuideActionItem? guideCurrentItem,
  }) {
    final dynamicItems = _dynamicItems(
      locale,
      stage: stage,
      city: city,
      weather: weather,
      socialProof: socialProof,
      climateSummary: climateSummary,
      arrivalStory: arrivalStory,
      comparison: comparison,
      guideCurrentItem: guideCurrentItem,
    );
    final seenIds = dynamicItems.map((item) => item.id).toSet();
    final hasRealCost = city?.budgetSnapshot != null;
    final hasRealClimate = climateSummary != null || weather != null;
    final hasRealSocial =
        socialProof != null &&
        (_isTraceableSource(
              socialProof.publicOpinion?.provider,
              socialProof.publicOpinion?.placeUrl,
            ) ||
            socialProof.sources.any(
              (source) => _isTraceableSource(source.label, source.url),
            ));
    final fallbackItems = _officialFallbacks(locale)
        .where((item) => item.isRelevantFor(cityCode: cityCode, stage: stage))
        .where((item) => !seenIds.contains(item.id))
        .where(
          (item) =>
              !(hasRealCost && item.type == CityFeedItemType.costUpdate) &&
              !(hasRealSocial && item.type == CityFeedItemType.migrantStory) &&
              !(hasRealClimate &&
                  item.id.startsWith('lifestyle_') &&
                  (item.cityCodes.isNotEmpty || cityCode != null)),
        )
        .toList();

    return [...dynamicItems, ...fallbackItems];
  }

  static List<CityFeedItem> _officialFallbacks(String locale) => [
    CityFeedItem(
      id: 'official_cpf_registration',
      type: CityFeedItemType.practicalTip,
      badge: _officialSourceLabel(locale),
      title: _t(
        locale,
        pt: 'CPF para brasileiros e estrangeiros',
        es: 'CPF para brasileños y extranjeros',
        en: 'CPF for Brazilian and foreign citizens',
      ),
      body: _t(
        locale,
        pt: 'A Receita Federal informa quem pode solicitar, quais documentos apresentar e quais canais estão disponíveis. Confira a página vigente antes de iniciar.',
        es: 'La Receita Federal informa quién puede solicitarlo, qué documentos presentar y qué canales están disponibles. Revisá la página vigente antes de empezar.',
        en: 'Brazilian Federal Revenue explains eligibility, documents and available channels. Check the current page before starting.',
      ),
      stages: const [UserJourneyStage.explorer, UserJourneyStage.planner],
      sourceLabel: 'Receita Federal · Gov.br',
      sourceUrl: 'https://www.gov.br/pt-br/servicos/inscrever-no-cpf',
      updatedAt: '2026-07-26',
    ),
    CityFeedItem(
      id: 'official_residence_pf',
      type: CityFeedItemType.practicalTip,
      badge: _officialSourceLabel(locale),
      title: _t(
        locale,
        pt: 'Residência: consulte sua modalidade',
        es: 'Residencia: consultá tu modalidad',
        en: 'Residence: check your route',
      ),
      body: _t(
        locale,
        pt: 'A Polícia Federal reúne modalidades, formulários e etapas. Requisitos variam conforme o fundamento do pedido; valide sua situação no portal oficial.',
        es: 'La Policía Federal reúne modalidades, formularios y etapas. Los requisitos cambian según el fundamento; validá tu situación en el portal oficial.',
        en: 'Federal Police lists residence routes, forms and steps. Requirements vary by legal basis, so validate your case on the official portal.',
      ),
      stages: const [UserJourneyStage.planner, UserJourneyStage.executor],
      sourceLabel: 'Polícia Federal · Gov.br',
      sourceUrl:
          'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia',
      updatedAt: '2026-07-26',
    ),
    CityFeedItem(
      id: 'official_mei_formalization',
      type: CityFeedItemType.opportunity,
      badge: _officialSourceLabel(locale),
      title: _t(
        locale,
        pt: 'MEI: confirme se a atividade se enquadra',
        es: 'MEI: confirmá si tu actividad aplica',
        en: 'MEI: check whether your activity qualifies',
      ),
      body: _t(
        locale,
        pt: 'A formalização é feita no Portal do Empreendedor. Antes de avançar, confira ocupações permitidas, requisitos e obrigações atualizadas.',
        es: 'La formalización se hace en el Portal del Emprendedor. Antes de avanzar, revisá actividades permitidas, requisitos y obligaciones vigentes.',
        en: 'Formalization is handled through the official Entrepreneur Portal. Check eligible activities, requirements and current obligations first.',
      ),
      stages: const [UserJourneyStage.planner, UserJourneyStage.executor],
      sourceLabel: 'Portal do Empreendedor · Gov.br',
      sourceUrl:
          'https://www.gov.br/empresas-e-negocios/pt-br/empreendedor/quero-ser-mei',
      updatedAt: '2026-07-26',
    ),
  ];

  static String _t(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) => switch (locale) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };

  static List<CityFeedItem> _dynamicItems(
    String locale, {
    required UserJourneyStage stage,
    City? city,
    CityWeather? weather,
    CityDetailSocialProof? socialProof,
    CityDetailClimateSummary? climateSummary,
    CityDetailArrivalStory? arrivalStory,
    CityDetailComparison? comparison,
    GuideActionItem? guideCurrentItem,
  }) {
    final items = <CityFeedItem>[];

    if (guideCurrentItem != null) {
      items.add(
        CityFeedItem(
          id: 'guide_now_${guideCurrentItem.id}',
          type: switch (guideCurrentItem.urgencyLevel) {
            GuideUrgencyLevel.urgent ||
            GuideUrgencyLevel.critical => CityFeedItemType.warning,
            _ => CityFeedItemType.practicalTip,
          },
          badge: _phaseLabel(locale, guideCurrentItem.phase),
          title: _t(
            locale,
            pt: 'Agora: ${guideCurrentItem.title}',
            es: 'Ahora: ${guideCurrentItem.title}',
            en: 'Now: ${guideCurrentItem.title}',
          ),
          body:
              guideCurrentItem.urgencySignal ??
              guideCurrentItem.whyItMatters ??
              guideCurrentItem.shortDescription,
          guideItemId: guideCurrentItem.id,
          sourceLabel: guideCurrentItem.evidence?.sourceLabel,
          sourceUrl: guideCurrentItem.evidence?.sourceUrl,
          updatedAt: guideCurrentItem.evidence?.lastVerified
              .toIso8601String()
              .split('T')
              .first,
        ),
      );
    }

    final budget = city?.budgetSnapshot;
    if (city != null && budget != null) {
      items.add(
        CityFeedItem(
          id: 'real_budget_${city.id}',
          type: CityFeedItemType.costUpdate,
          badge: city.name,
          title: _t(
            locale,
            pt: 'Quanto custa viver em ${city.name}',
            es: 'Cuánto cuesta vivir en ${city.name}',
            en: 'What it costs to live in ${city.name}',
          ),
          body: '',
          rangeMinBrl: budget.fairLivingTotal,
          rangeMaxBrl: budget.wellLivingTotal,
          bodyBeforeRange: _t(
            locale,
            pt: 'Faixa de planejamento: ',
            es: 'Rango de planificación: ',
            en: 'Planning range: ',
          ),
          bodyAfterRange: _t(
            locale,
            pt: ' por mês, variando por zona e estilo de vida. Fonte de referência: ${budget.sourceLabel}.',
            es: ' por mes, según la zona y el estilo de vida. Fuente de referencia: ${budget.sourceLabel}.',
            en: ' per month, depending on area and lifestyle. Reference source: ${budget.sourceLabel}.',
          ),
          updatedAt: budget.updatedAt,
          sourceLabel: budget.sourceLabel,
          sourceUrl: budget.sourceUrl,
        ),
      );
    }

    final climate = climateSummary;
    if (city != null && climate != null) {
      final condition = climate.currentWeather.conditionLabel;
      final temp = climate.currentWeather.temperatureCelsius.round();
      final seasonality = climate.seasonality;
      final seasonalityText =
          seasonality == null ||
              !_isTraceableSource(
                seasonality.sourceLabel,
                seasonality.sourceUrl,
              )
          ? null
          : _t(
              locale,
              pt: '${seasonality.visitorsLabel}. ${seasonality.rentNotes}',
              es: '${seasonality.visitorsLabel}. ${seasonality.rentNotes}',
              en: '${seasonality.visitorsLabel}. ${seasonality.rentNotes}',
            );
      items.add(
        CityFeedItem(
          id: 'real_climate_${city.id}',
          type: CityFeedItemType.lifestyleTip,
          badge: _t(
            locale,
            pt: 'Clima real',
            es: 'Clima real',
            en: 'Live climate',
          ),
          title: _t(
            locale,
            pt: 'Clima agora em ${city.name}',
            es: 'Clima ahora en ${city.name}',
            en: 'Weather now in ${city.name}',
          ),
          body: _t(
            locale,
            pt: 'Agora faz $temp°C e ${condition.toLowerCase()}. ${seasonalityText ?? ''}'
                .trim(),
            es: 'Ahora hace $temp°C y ${condition.toLowerCase()}. ${seasonalityText ?? ''}'
                .trim(),
            en: 'It is $temp°C and ${condition.toLowerCase()} now. ${seasonalityText ?? ''}'
                .trim(),
          ),
          sourceLabel: climate.sources.isEmpty
              ? 'Open-Meteo'
              : climate.sources.first.label,
          sourceUrl: climate.sources.isEmpty
              ? 'https://open-meteo.com/'
              : climate.sources.first.url,
        ),
      );
    } else if (city != null && weather != null) {
      final fallbackCondition = _weatherCodeLabel(locale, weather.weatherCode);
      items.add(
        CityFeedItem(
          id: 'weather_${city.id}',
          type: CityFeedItemType.lifestyleTip,
          badge: _t(
            locale,
            pt: 'Clima real',
            es: 'Clima real',
            en: 'Live climate',
          ),
          title: _t(
            locale,
            pt: 'Clima agora em ${city.name}',
            es: 'Clima ahora en ${city.name}',
            en: 'Weather now in ${city.name}',
          ),
          body: _t(
            locale,
            pt: '${weather.temperatureCelsius.round()}°C agora, ${fallbackCondition.toLowerCase()}. Use isso como leitura do dia, não da estação inteira.',
            es: '${weather.temperatureCelsius.round()}°C ahora, ${fallbackCondition.toLowerCase()}. Usalo como lectura del dia, no de toda la estacion.',
            en: '${weather.temperatureCelsius.round()}°C now, ${fallbackCondition.toLowerCase()}. Use this as a day reading, not the whole season.',
          ),
          sourceLabel: 'Open-Meteo',
          sourceUrl: 'https://open-meteo.com/',
        ),
      );
    }

    if (socialProof != null) {
      final opinion = socialProof.publicOpinion;
      final source = _firstTraceableSource([
        if (opinion != null) (label: opinion.provider, url: opinion.placeUrl),
        ...socialProof.sources.map(
          (item) => (label: item.label, url: item.url),
        ),
      ]);
      final text =
          socialProof.routineInsight?.shortText ??
          socialProof.neighborhoodInsight?.shortText ??
          opinion?.summary;
      if (text != null && text.isNotEmpty && source != null) {
        items.add(
          CityFeedItem(
            id: 'social_${socialProof.cityId}',
            type: CityFeedItemType.migrantStory,
            badge: _t(
              locale,
              pt: 'Sinal social',
              es: 'Señal social',
              en: 'Social signal',
            ),
            title: _t(
              locale,
              pt: 'Como ${socialProof.cityName} aparece para quem já vive aí',
              es: 'Cómo se ve ${socialProof.cityName} para quien ya vive ahí',
              en: 'How ${socialProof.cityName} reads to people already there',
            ),
            body: text,
            sourceLabel: source.label,
            sourceUrl: source.url,
          ),
        );
      }
    }

    if (arrivalStory != null) {
      final source = _firstTraceableSource(
        arrivalStory.sources.map((item) => (label: item.label, url: item.url)),
      );
      final storyText = arrivalStory.story?.shortText;
      final firstNeighborhood = arrivalStory.neighborhoods.firstOrNull;
      final focus = arrivalStory.firstMonthFocus
          .take(2)
          .map((item) => item.label)
          .join(' + ');
      final body = [
        if (storyText != null && storyText.isNotEmpty) storyText,
        if (focus.isNotEmpty)
          _t(
            locale,
            pt: 'Primeiro foco: $focus.',
            es: 'Primer foco: $focus.',
            en: 'First focus: $focus.',
          ),
        if (firstNeighborhood != null)
          _t(
            locale,
            pt: 'Bom ponto para começar: ${firstNeighborhood.name}.',
            es: 'Buen punto para empezar: ${firstNeighborhood.name}.',
            en: 'Useful starting area: ${firstNeighborhood.name}.',
          ),
      ].join(' ');
      if (body.isNotEmpty && source != null) {
        items.add(
          CityFeedItem(
            id: 'arrival_${arrivalStory.cityId}',
            type: stage == UserJourneyStage.executor
                ? CityFeedItemType.practicalTip
                : CityFeedItemType.lifestyleTip,
            badge: _t(
              locale,
              pt: 'Primeiro mês',
              es: 'Primer mes',
              en: 'First month',
            ),
            title: _t(
              locale,
              pt: 'Como começar em ${arrivalStory.cityName}',
              es: 'Como empezar en ${arrivalStory.cityName}',
              en: 'How to start in ${arrivalStory.cityName}',
            ),
            body: body,
            sourceLabel: source.label,
            sourceUrl: source.url,
          ),
        );
      }
    }

    final comparisonSource = comparison == null
        ? null
        : _firstTraceableSource(
            comparison.sources.map(
              (item) => (label: item.label, url: item.url),
            ),
          );
    if (comparison != null &&
        comparison.metrics.isNotEmpty &&
        comparisonSource != null) {
      final usefulMetric = comparison.metrics.firstWhere(
        (metric) => metric.primaryValue != null,
        orElse: () => comparison.metrics.first,
      );
      final best = usefulMetric.comparisons.firstWhere(
        (item) => item.cityId == comparison.cityId,
        orElse: () => usefulMetric.comparisons.first,
      );
      final competitors = usefulMetric.comparisons
          .where((item) => item.cityId != comparison.cityId)
          .toList(growable: false);
      if (competitors.isNotEmpty) {
        items.add(
          CityFeedItem(
            id: 'comparison_${comparison.cityId}',
            type: CityFeedItemType.opportunity,
            badge: _t(
              locale,
              pt: 'Comparativo',
              es: 'Comparativa',
              en: 'Comparison',
            ),
            title: _t(
              locale,
              pt: 'Como ${comparison.cityName} se compara',
              es: 'Como se compara ${comparison.cityName}',
              en: 'How ${comparison.cityName} compares',
            ),
            body: _t(
              locale,
              pt: '${usefulMetric.label}: ${comparison.cityName} está em ${best.value ?? '-'}${usefulMetric.unit}. Compare com ${competitors.map((item) => item.cityName).join(' e ')}.',
              es: '${usefulMetric.label}: ${comparison.cityName} esta en ${best.value ?? '-'}${usefulMetric.unit}. Comparalo con ${competitors.map((item) => item.cityName).join(' y ')}.',
              en: '${usefulMetric.label}: ${comparison.cityName} is at ${best.value ?? '-'}${usefulMetric.unit}. Compare it with ${competitors.map((item) => item.cityName).join(' and ')}.',
            ),
            sourceLabel: comparisonSource.label,
            sourceUrl: comparisonSource.url,
          ),
        );
      }
    }

    return items;
  }

  static String _phaseLabel(String locale, GuidePhase phase) => switch (phase) {
    GuidePhase.preparation => _t(
      locale,
      pt: 'Preparação',
      es: 'Preparacion',
      en: 'Preparation',
    ),
    GuidePhase.housing => _t(
      locale,
      pt: 'Moradia',
      es: 'Vivienda',
      en: 'Housing',
    ),
    GuidePhase.documents => _t(
      locale,
      pt: 'Documentos',
      es: 'Documentos',
      en: 'Documents',
    ),
    GuidePhase.work => _t(locale, pt: 'Trabalho', es: 'Trabajo', en: 'Work'),
    GuidePhase.arrival => _t(
      locale,
      pt: 'Chegada',
      es: 'Llegada',
      en: 'Arrival',
    ),
  };

  static ({String label, String url})? _firstTraceableSource(
    Iterable<({String label, String? url})> sources,
  ) {
    for (final source in sources) {
      if (_isTraceableSource(source.label, source.url)) {
        return (label: source.label, url: source.url!);
      }
    }
    return null;
  }

  static bool _isTraceableSource(String? label, String? url) {
    if (label == null || url == null || url.trim().isEmpty) return false;
    final normalized = label.toLowerCase();
    return !normalized.contains('movaro') &&
        !normalized.contains('curadoria') &&
        !normalized.contains('curated city model') &&
        !normalized.contains('ranking methodology');
  }

  static String _officialSourceLabel(String locale) => _t(
    locale,
    pt: 'Fonte oficial',
    es: 'Fuente oficial',
    en: 'Official source',
  );

  static String _weatherCodeLabel(String locale, int? code) {
    if (code == null) {
      return _t(
        locale,
        pt: 'tempo estável',
        es: 'clima estable',
        en: 'stable weather',
      );
    }
    if (code == 0) {
      return _t(
        locale,
        pt: 'céu limpo',
        es: 'cielo despejado',
        en: 'clear skies',
      );
    }
    if ({1, 2, 3}.contains(code)) {
      return _t(
        locale,
        pt: 'tempo aberto',
        es: 'tiempo abierto',
        en: 'partly clear weather',
      );
    }
    if ({45, 48}.contains(code)) {
      return _t(locale, pt: 'névoa', es: 'niebla', en: 'fog');
    }
    if ({51, 53, 55, 56, 57}.contains(code)) {
      return _t(locale, pt: 'garoa', es: 'llovizna', en: 'drizzle');
    }
    if ({61, 63, 65, 66, 67, 80, 81, 82}.contains(code)) {
      return _t(locale, pt: 'chuva', es: 'lluvia', en: 'rain');
    }
    if ({71, 73, 75, 77, 85, 86}.contains(code)) {
      return _t(locale, pt: 'neve', es: 'nieve', en: 'snow');
    }
    if ({95, 96, 99}.contains(code)) {
      return _t(locale, pt: 'trovoadas', es: 'tormenta', en: 'thunderstorms');
    }
    return _t(
      locale,
      pt: 'tempo variável',
      es: 'clima variable',
      en: 'mixed weather',
    );
  }
}
