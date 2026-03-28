import 'package:flutter/material.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';

enum CityFeedItemType {
  costUpdate,
  lifestyleTip,
  migrantStory,
  practicalTip,
  warning,
  opportunity,
}

class CityFeedItem {
  const CityFeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.badge,
    this.actionLabel,
    this.actionUrl,
    this.cityCodes = const <String>[],
    this.stages = const <UserJourneyStage>[],
    this.updatedAt,
  });

  final String id;
  final CityFeedItemType type;

  /// Short headline (max ~50 chars).
  final String title;

  /// 1–3 line body — snackable, direct.
  final String body;

  /// Optional badge: 'novo', 'atualizado', 'alerta'.
  final String? badge;

  final String? actionLabel;
  final String? actionUrl;

  /// City codes this item applies to. Empty = all cities.
  final List<String> cityCodes;

  /// Journey stages this item is relevant for. Empty = all stages.
  final List<UserJourneyStage> stages;

  /// Optional curation date shown on cost-sensitive cards, e.g. "Mar/2025".
  final String? updatedAt;

  bool isRelevantFor({required String? cityCode, required UserJourneyStage stage}) {
    final cityMatch = cityCodes.isEmpty || (cityCode != null && cityCodes.contains(cityCode));
    final stageMatch = stages.isEmpty || stages.contains(stage);
    return cityMatch && stageMatch;
  }

  IconData get icon => switch (type) {
        CityFeedItemType.costUpdate => Icons.show_chart_rounded,
        CityFeedItemType.lifestyleTip => Icons.wb_sunny_rounded,
        CityFeedItemType.migrantStory => Icons.format_quote_rounded,
        CityFeedItemType.practicalTip => Icons.lightbulb_outline_rounded,
        CityFeedItemType.warning => Icons.warning_amber_rounded,
        CityFeedItemType.opportunity => Icons.trending_up_rounded,
      };

  Color typeColor(bool isDark) => switch (type) {
        CityFeedItemType.costUpdate => const Color(0xFF3B7CC8),
        CityFeedItemType.lifestyleTip => const Color(0xFF1D9E75),
        CityFeedItemType.migrantStory => const Color(0xFF9B59B6),
        CityFeedItemType.practicalTip => const Color(0xFF3B7CC8),
        CityFeedItemType.warning => const Color(0xFFE8873A),
        CityFeedItemType.opportunity => const Color(0xFF1D9E75),
      };

  String typeLabel(String locale) => switch (type) {
        CityFeedItemType.costUpdate => switch (locale) {
            'pt' => 'Custo de vida',
            'es' => 'Costo de vida',
            _ => 'Cost of living',
          },
        CityFeedItemType.lifestyleTip => switch (locale) {
            'pt' => 'Estilo de vida',
            'es' => 'Estilo de vida',
            _ => 'Lifestyle',
          },
        CityFeedItemType.migrantStory => switch (locale) {
            'pt' => 'Quem já fez',
            'es' => 'Quien ya lo hizo',
            _ => 'Real experience',
          },
        CityFeedItemType.practicalTip => switch (locale) {
            'pt' => 'Dica prática',
            'es' => 'Consejo practico',
            _ => 'Practical tip',
          },
        CityFeedItemType.warning => switch (locale) {
            'pt' => 'Atenção',
            'es' => 'Atencion',
            _ => 'Watch out',
          },
        CityFeedItemType.opportunity => switch (locale) {
            'pt' => 'Oportunidade',
            'es' => 'Oportunidad',
            _ => 'Opportunity',
          },
      };
}
