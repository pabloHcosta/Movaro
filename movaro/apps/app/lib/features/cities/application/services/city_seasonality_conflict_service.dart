/// Service that evaluates the overlap between a user's planned arrival window
/// and a city's peak tourist season.
///
/// This is the bridge between [MigrationPlan.timeline] and
/// [CitySeasonalityProfile] — it turns a raw timeline string like "in_0_3m"
/// into a concrete month range, then computes how many of those months fall
/// inside the city's peak season and assigns a conflict level.
library;

import 'package:movaro_app/features/cities/application/services/city_seasonality_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

// ─── Conflict level ────────────────────────────────────────────────────────────

enum SeasonalityConflictLevel {
  /// No overlap between arrival window and peak months, or no data.
  none,

  /// 1 month overlap, or city is medium-severity with any overlap.
  caution,

  /// 2+ months overlap AND city is high-severity.  User WILL arrive during
  /// peak — housing and pricing will be severely impacted.
  critical,
}

// ─── Conflict result ───────────────────────────────────────────────────────────

class SeasonalityConflict {
  const SeasonalityConflict({
    required this.level,
    required this.arrivalMonths,
    required this.overlapMonths,
    required this.data,
  });

  final SeasonalityConflictLevel level;

  /// Full estimated arrival window (1-based months, e.g. [1, 2, 3]).
  final List<int> arrivalMonths;

  /// Subset of [arrivalMonths] that overlap with the city's peak season.
  final List<int> overlapMonths;

  /// The underlying seasonality data for the city.
  final CitySeasonalityData data;

  bool get hasConflict => level != SeasonalityConflictLevel.none;

  // ── Localized month label for the overlap window ─────────────────────────

  String overlapLabel(String locale) {
    if (overlapMonths.isEmpty) return '';
    final names = _monthNames(locale);
    if (overlapMonths.length == 1) return names[overlapMonths.first - 1];
    return '${names[overlapMonths.first - 1]}–${names[overlapMonths.last - 1]}';
  }

  String arrivalLabel(String locale) {
    if (arrivalMonths.isEmpty) return '';
    final names = _monthNames(locale);
    if (arrivalMonths.length == 1) return names[arrivalMonths.first - 1];
    return '${names[arrivalMonths.first - 1]}–${names[arrivalMonths.last - 1]}';
  }

  // ── Personalized conflict messages ────────────────────────────────────────

  String conflictMessage(String locale) => switch (locale) {
        'pt' => _messagePt(),
        'es' => _messageEs(),
        _ => _messageEn(),
      };

  String conflictHeadline(String locale) => switch (locale) {
        'pt' => _headlinePt(),
        'es' => _headlineEs(),
        _ => _headlineEn(),
      };

  String _headlinePt() {
    final label = overlapLabel('pt');
    if (level == SeasonalityConflictLevel.critical) {
      return '⚠ Sua chegada ($label) é na alta temporada';
    }
    return 'Atenção: chegada próxima à alta temporada ($label)';
  }

  String _headlineEs() {
    final label = overlapLabel('es');
    if (level == SeasonalityConflictLevel.critical) {
      return '⚠ Tu llegada ($label) cae en temporada alta';
    }
    return 'Atención: llegada cercana a la temporada alta ($label)';
  }

  String _headlineEn() {
    final label = overlapLabel('en');
    if (level == SeasonalityConflictLevel.critical) {
      return '⚠ Your arrival ($label) falls in peak season';
    }
    return 'Heads up: arrival near peak season ($label)';
  }

  String _messagePt() {
    if (level == SeasonalityConflictLevel.none) return '';
    final label = overlapLabel('pt');
    if (level == SeasonalityConflictLevel.critical) {
      return 'Moradia de longa duração fica escassa e até 10–15× mais cara '
          'durante $label nesta cidade. '
          'Garanta contrato antes de embarcar ou considere chegar na baixa '
          'temporada (${_lowLabel('pt')}).';
    }
    return 'Sua chegada em $label coincide com o início da temporada alta. '
        'Reserve moradia com pelo menos 2–3 meses de antecedência.';
  }

  String _messageEs() {
    if (level == SeasonalityConflictLevel.none) return '';
    final label = overlapLabel('es');
    if (level == SeasonalityConflictLevel.critical) {
      return 'La vivienda a largo plazo escasea y puede costar hasta 10–15× más '
          'durante $label en esta ciudad. '
          'Asegura contrato antes de embarcarte o considera llegar en temporada '
          'baja (${_lowLabel('es')}).';
    }
    return 'Tu llegada en $label coincide con el inicio de la temporada alta. '
        'Reserva vivienda con al menos 2–3 meses de anticipación.';
  }

  String _messageEn() {
    if (level == SeasonalityConflictLevel.none) return '';
    final label = overlapLabel('en');
    if (level == SeasonalityConflictLevel.critical) {
      return 'Long-term housing becomes scarce and up to 10–15× more expensive '
          'during $label in this city. '
          'Secure a lease before you travel, or consider arriving in the '
          'off-season (${_lowLabel('en')}).';
    }
    return 'Your arrival in $label coincides with the start of peak season. '
        'Book accommodation at least 2–3 months in advance.';
  }

  String _lowLabel(String locale) {
    if (data.lowMonths.isEmpty) return '';
    final names = _monthNames(locale);
    return '${names[data.lowMonths.first - 1]}–${names[data.lowMonths.last - 1]}';
  }

  // ── Month name tables ─────────────────────────────────────────────────────

  static List<String> _monthNames(String locale) => switch (locale) {
        'es' => const [
            'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
            'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
          ],
        'en' => const [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
          ],
        _ => const [
            'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
            'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
          ],
      };
}

// ─── Service ───────────────────────────────────────────────────────────────────

class CitySeasonalityConflictService {
  const CitySeasonalityConflictService._();

  /// Evaluates the seasonality conflict between a city and a migration timeline.
  ///
  /// Returns `null` if the city has no seasonality data.
  /// Returns a [SeasonalityConflict] with [SeasonalityConflictLevel.none] if
  /// the timeline doesn't produce a concrete arrival window.
  static SeasonalityConflict? evaluate({
    required City city,
    required String? timeline,
  }) {
    final data = CitySeasonalityProfile.of(city);
    if (data == null) return null;

    final arrivalMonths = _arrivalMonthsFor(timeline);
    if (arrivalMonths.isEmpty) {
      return null; // no concrete estimate — don't show any warning
    }

    final overlapMonths = arrivalMonths
        .where((m) => data.peakMonths.contains(m))
        .toList();

    if (overlapMonths.isEmpty) {
      return SeasonalityConflict(
        level: SeasonalityConflictLevel.none,
        arrivalMonths: arrivalMonths,
        overlapMonths: const [],
        data: data,
      );
    }

    final isHigh = data.severity == CitySeasonalitySeverity.high;
    final level = (isHigh && overlapMonths.length >= 2)
        ? SeasonalityConflictLevel.critical
        : SeasonalityConflictLevel.caution;

    return SeasonalityConflict(
      level: level,
      arrivalMonths: arrivalMonths,
      overlapMonths: overlapMonths,
      data: data,
    );
  }

  // ── Timeline → month window ───────────────────────────────────────────────

  /// Maps a [MigrationPlan.timeline] string to a list of 1-based months.
  ///
  /// Timeline values (from question_repository_impl.dart):
  ///   'in_0_3m'     → arriving in the next 0–3 months from today
  ///   'in_3_6m'     → arriving in 3–6 months from today
  ///   'in_6_12m'    → arriving in 6–12 months from today
  ///   'in_12m_plus' → too far out — skip (no concrete estimate)
  ///   'just_exploring' / 'depends' → skip
  static List<int> _arrivalMonthsFor(String? timeline) {
    if (timeline == null) return const [];
    final now = DateTime.now().month; // 1-based
    return switch (timeline) {
      'in_0_3m' => _monthRange(now, 3),
      'in_3_6m' => _monthRange(now + 3, 3),
      'in_6_12m' => _monthRange(now + 6, 6),
      _ => const [],
    };
  }

  /// Generates [count] consecutive 1-based months starting from [start],
  /// wrapping around December → January.
  static List<int> _monthRange(int start, int count) =>
      List.generate(count, (i) => (start - 1 + i) % 12 + 1);
}
