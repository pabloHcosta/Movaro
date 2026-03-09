import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/movaro_logo.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({
    required this.journeyContextController,
    this.isFirstLaunch = false,
    super.key,
  });

  final bool isFirstLaunch;
  final JourneyContextController journeyContextController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCompact = MediaQuery.sizeOf(context).width < 720;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(
          context.pageHorizontalPadding,
          0,
          context.pageHorizontalPadding,
          context.pageVerticalPadding,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: _IntroBottomBar(
            isFirstLaunch: isFirstLaunch,
            supportLabel: l10n.introBottomSupportLabel,
            primaryLabel: l10n.introPrimaryAction,
            skipLabel: l10n.introSkipAction,
            onPrimaryPressed: () => _finish(context),
            onSkipPressed: isFirstLaunch ? () => _finish(context) : null,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 132,
                  ),
                  children: [
                    AppGlassHeader(
                      title: l10n.introPageTitle,
                      onBack: isFirstLaunch && !Navigator.canPop(context)
                          ? null
                          : () => Navigator.maybePop(context),
                    ),
                    const SizedBox(height: 20),
                    FrostedPanel(
                      padding: EdgeInsets.all(isCompact ? 24 : 32),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.heroStart,
                          AppColors.heroMiddle,
                          AppColors.heroEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      backgroundColor: const Color(0xB30B1320),
                      borderColor: const Color(0x1AFFFFFF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MovaroLogo(
                            markSize: 18,
                            textColor: Colors.white,
                            markColor: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.introHeroTitle,
                            style: (isCompact
                                    ? Theme.of(context).textTheme.headlineLarge
                                    : Theme.of(context).textTheme.displaySmall)
                                ?.copyWith(
                                  color: Colors.white,
                                  height: 0.98,
                                  letterSpacing: -0.9,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isCompact ? 560 : 680,
                            ),
                            child: Text(
                              l10n.introHeroDescription,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.82),
                                    height: 1.45,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 900;
                        final cardWidth = wide
                            ? (constraints.maxWidth - 24) / 3
                            : constraints.maxWidth;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _IntroCard(
                                step: '01',
                                icon: Icons.location_city_outlined,
                                title: l10n.introExploreTitle,
                                description: l10n.introExploreDescription,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _IntroCard(
                                step: '02',
                                icon: Icons.route_outlined,
                                title: l10n.introPlanTitle,
                                description: l10n.introPlanDescription,
                              ),
                            ),
                            SizedBox(
                              width: cardWidth,
                              child: _IntroCard(
                                step: '03',
                                icon: Icons.description_outlined,
                                title: l10n.introDocumentationTitle,
                                description: l10n.introDocumentationDescription,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FrostedPanel(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.introBetaTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.introBetaDescription,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textSoftFor(context),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finish(BuildContext context) async {
    await journeyContextController.markIntroSeen();

    if (!context.mounted) {
      return;
    }

    if (isFirstLaunch) {
      Navigator.pushReplacementNamed(context, AppRoutes.journeySetup);
      return;
    }

    Navigator.maybePop(context);
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String step;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedFor(context),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  step,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMutedFor(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroBottomBar extends StatelessWidget {
  const _IntroBottomBar({
    required this.isFirstLaunch,
    required this.supportLabel,
    required this.primaryLabel,
    required this.skipLabel,
    required this.onPrimaryPressed,
    required this.onSkipPressed,
  });

  final bool isFirstLaunch;
  final String supportLabel;
  final String primaryLabel;
  final String skipLabel;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSkipPressed;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 720;

    return FrostedPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(28),
      backgroundColor: const Color(0xD10A1220),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: isCompact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: onPrimaryPressed,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(primaryLabel),
                ),
                if (isFirstLaunch) ...[
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: onSkipPressed,
                    child: Text(skipLabel),
                  ),
                ],
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    supportLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
                if (isFirstLaunch)
                  TextButton(
                    onPressed: onSkipPressed,
                    child: Text(skipLabel),
                  ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: onPrimaryPressed,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(primaryLabel),
                ),
              ],
            ),
    );
  }
}
