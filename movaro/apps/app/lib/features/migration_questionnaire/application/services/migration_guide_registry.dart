import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/features/location/location_data.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/default_migration_guide_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/uruguay_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

typedef MigrationGuideBuilder =
    List<GuideActionItem> Function(
      MigrationPlan plan, {
      LocationData? currentLocation,
      String? localeCode,
      CopilotExchangeRates? exchangeRates,
    });

class MigrationGuideDefinition {
  const MigrationGuideDefinition({
    required this.key,
    required this.supports,
    required this.build,
  });

  final String key;
  final bool Function(String originCountry, String destinationCountry) supports;
  final MigrationGuideBuilder build;
}

class MigrationGuideRegistry {
  const MigrationGuideRegistry._();

  static const List<String> _defaultSupportedDestinations = <String>['brasil'];
  static const List<MigrationGuideDefinition> _guideDefinitions = [
    MigrationGuideDefinition(
      key: 'argentina->brasil',
      supports: ArgentinaBrazilGuideDataSource.isArgentinaToBrazil,
      build: ArgentinaBrazilGuideDataSource.build,
    ),
    MigrationGuideDefinition(
      key: 'uruguai->brasil',
      supports: UruguayBrazilGuideDataSource.isUruguayToBrazil,
      build: UruguayBrazilGuideDataSource.build,
    ),
  ];

  static String? normalizeCountryId(String? raw) {
    if (raw == null) return null;

    final normalized = raw.toLowerCase().trim();
    return switch (normalized) {
      'br' || 'brazil' || 'brasil' => 'brasil',
      'ar' || 'argentina' => 'argentina',
      'cl' || 'chile' => 'chile',
      'uy' || 'uruguay' || 'uruguai' => 'uruguai',
      'py' || 'paraguay' || 'paraguai' => 'paraguai',
      _ => normalized,
    };
  }

  static List<String> get defaultSupportedDestinations =>
      List<String>.unmodifiable(_defaultSupportedDestinations);

  static bool supportsDestination(String destinationCountry) =>
      _defaultSupportedDestinations.contains(
        normalizeCountryId(destinationCountry),
      );

  static bool supportsCorridor(
    String originCountry,
    String destinationCountry,
  ) {
    return _guideDefinitions.any(
      (definition) => definition.supports(originCountry, destinationCountry),
    );
  }

  static bool supportsPlan(MigrationPlan plan) =>
      supportsCorridor(plan.originCountry, plan.destinationCountry);

  static String? corridorKey(String originCountry, String destinationCountry) {
    final definition = _resolveDefinition(originCountry, destinationCountry);
    return definition?.key;
  }

  static List<GuideActionItem> build({
    required AppLocalizations l10n,
    required MigrationPlan plan,
    LocationData? currentLocation,
    String? localeCode,
    CopilotExchangeRates? exchangeRates,
    Set<String> completedIds = const <String>{},
  }) {
    final definition = _resolveDefinition(
      plan.originCountry,
      plan.destinationCountry,
    );

    if (definition != null) {
      return definition
          .build(
            plan,
            currentLocation: currentLocation,
            localeCode: localeCode,
            exchangeRates: exchangeRates,
          )
          .map(
            (item) =>
                item.copyWith(isCompleted: completedIds.contains(item.id)),
          )
          .toList(growable: false);
    }

    return DefaultMigrationGuideBuilder.build(
      l10n: l10n,
      plan: plan,
      completedIds: completedIds,
    );
  }

  static MigrationGuideDefinition? _resolveDefinition(
    String originCountry,
    String destinationCountry,
  ) {
    return _guideDefinitions.cast<MigrationGuideDefinition?>().firstWhere(
      (candidate) =>
          candidate?.supports(originCountry, destinationCountry) ?? false,
      orElse: () => null,
    );
  }
}
