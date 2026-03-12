import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

class CopilotExchangeRatesModel {
  const CopilotExchangeRatesModel({
    required this.usdToBrl,
    required this.brlToUsd,
    required this.brlToArs,
    required this.arsToBrl,
    required this.usdToArs,
    required this.arsToUsd,
    required this.fetchedAt,
    required this.source,
    required this.sources,
  });

  factory CopilotExchangeRatesModel.fromJson(Map<String, dynamic> json) {
    return CopilotExchangeRatesModel(
      usdToBrl: (json['usdToBrl'] as num).toDouble(),
      brlToUsd: (json['brlToUsd'] as num).toDouble(),
      brlToArs: (json['brlToArs'] as num).toDouble(),
      arsToBrl: (json['arsToBrl'] as num).toDouble(),
      usdToArs: (json['usdToArs'] as num).toDouble(),
      arsToUsd: (json['arsToUsd'] as num).toDouble(),
      fetchedAt: json['fetchedAt'] as String,
      source: json['source'] as String,
      sources: (json['sources'] as List<dynamic>).whereType<String>().toList(),
    );
  }

  final double usdToBrl;
  final double brlToUsd;
  final double brlToArs;
  final double arsToBrl;
  final double usdToArs;
  final double arsToUsd;
  final String fetchedAt;
  final String source;
  final List<String> sources;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'usdToBrl': usdToBrl,
    'brlToUsd': brlToUsd,
    'brlToArs': brlToArs,
    'arsToBrl': arsToBrl,
    'usdToArs': usdToArs,
    'arsToUsd': arsToUsd,
    'fetchedAt': fetchedAt,
    'source': source,
    'sources': sources,
  };

  CopilotExchangeRates toEntity() => CopilotExchangeRates(
    usdToBrl: usdToBrl,
    brlToUsd: brlToUsd,
    brlToArs: brlToArs,
    arsToBrl: arsToBrl,
    usdToArs: usdToArs,
    arsToUsd: arsToUsd,
    fetchedAt: fetchedAt,
    source: source,
    sources: sources,
  );

  static CopilotExchangeRatesModel fromEntity(CopilotExchangeRates entity) =>
      CopilotExchangeRatesModel(
        usdToBrl: entity.usdToBrl,
        brlToUsd: entity.brlToUsd,
        brlToArs: entity.brlToArs,
        arsToBrl: entity.arsToBrl,
        usdToArs: entity.usdToArs,
        arsToUsd: entity.arsToUsd,
        fetchedAt: entity.fetchedAt,
        source: entity.source,
        sources: entity.sources,
      );
}
