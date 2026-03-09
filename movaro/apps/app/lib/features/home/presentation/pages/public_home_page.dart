import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/language_selector_button.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/core/widgets/movaro_logo.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class PublicHomePage extends StatelessWidget {
  const PublicHomePage({
    required this.journeyContextController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxWidth = context.isDesktopLayout ? 1180.0 : 920.0;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 28,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: LanguageSelectorButton(
                        backgroundColor: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _HomeHero(
                      l10n: l10n,
                      journeyContextController: journeyContextController,
                      migrationQuestionnaireController:
                          migrationQuestionnaireController,
                    ),
                    const SizedBox(height: 16),
                    _QuickTrustRow(
                      l10n: l10n,
                      journeyContextController: journeyContextController,
                    ),
                    const SizedBox(height: 24),
                    _FirstStepSection(l10n: l10n),
                    const SizedBox(height: 18),
                    _WhereToFindPanel(
                      l10n: l10n,
                      journeyContextController: journeyContextController,
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
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.l10n,
    required this.journeyContextController,
    required this.migrationQuestionnaireController,
  });

  final dynamic l10n;
  final JourneyContextController journeyContextController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 900;
    final origin = journeyContextController.selectedOrigin;
    final destination = journeyContextController.selectedDestination;
    final scopeLabel =
        origin != null && destination != null
        ? '${origin.flagEmoji} ${origin.name} -> ${destination.flagEmoji} ${destination.name}'
        : l10n.publicHomeScopeBadge;
    final heroDescription =
        origin != null && destination != null
        ? l10n.publicHomeSelectedJourneyDescription(
            origin.name,
            destination.name,
          )
        : l10n.publicHomeFocusedDescription;

    final primaryContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          borderRadius: BorderRadius.circular(999),
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          borderColor: Colors.white.withValues(alpha: 0.12),
          blurSigma: 10,
          boxShadow: const [],
          child: const MovaroLogo(
            markSize: 18,
            textColor: Colors.white,
            markColor: Colors.white,
            spacing: 8,
          ),
        ),
        const SizedBox(height: 20),
        _HeroBadge(label: scopeLabel),
        const SizedBox(height: 22),
        Text(
          l10n.publicHomeHeadline,
          style: (stacked
                  ? Theme.of(context).textTheme.displaySmall
                  : Theme.of(context).textTheme.displayLarge)
              ?.copyWith(
                color: Colors.white,
                letterSpacing: stacked ? -1.0 : -1.8,
                height: 0.98,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            heroDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.migrationQuestionnaire,
              ),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(l10n.publicHomeQuestionnaireAction),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.cities),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
              ),
              icon: const Icon(Icons.location_city_outlined),
              label: Text(l10n.publicHomeCitiesAction),
            ),
          ],
        ),
      ],
    );

    final sideNote = FrostedPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(28),
      backgroundColor: Colors.white.withValues(alpha: 0.09),
      borderColor: Colors.white.withValues(alpha: 0.12),
      blurSigma: 10,
      boxShadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '01',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.56),
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.publicHomePrimaryQuestionTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.publicHomePrimaryQuestionBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Column(
            children: [
              _HeroBullet(label: l10n.publicHomeQuestionnaireAction),
              const SizedBox(height: 10),
              _HeroBullet(label: l10n.publicHomeCitiesAction),
              const SizedBox(height: 10),
              _HeroBullet(label: l10n.publicHomeHowItWorksAction),
            ],
          ),
        ],
      ),
    );

    return FrostedPanel(
      padding: EdgeInsets.all(stacked ? 28 : 36),
      backgroundColor: const Color(0xB30B1320),
      borderColor: Colors.white.withValues(alpha: 0.12),
      gradient: const LinearGradient(
        colors: [AppColors.heroStart, AppColors.heroMiddle, AppColors.heroEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                primaryContent,
                const SizedBox(height: 20),
                sideNote,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: primaryContent),
                const SizedBox(width: 28),
                Expanded(flex: 3, child: sideNote),
              ],
            ),
    );
  }
}

class _QuickTrustRow extends StatelessWidget {
  const _QuickTrustRow({
    required this.l10n,
    required this.journeyContextController,
  });

  final dynamic l10n;
  final JourneyContextController journeyContextController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1080;
        final medium = constraints.maxWidth >= 720;
        final cardWidth = wide
            ? (constraints.maxWidth - 24) / 3
            : medium
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickTrustCard(
              width: cardWidth,
              icon: Icons.bolt_rounded,
              title: l10n.publicHomeTrustFastTitle,
              body: l10n.publicHomeTrustFastBody,
            ),
            _QuickTrustCard(
              width: cardWidth,
              icon: Icons.visibility_outlined,
              title: l10n.publicHomeTrustGuestTitle,
              body: l10n.publicHomeTrustGuestBody,
            ),
            _QuickTrustCard(
              width: cardWidth,
              icon: Icons.flag_outlined,
              title: l10n.publicHomeTrustFocusTitle,
              body: journeyContextController.hasSelectedJourney
                  ? l10n.publicHomeTrustSelectedBody(
                      journeyContextController.selectedOrigin?.name ?? '',
                      journeyContextController.selectedDestination?.name ?? '',
                    )
                  : l10n.publicHomeTrustFocusBody,
            ),
          ],
        );
      },
    );
  }
}

class _QuickTrustCard extends StatelessWidget {
  const _QuickTrustCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.body,
  });

  final double width;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.textPrimaryFor(context)),
    );

    return SizedBox(
      width: width,
      child: FrostedPanel(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconBox,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(height: 1.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FirstStepSection extends StatelessWidget {
  const _FirstStepSection({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.publicHomeFirstStepTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.publicHomeFirstStepBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1020;
              final medium = constraints.maxWidth >= 680;
              final cardWidth = wide
                  ? (constraints.maxWidth - 24) / 3
                  : medium
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _ActionCard(
                      title: l10n.publicHomePlanTitle,
                      description: l10n.publicHomePlanBody,
                      actionLabel: l10n.publicHomeQuestionnaireAction,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.migrationQuestionnaire,
                      ),
                      icon: Icons.route_outlined,
                      isPrimary: true,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _ActionCard(
                      title: l10n.publicHomeCitiesTitle,
                      description: l10n.publicHomeCitiesBody,
                      actionLabel: l10n.publicHomeCitiesAction,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.cities),
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _ActionCard(
                      title: l10n.exploreIntroTitle,
                      description: l10n.exploreIntroDescription,
                      actionLabel: l10n.publicHomeHowItWorksAction,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.intro),
                      icon: Icons.lightbulb_outline_rounded,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WhereToFindPanel extends StatelessWidget {
  const _WhereToFindPanel({
    required this.l10n,
    required this.journeyContextController,
  });

  final dynamic l10n;
  final JourneyContextController journeyContextController;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.publicHomeSecondaryTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            journeyContextController.destinationCountryId == 'brasil'
                ? l10n.publicHomeSecondaryBody
                : l10n.publicHomeSecondaryGenericBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SupportShortcut(
                label: l10n.documentationPathDocumentsTitle,
                icon: Icons.badge_outlined,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.documentationTopic,
                  arguments: DocumentationGuideSection.documents,
                ),
              ),
              _SupportShortcut(
                label: l10n.documentationPathHealthTitle,
                icon: Icons.health_and_safety_outlined,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.documentationTopic,
                  arguments: DocumentationGuideSection.health,
                ),
              ),
              _SupportShortcut(
                label: l10n.documentationNavigatorHousing,
                icon: Icons.home_work_outlined,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.documentationTopic,
                  arguments: DocumentationGuideSection.housing,
                ),
              ),
              _SupportShortcut(
                label: l10n.documentationPathWorkTitle,
                icon: Icons.work_outline_rounded,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.documentationTopic,
                  arguments: DocumentationGuideSection.work,
                ),
              ),
              _SupportShortcut(
                label: l10n.documentationPathDrivingTitle,
                icon: Icons.directions_car_outlined,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.documentationTopic,
                  arguments: DocumentationGuideSection.driving,
                ),
              ),
              _SupportShortcut(
                label: l10n.documentationPathCostsTitle,
                icon: Icons.wallet_outlined,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.documentationTopic,
                  arguments: DocumentationGuideSection.costs,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportShortcut extends StatelessWidget {
  const _SupportShortcut({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white.withValues(alpha: 0.88),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
    required this.icon,
    this.isPrimary = false,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;
  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final headerIcon = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(colors: [AppColors.primary, AppColors.accent])
            : null,
        color: isPrimary ? null : AppColors.surfaceMutedFor(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        icon,
        color: isPrimary ? Colors.white : AppColors.textPrimaryFor(context),
      ),
    );

    return FrostedPanel(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              headerIcon,
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(height: 1.1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          if (isPrimary)
            FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_outward_rounded),
              label: Text(actionLabel),
            )
          else
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_outward_rounded),
              label: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}

class _HeroBullet extends StatelessWidget {
  const _HeroBullet({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
        ),
      ],
    );
  }
}
