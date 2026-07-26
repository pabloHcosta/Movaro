import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

class CopilotExchangeRatesModel {
  const CopilotExchangeRatesModel({
    required this.usdToBrl,
    required this.brlToUsd,
    required this.brlToArs,
    required this.arsToBrl,
    required this.usdToArs,
    required this.arsToUsd,
    required this.brlToEur,
    required this.brlToClp,
    required this.brlToUyu,
    required this.brlToCop,
    required this.brlToPen,
    required this.brlToPyg,
    required this.brlToBob,
    required this.fetchedAt,
    required this.source,
    required this.sources,
    this.referenceDate,
    this.isIndicative = true,
  });

  factory CopilotExchangeRatesModel.fromJson(Map<String, dynamic> json) {
    // Fallback multipliers applied when API doesn't return new fields yet.
    final usdToBrl = (json['usdToBrl'] as num).toDouble();
    final brlToUsd = (json['brlToUsd'] as num).toDouble();
    return CopilotExchangeRatesModel(
      usdToBrl: usdToBrl,
      brlToUsd: brlToUsd,
      brlToArs: (json['brlToArs'] as num).toDouble(),
      arsToBrl: (json['arsToBrl'] as num).toDouble(),
      usdToArs: (json['usdToArs'] as num).toDouble(),
      arsToUsd: (json['arsToUsd'] as num).toDouble(),
      brlToEur: (json['brlToEur'] as num?)?.toDouble() ?? brlToUsd * 0.92,
      brlToClp: (json['brlToClp'] as num?)?.toDouble() ?? brlToUsd * 940.0,
      brlToUyu: (json['brlToUyu'] as num?)?.toDouble() ?? brlToUsd * 41.0,
      brlToCop: (json['brlToCop'] as num?)?.toDouble() ?? brlToUsd * 4200.0,
      brlToPen: (json['brlToPen'] as num?)?.toDouble() ?? brlToUsd * 3.75,
      brlToPyg: (json['brlToPyg'] as num?)?.toDouble() ?? brlToUsd * 7800.0,
      brlToBob: (json['brlToBob'] as num?)?.toDouble() ?? brlToUsd * 6.9,
      fetchedAt: json['fetchedAt'] as String,
      source: json['source'] as String,
      sources: (json['sources'] as List<dynamic>).whereType<String>().toList(),
      referenceDate: json['referenceDate'] as String?,
      isIndicative: json['isIndicative'] as bool? ?? true,
    );
  }

  final double usdToBrl;
  final double brlToUsd;
  final double brlToArs;
  final double arsToBrl;
  final double usdToArs;
  final double arsToUsd;
  final double brlToEur;
  final double brlToClp;
  final double brlToUyu;
  final double brlToCop;
  final double brlToPen;
  final double brlToPyg;
  final double brlToBob;
  final String fetchedAt;
  final String source;
  final List<String> sources;
  final String? referenceDate;
  final bool isIndicative;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'usdToBrl': usdToBrl,
    'brlToUsd': brlToUsd,
    'brlToArs': brlToArs,
    'arsToBrl': arsToBrl,
    'usdToArs': usdToArs,
    'arsToUsd': arsToUsd,
    'brlToEur': brlToEur,
    'brlToClp': brlToClp,
    'brlToUyu': brlToUyu,
    'brlToCop': brlToCop,
    'brlToPen': brlToPen,
    'brlToPyg': brlToPyg,
    'brlToBob': brlToBob,
    'fetchedAt': fetchedAt,
    'source': source,
    'sources': sources,
    'referenceDate': referenceDate,
    'isIndicative': isIndicative,
  };

  CopilotExchangeRates toEntity() => CopilotExchangeRates(
    usdToBrl: usdToBrl,
    brlToUsd: brlToUsd,
    brlToArs: brlToArs,
    arsToBrl: arsToBrl,
    usdToArs: usdToArs,
    arsToUsd: arsToUsd,
    brlToEur: brlToEur,
    brlToClp: brlToClp,
    brlToUyu: brlToUyu,
    brlToCop: brlToCop,
    brlToPen: brlToPen,
    brlToPyg: brlToPyg,
    brlToBob: brlToBob,
    fetchedAt: fetchedAt,
    source: source,
    sources: sources,
    referenceDate: referenceDate,
    isIndicative: isIndicative,
  );

  static CopilotExchangeRatesModel fromEntity(CopilotExchangeRates entity) =>
      CopilotExchangeRatesModel(
        usdToBrl: entity.usdToBrl,
        brlToUsd: entity.brlToUsd,
        brlToArs: entity.brlToArs,
        arsToBrl: entity.arsToBrl,
        usdToArs: entity.usdToArs,
        arsToUsd: entity.arsToUsd,
        brlToEur: entity.brlToEur,
        brlToClp: entity.brlToClp,
        brlToUyu: entity.brlToUyu,
        brlToCop: entity.brlToCop,
        brlToPen: entity.brlToPen,
        brlToPyg: entity.brlToPyg,
        brlToBob: entity.brlToBob,
        fetchedAt: entity.fetchedAt,
        source: entity.source,
        sources: entity.sources,
        referenceDate: entity.referenceDate,
        isIndicative: entity.isIndicative,
      );
}
