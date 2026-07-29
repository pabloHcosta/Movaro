import 'package:flutter/material.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

class CityStrengthSignal {
  const CityStrengthSignal({
    required this.title,
    required this.supporting,
    required this.sourceLabel,
  });

  final String title;
  final String supporting;
  final String sourceLabel;
}

class CityStrengthStoryService {
  const CityStrengthStoryService._();

  static List<CityStrengthSignal> strongest(BuildContext context, City city) {
    final candidates = <_ScoredSignal>[
      if (city.costOfLivingScore >= 68 &&
          city.budgetSnapshot?.sourceUrl != null)
        _ScoredSignal(
          weight: city.costOfLivingScore,
          signal: CityStrengthSignal(
            title: _localizedText(
              context,
              pt: 'Entrada de custo mais leve',
              es: 'Entrada de costo más liviana',
              en: 'Lighter cost of entry',
            ),
            supporting: _budgetSupporting(context, city),
            sourceLabel: _budgetSource(city)!,
          ),
        ),
      if (city.safetyScore >= 68 && city.sources.safety != null)
        _ScoredSignal(
          weight: city.safetyScore,
          signal: CityStrengthSignal(
            title: _localizedText(
              context,
              pt: 'Segurança acima da média do catálogo',
              es: 'Seguridad por encima del promedio del catálogo',
              en: 'Safety above the catalog average',
            ),
            supporting: _localizedText(
              context,
              pt: 'A cidade entra melhor para rotina e adaptação no dia a dia.',
              es: 'La ciudad entra mejor para rutina y adaptación del día a día.',
              en: 'The city supports day-to-day routine and adaptation better.',
            ),
            sourceLabel: city.sources.safety!.provider,
          ),
        ),
      if (city.jobMarketScore >= 70 &&
          _jobStabilityWeight(city) >= 68 &&
          city.sources.employment != null)
        _ScoredSignal(
          weight: _jobStabilityWeight(city),
          signal: CityStrengthSignal(
            title: _localizedText(
              context,
              pt: 'Mercado mais estável ao longo do ano',
              es: 'Mercado más estable durante el año',
              en: 'More stable job market through the year',
            ),
            supporting: _jobSupporting(context, city),
            sourceLabel: city.sources.employment!.provider,
          ),
        ),
      if (city.publicOpinion != null &&
          city.publicOpinion!.placeUrl?.isNotEmpty == true &&
          (city.publicOpinion!.rating ?? 0) >= 4.2 &&
          city.publicOpinion!.positivePoints.isNotEmpty)
        _ScoredSignal(
          weight: ((city.publicOpinion!.rating ?? 0) * 20).round(),
          signal: CityStrengthSignal(
            title: _localizedText(
              context,
              pt: 'Leitura pública mais favorável',
              es: 'Lectura pública más favorable',
              en: 'More favorable public sentiment',
            ),
            supporting: city.publicOpinion!.positivePoints.first,
            sourceLabel: city.publicOpinion!.provider,
          ),
        ),
      if (city.economicActivityScore >= 72 &&
          city.topIndustries.isNotEmpty &&
          city.sources.employment != null)
        _ScoredSignal(
          weight: city.economicActivityScore,
          signal: CityStrengthSignal(
            title: _localizedText(
              context,
              pt: 'Economia mais puxada por setores reais',
              es: 'Economía más sostenida por sectores reales',
              en: 'Economy supported by real sectors',
            ),
            supporting: _localizedText(
              context,
              pt: 'Setores fortes: ${city.topIndustries.take(2).join(', ')}.',
              es: 'Sectores fuertes: ${city.topIndustries.take(2).join(', ')}.',
              en: 'Stronger sectors: ${city.topIndustries.take(2).join(', ')}.',
            ),
            sourceLabel: city.sources.employment!.provider,
          ),
        ),
    ];

    candidates.sort((a, b) => b.weight.compareTo(a.weight));
    return candidates
        .take(3)
        .map((item) => item.signal)
        .toList(growable: false);
  }

  static String _budgetSupporting(BuildContext context, City city) {
    final budget = city.budgetSnapshot;
    if (budget == null) {
      return _localizedText(
        context,
        pt: 'O score de custo e moradia sugere uma entrada menos apertada do que outras cidades.',
        es: 'El puntaje de costo y vivienda sugiere una entrada menos ajustada que otras ciudades.',
        en: 'The cost and housing score suggests a less tight start than other cities.',
      );
    }
    final range = MultiCurrencyAmount.formatRangeFromBrl(
      context: context,
      minBrl: budget.fairLivingTotal,
      maxBrl: budget.wellLivingTotal,
    );
    return _localizedText(
      context,
      pt: 'Faixa de planejamento para uma pessoa: $range/mês.',
      es: 'Rango de planificación para una persona: $range/mes.',
      en: 'Planning range for one person: $range/month.',
    );
  }

  static String? _budgetSource(City city) {
    final budget = city.budgetSnapshot;
    if (budget == null) {
      return null;
    }
    return '${budget.sourceLabel} · ${budget.updatedAt}';
  }

  static int _jobStabilityWeight(City city) {
    final seasonality = CitySeasonalityProfile.of(city);
    final penalty = switch (seasonality?.severity) {
      CitySeasonalitySeverity.high => 18,
      CitySeasonalitySeverity.medium => 8,
      _ => 0,
    };
    return (city.jobMarketScore - penalty).clamp(0, 100);
  }

  static String _jobSupporting(BuildContext context, City city) {
    final seasonality = CitySeasonalityProfile.of(city);
    if (seasonality == null) {
      return _localizedText(
        context,
        pt: 'A cidade depende menos de picos sazonais e tende a sustentar busca de trabalho por mais meses.',
        es: 'La ciudad depende menos de picos estacionales y tiende a sostener la búsqueda laboral por más meses.',
        en: 'The city depends less on seasonal peaks and tends to sustain job search through more of the year.',
      );
    }
    return _localizedText(
      context,
      pt: 'Mesmo com alguma sazonalidade, ela ainda mantém base melhor de trabalho do que cidades mais turísticas.',
      es: 'Incluso con cierta estacionalidad, mantiene una mejor base laboral que ciudades más turísticas.',
      en: 'Even with some seasonality, it still keeps a better work base than more tourist-driven cities.',
    );
  }

  static String _localizedText(
    BuildContext context, {
    required String pt,
    required String es,
    required String en,
  }) {
    return switch (Localizations.localeOf(context).languageCode) {
      'es' => es,
      'en' => en,
      _ => pt,
    };
  }
}

class _ScoredSignal {
  const _ScoredSignal({required this.weight, required this.signal});

  final int weight;
  final CityStrengthSignal signal;
}
