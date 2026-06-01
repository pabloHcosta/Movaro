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

class _SplashPageState extends State<SplashPage> {
  static const _minimumBrandExposure = Duration(milliseconds: 2400);

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;
    _initialize();
  }

  Future<void> _initialize() async {
    final startedAt = DateTime.now();

    // The backend is treated as an enhancement, not a gate. A failed health
    // check (no connection, slow network, cold backend, blocked origin) must
    // never brick the app at launch: we still boot into the public experience
    // and let each surface degrade gracefully (cached data, seed fallback or a
    // local inline retry). This protects the "explore in seconds, no account"
    // promise even when the API is temporarily unreachable.
    await _runStep('api_health_check', () => widget.apiHealthService.check());

    // Each initialization step is best-effort and isolated: a failure in one
    // (e.g. a network-backed call while offline) must not abort the boot.
    await _runStep(
      'journey_context',
      () => widget.journeyContextController.initialize(),
    );
    await _runStep('location', () => widget.locationController.initialize());
    await _runStep('auth', () => widget.authController.initialize());
    await _runStep(
      'cities',
      () => widget.citiesController.initialize(
        preloadData: widget.journeyContextController.hasSelectedJourney,
      ),
    );

    if (widget.journeyContextController.hasSelectedJourney) {
      await _runStep(
        'migration_questionnaire',
        () => widget.migrationQuestionnaireController.initialize(),
      );
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

  /// Runs a single boot step, swallowing (but logging) any failure so that a
  /// degraded dependency never blocks the launch sequence.
  Future<void> _runStep(String label, Future<void> Function() step) async {
    try {
      await step();
    } catch (error) {
      debugPrint('Splash: boot step "$label" failed, continuing: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SplashLoadingView(
      loadingLabel: l10n.splashLoadingLabel,
      initializingLabel: l10n.splashInitializingLabel,
    );
  }
}
