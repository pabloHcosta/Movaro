import 'package:movaro_app/app/localization/generated/app_localizations.dart';
import 'package:movaro_app/features/location/location_data.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/default_migration_guide_builder.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class MigrationGuideRegistry {
  const MigrationGuideRegistry._();

  static const List<String> _defaultSupportedDestinations = <String>['brasil'];

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
    return ArgentinaBrazilGuideDataSource.isArgentinaToBrazil(
      originCountry,
      destinationCountry,
    );
  }

  static bool supportsPlan(MigrationPlan plan) =>
      supportsCorridor(plan.originCountry, plan.destinationCountry);

  static List<GuideActionItem> build({
    required AppLocalizations l10n,
    required MigrationPlan plan,
    LocationData? currentLocation,
    String? localeCode,
    Set<String> completedIds = const <String>{},
  }) {
    if (supportsPlan(plan)) {
      return ArgentinaBrazilGuideDataSource.build(
            plan,
            currentLocation: currentLocation,
            localeCode: localeCode,
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
}
