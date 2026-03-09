import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/network/api_health_service.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/movaro_logo.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    required this.environment,
    required this.authController,
    required this.migrationQuestionnaireController,
    required this.apiHealthService,
    required this.journeyContextController,
    super.key,
  });

  final AppEnvironment environment;
  final AuthController authController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final ApiHealthService apiHealthService;
  final JourneyContextController journeyContextController;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _started = false;
  bool _isCheckingApi = false;
  bool _apiUnavailable = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) {
      return;
    }

    _started = true;
    _initialize();
  }

  Future<void> _initialize() async {
    if (mounted) {
      setState(() {
        _isCheckingApi = true;
        _apiUnavailable = false;
      });
    }

    try {
      await widget.apiHealthService.check();
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingApi = false;
        _apiUnavailable = true;
      });
      return;
    }

    await widget.journeyContextController.initialize();
    await widget.authController.initialize();

    if (widget.journeyContextController.hasSelectedJourney) {
      await widget.migrationQuestionnaireController.initialize();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isCheckingApi = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    final shouldReplayIntroFlow = widget.environment.isDevelopment;

    final nextRoute = shouldReplayIntroFlow || !widget.journeyContextController.hasSeenIntro
        ? AppRoutes.intro
        : !widget.journeyContextController.hasSelectedJourney
        ? AppRoutes.journeySetup
        : widget.authController.isAuthenticated
        ? (widget.authController.needsOnboarding
              ? AppRoutes.onboarding
              : widget.authController.resolveRouteAfterLogin())
        : AppRoutes.publicHome;
    Navigator.pushReplacementNamed(
      context,
      nextRoute,
      arguments: shouldReplayIntroFlow || !widget.journeyContextController.hasSeenIntro,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final l10n = context.l10n;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.heroStart.withValues(alpha: 0.84),
                  AppColors.heroMiddle.withValues(alpha: 0.54),
                  AppColors.heroEnd.withValues(alpha: 0.20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -40,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.34),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -80,
            bottom: -140,
            child: IgnorePointer(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _apiUnavailable
                      ? _ApiUnavailableCard(onRetry: _initialize)
                      : FrostedPanel(
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                          borderRadius: BorderRadius.circular(36),
                          backgroundColor: const Color(0xA10A1220),
                          borderColor: Colors.white.withValues(alpha: 0.10),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xE60B1320),
                              Color(0xCC0F1D35),
                              Color(0xB3163058),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 132,
                                height: 132,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(36),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.16),
                                      Colors.white.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.14),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.18),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: const MovaroLogo(
                                  markSize: 74,
                                  showWordmark: false,
                                  markColor: Color(0xFFF7FAFF),
                                ),
                              ),
                              const SizedBox(height: 26),
                              const MovaroLogo(
                                markSize: 22,
                                textColor: Color(0xFFF7FAFF),
                                markColor: Color(0xFFF7FAFF),
                                spacing: 14,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.splashHeroTitle,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.8,
                                      height: 1.05,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.splashHeroBody,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.76),
                                      height: 1.4,
                                    ),
                              ),
                              const SizedBox(height: 28),
                              if (_isCheckingApi) const _SplashProgress(),
                              if (_isCheckingApi) const SizedBox(height: 14),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.08),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.splashInitializingLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.72,
                                            ),
                                            letterSpacing: 0.2,
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.north_east_rounded,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.68)
                                        : AppColors.textPrimary.withValues(
                                            alpha: 0.6,
                                          ),
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 8,
            color: Colors.white.withValues(alpha: 0.10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.18, end: 0.82),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.88),
                            const Color(0xFF92C7FF),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ApiUnavailableCard extends StatelessWidget {
  const _ApiUnavailableCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FrostedPanel(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      borderRadius: BorderRadius.circular(36),
      backgroundColor: const Color(0xB30A1220),
      borderColor: Colors.white.withValues(alpha: 0.10),
      gradient: const LinearGradient(
        colors: [Color(0xE60A1220), Color(0xCC10203A), Color(0xB315335B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MovaroLogo(
            markSize: 20,
            textColor: Colors.white,
            markColor: Colors.white,
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 180,
              height: 180,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    Colors.white.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: SvgPicture.asset('assets/illustrations/offline.svg'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.apiUnavailableTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              height: 1.0,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.apiUnavailableDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              l10n.apiUnavailableSupportingText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.apiUnavailableRetryAction),
            ),
          ),
        ],
      ),
    );
  }
}
