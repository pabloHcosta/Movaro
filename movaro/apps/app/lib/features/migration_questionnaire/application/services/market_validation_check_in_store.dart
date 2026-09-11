import 'package:mudavi_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MarketValidationClarity { clear, partial, unclear }

enum MarketValidationProgress { completed, blocked, notStarted }

enum MarketValidationValue { high, moderate, low }

class MarketValidationCheckIn {
  const MarketValidationCheckIn({
    required this.clarity,
    required this.progress,
    required this.value,
  });

  final MarketValidationClarity clarity;
  final MarketValidationProgress progress;
  final MarketValidationValue value;
}

/// Controls the optional pilot check-in without retaining the participant's
/// task, city or answers. Only bounded categories are sent through the
/// consent-gated product metrics channel.
class MarketValidationCheckInStore {
  MarketValidationCheckInStore({
    SharedPreferences? preferences,
    GuideFlowMetricsStore? metricsStore,
    DateTime Function()? now,
  }) : _preferences = preferences,
       _metricsStore = metricsStore ?? GuideFlowMetricsStore.instance,
       _now = now ?? DateTime.now;

  static final MarketValidationCheckInStore instance =
      MarketValidationCheckInStore();
  static const String _submittedPhasesKey =
      'mudavi.market_validation.submitted_phases.v1';
  static const String _lastDismissedAtKey =
      'mudavi.market_validation.last_dismissed_at.v1';
  static const Duration _dismissalCooldown = Duration(days: 7);

  SharedPreferences? _preferences;
  final GuideFlowMetricsStore _metricsStore;
  final DateTime Function() _now;

  Future<bool> shouldOffer({required String phaseKey}) async {
    if (!_metricsStore.isEnabled) {
      return false;
    }
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    final submitted =
        preferences.getStringList(_submittedPhasesKey) ?? const <String>[];
    if (submitted.contains(phaseKey)) {
      return false;
    }
    final lastDismissed = DateTime.tryParse(
      preferences.getString(_lastDismissedAtKey) ?? '',
    );
    return lastDismissed == null ||
        _now().difference(lastDismissed) >= _dismissalCooldown;
  }

  Future<void> markShown({required String phaseKey}) {
    return _metricsStore.record(
      GuideFlowMetric.pilotCheckInShown,
      validationPhaseBand: phaseKey,
    );
  }

  Future<void> dismiss({required String phaseKey}) async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    await preferences.setString(
      _lastDismissedAtKey,
      _now().toUtc().toIso8601String(),
    );
    await _metricsStore.record(
      GuideFlowMetric.pilotCheckInDismissed,
      validationPhaseBand: phaseKey,
    );
  }

  Future<void> submit({
    required String phaseKey,
    required MarketValidationCheckIn checkIn,
  }) async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    final submitted = <String>{
      ...?preferences.getStringList(_submittedPhasesKey),
      phaseKey,
    };
    await preferences.setStringList(_submittedPhasesKey, submitted.toList());
    await _metricsStore.record(
      GuideFlowMetric.pilotCheckInSubmitted,
      validationClarityBand: checkIn.clarity.name,
      validationProgressBand: checkIn.progress.name,
      validationValueBand: checkIn.value.name,
      validationPhaseBand: phaseKey,
    );
  }
}
