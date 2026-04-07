import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
import 'package:movaro_app/features/location/location_controller.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';
import 'package:movaro_app/features/splash/presentation/pages/splash_loading_view.dart';
import 'package:movaro_app/features/splash/presentation/pages/splash_offline_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    required this.environment,
    required this.authController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    required this.apiHealthService,
    required this.journeyContextController,
    required this.locationController,
    super.key,
  });

  final AppEnvironment environment;
  final AuthController authController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final ApiHealthService apiHealthService;
  final JourneyContextController journeyContextController;
  final LocationController locationController;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

enum SplashStatus { loading, offline }

class _SplashPageState extends State<SplashPage> {
  static const _minimumBrandExposure = Duration(milliseconds: 2400);

  bool _started = false;
  SplashStatus _status = SplashStatus.loading;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;
    _initialize();
  }

  Future<void> _initialize() async {
    final startedAt = DateTime.now();

    if (mounted) {
      setState(() {
        _status = SplashStatus.loading;
      });
    }

    try {
      await widget.apiHealthService.check();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _status = SplashStatus.offline;
      });
      return;
    }

    await widget.journeyContextController.initialize();
    await widget.locationController.initialize();
    await widget.authController.initialize();
    await widget.citiesController.initialize(
      preloadData: widget.journeyContextController.hasSelectedJourney,
    );

    if (widget.journeyContextController.hasSelectedJourney) {
      await widget.migrationQuestionnaireController.initialize();
    }

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumBrandExposure - elapsed;

    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) return;

    const shouldReplayIntroFlow = false;

    final resolvedRoute =
        shouldReplayIntroFlow || !widget.journeyContextController.hasSeenIntro
        ? AppRoutes.intro
        : !widget.journeyContextController.hasDestinationSelected
        ? AppRoutes.publicHome
        : !widget.journeyContextController.hasSelectedJourney
        ? AppRoutes.publicHome
        : widget.authController.isAuthenticated
        ? (widget.authController.needsOnboarding
              ? AppRoutes.onboarding
              : widget.authController.resolveRouteAfterLogin())
        : AppRoutes.publicHome;

    Navigator.pushReplacementNamed(
      context,
      resolvedRoute,
      arguments:
          shouldReplayIntroFlow ||
          !widget.journeyContextController.hasSeenIntro,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    switch (_status) {
      case SplashStatus.offline:
        return SplashOfflinePage(onRetry: _initialize);

      case SplashStatus.loading:
        return SplashLoadingView(
          loadingLabel: l10n.splashLoadingLabel,
          initializingLabel: l10n.splashInitializingLabel,
        );
    }
  }
}
