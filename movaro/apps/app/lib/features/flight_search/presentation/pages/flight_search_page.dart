import 'package:flutter/material.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/flight_search/domain/services/flight_route_context_resolver.dart';
import 'package:movaro_app/features/flight_search/presentation/widgets/flight_search_tool.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

String _flightPageText(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
}

/// Standalone flight utility. Plan data is only an optional prefill and this
/// page never creates, updates, or opens a migration plan.
class FlightSearchPage extends StatelessWidget {
  const FlightSearchPage({
    required this.locationController,
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final LocationController locationController;
  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    final plan = migrationQuestionnaireController.generatedPlan;
    final city = plan?.currentPlanCity;
    final originCountryIso = FlightRouteContextResolver.resolveOriginCountryIso(
      savedCountryCode: locationController.savedLocation?.countryCode,
      planOriginCountry:
          plan?.originCountry ??
          journeyContextController.selection.origin?.name,
    );
    final destinationCountryIso =
        FlightRouteContextResolver.resolveDestinationCountryIso(
          cityCountryCode: city?.countryCode,
          planDestinationCountry:
              plan?.destinationCountry ??
              journeyContextController.selection.destination?.name,
        );

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    132,
                  ),
                  children: [
                    AppGlassHeader(
                      title: _flightPageText(
                        context,
                        pt: 'Buscar voos',
                        es: 'Buscar vuelos',
                        en: 'Search flights',
                      ),
                      subtitle: _flightPageText(
                        context,
                        pt: 'Uma ferramenta independente do seu plano',
                        es: 'Una herramienta independiente de tu plan',
                        en: 'A tool that works independently from your plan',
                      ),
                      onBack: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.tools,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Semantics(
                      container: true,
                      label: _flightPageText(
                        context,
                        pt: city == null
                            ? 'Escolha origem, destino e data. Esta busca não altera seu plano.'
                            : '${city.name} foi sugerida a partir do seu contexto e pode ser alterada. Esta busca não altera seu plano.',
                        es: city == null
                            ? 'Elegí origen, destino y fecha. Esta búsqueda no cambia tu plan.'
                            : 'Se sugirió ${city.name} desde tu contexto y podés cambiarla. Esta búsqueda no cambia tu plan.',
                        en: city == null
                            ? 'Choose origin, destination, and date. This search does not change your plan.'
                            : '${city.name} was suggested from your context and can be changed. This search does not change your plan.',
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _flightPageText(
                                  context,
                                  pt: city == null
                                      ? 'Use a busca sem criar um plano. Suas escolhas ficam somente nesta ferramenta.'
                                      : 'Usamos ${city.name} apenas como sugestão editável. Nada será adicionado ao plano.',
                                  es: city == null
                                      ? 'Usá la búsqueda sin crear un plan. Tus elecciones quedan sólo en esta herramienta.'
                                      : 'Usamos ${city.name} sólo como sugerencia editable. No se agregará nada al plan.',
                                  en: city == null
                                      ? 'Search without creating a plan. Your choices stay in this tool.'
                                      : 'We use ${city.name} only as an editable suggestion. Nothing is added to your plan.',
                                ),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSoftFor(context),
                                      height: 1.4,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FlightSearchTool(
                      locationController: locationController,
                      originCountryIso: originCountryIso,
                      destinationCountryIso: destinationCountryIso,
                      destinationCityName: city?.name,
                      destinationLatitude: city?.latitude,
                      destinationLongitude: city?.longitude,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 3,
        journeyContextController: journeyContextController,
        citiesController: citiesController,
        migrationQuestionnaireController: migrationQuestionnaireController,
      ),
    );
  }
}
