import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/home/presentation/widgets/main_navigation_bar.dart';
import 'package:movaro_app/features/explore/presentation/pages/documentation_guide_page.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class PublicHomePage extends StatefulWidget {
  const PublicHomePage({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  State<PublicHomePage> createState() => _PublicHomePageState();
}

class _PublicHomePageState extends State<PublicHomePage> {
  @override
  Widget build(BuildContext context) {
    final maxWidth = context.isDesktopLayout ? 1160.0 : 920.0;

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                widget.journeyContextController,
                widget.migrationQuestionnaireController,
              ]),
              builder: (context, _) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding,
                        context.pageHorizontalPadding,
                        context.pageVerticalPadding + 24,
                      ),
                      children: [
                        _LandingHero(
                          journeyContextController:
                              widget.journeyContextController,
                          citiesController: widget.citiesController,
                          migrationQuestionnaireController:
                              widget.migrationQuestionnaireController,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 0,
        journeyContextController: widget.journeyContextController,
        citiesController: widget.citiesController,
        migrationQuestionnaireController:
            widget.migrationQuestionnaireController,
      ),
    );
  }
}

class _LandingHero extends StatelessWidget {
  const _LandingHero({
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    return _ActionStage(
      journeyContextController: journeyContextController,
      migrationQuestionnaireController: migrationQuestionnaireController,
    );
  }
}

class _ActionStage extends StatelessWidget {
  const _ActionStage({
    required this.journeyContextController,
    required this.migrationQuestionnaireController,
  });

  final JourneyContextController journeyContextController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = migrationQuestionnaireController.generatedPlan;
    final leadCity = plan?.recommendedCity;
    final hasDestination = journeyContextController.hasDestinationSelected;
    final hasJourney = journeyContextController.isJourneyReadyForPlanning;
    final needsSupportedRoute =
        hasDestination &&
        !journeyContextController.canEnterQuestionnaire &&
        !journeyContextController.isJourneyReadyForPlanning;
    final hasPlan = hasJourney && plan != null;
    final selectedDestination = journeyContextController.selectedDestination;
    final routeCard = _VisualActionCard(
      title: !hasDestination
          ? l10n.journeySetupPageTitle
          : needsSupportedRoute
          ? l10n.journeyCoverageUnsupportedTitle
          : hasPlan
          ? l10n.publicHomeResumePlanTitle
          : l10n.publicHomePlanTitle,
      description: !hasDestination
          ? l10n.journeyEntryDestinationLabel
          : needsSupportedRoute
          ? (selectedDestination?.name ?? l10n.journeyCoverageUnsupported)
          : hasPlan
          ? (leadCity != null
                ? '${leadCity.name} • ${leadCity.stateCode}'
                : l10n.publicHomeResumePlanAction)
          : (selectedDestination?.name ?? l10n.journeyEntryStartAction),
      actionLabel: !hasDestination
          ? l10n.journeySetupPageTitle
          : needsSupportedRoute
          ? l10n.journeyCoverageChooseRouteAction
          : hasPlan
          ? l10n.publicHomeResumePlanAction
          : l10n.journeyEntryStartAction,
      statusLine: hasPlan && leadCity != null
          ? '${leadCity.name} (${leadCity.stateCode})'
          : selectedDestination?.name,
      onTap: () async {
        if (!hasDestination) {
          Navigator.pushNamed(context, AppRoutes.journeySetup);
          return;
        }

        await migrationQuestionnaireController.initialize();
        if (!context.mounted) {
          return;
        }

        Navigator.pushNamed(
          context,
          needsSupportedRoute
              ? AppRoutes.journeySetup
              : hasPlan
              ? AppRoutes.migrationPlanResult
              : AppRoutes.migrationQuestionnaire,
        );
      },
      scene: const _PlanScene(),
      icon: !hasDestination
          ? Icons.route_rounded
          : hasPlan
          ? Icons.playlist_play_rounded
          : Icons.edit_note_rounded,
      accent: AppColors.primary,
      highlights: [
        _CardHighlight(
          icon: Icons.place_rounded,
          label: hasDestination
              ? (selectedDestination?.name ?? l10n.journeySetupPageTitle)
              : l10n.journeyDestinationSectionTitle,
        ),
        _CardHighlight(
          icon: hasPlan ? Icons.check_circle_rounded : Icons.tune_rounded,
          label: hasPlan ? l10n.mainNavPlan : l10n.mainNavHome,
        ),
      ],
      secondaryActionLabel: hasPlan ? l10n.startNewPlanAction : null,
      onSecondaryTap: hasPlan
          ? () async {
              final confirmed = await showModalBottomSheet<bool>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (sheetContext) => _PlanResetSheet(
                  onConfirm: () => Navigator.of(sheetContext).pop(true),
                ),
              );

              if (confirmed != true || !context.mounted) {
                return;
              }

              await migrationQuestionnaireController.clearCurrentPlan();
              if (!context.mounted) {
                return;
              }

              Navigator.pushNamed(context, AppRoutes.migrationQuestionnaire);
            }
          : null,
    );

    final citiesCard = _VisualActionCard(
      title: l10n.publicHomeCitiesTitle,
      description: l10n.publicHomeCitiesBody,
      actionLabel: l10n.publicHomeCitiesAction,
      onTap: () => Navigator.pushNamed(context, AppRoutes.cities),
      scene: const _CitiesScene(),
      icon: Icons.location_city_rounded,
      accent: const Color(0xFF35A8FF),
      highlights: [
        _CardHighlight(
          icon: Icons.payments_outlined,
          label: l10n.cityDetailAffordabilityTitle,
        ),
        _CardHighlight(
          icon: Icons.work_outline_rounded,
          label: l10n.cityDetailWorkLabel,
        ),
      ],
    );

    final questionsCard = _VisualActionCard(
      title: l10n.publicHomeQuestionsTitle,
      description: l10n.publicHomeQuestionsBody,
      actionLabel: l10n.publicHomeQuestionsAction,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.documentationGuide,
        arguments: DocumentationGuideSection.documents,
      ),
      scene: const _QuestionsScene(),
      icon: Icons.folder_open_rounded,
      accent: const Color(0xFF4DC2A8),
      highlights: [
        _CardHighlight(
          icon: Icons.badge_outlined,
          label: l10n.documentationPathDocumentsTitle,
        ),
        _CardHighlight(
          icon: Icons.home_work_outlined,
          label: l10n.documentationHousingArrivalSectionTitle,
        ),
      ],
    );

    return _HomeCardGrid(
      primaryCard: routeCard,
      secondaryCards: [citiesCard, questionsCard],
    );
  }
}

class _HomeCardGrid extends StatelessWidget {
  const _HomeCardGrid({
    required this.primaryCard,
    required this.secondaryCards,
  });

  final Widget primaryCard;
  final List<Widget> secondaryCards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1080) {
          final width = (constraints.maxWidth - 24) / 3;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(width: width, child: primaryCard),
              for (final card in secondaryCards) SizedBox(width: width, child: card),
            ],
          );
        }

        if (constraints.maxWidth >= 720) {
          final width = (constraints.maxWidth - 12) / 2;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(width: constraints.maxWidth, child: primaryCard),
              for (final card in secondaryCards) SizedBox(width: width, child: card),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            primaryCard,
            for (final card in secondaryCards) ...[
              const SizedBox(height: 12),
              card,
            ],
          ],
        );
      },
    );
  }
}

class _CardHighlight {
  const _CardHighlight({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class _VisualActionCard extends StatelessWidget {
  const _VisualActionCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
    required this.scene,
    required this.icon,
    required this.accent,
    this.highlights = const [],
    this.statusLine,
    this.secondaryActionLabel,
    this.onSecondaryTap,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;
  final Widget scene;
  final IconData icon;
  final Color accent;
  final List<_CardHighlight> highlights;
  final String? statusLine;
  final String? secondaryActionLabel;
  final Future<void> Function()? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final borderColor = AppColors.borderFor(context);
    final cardGradient = LinearGradient(
      colors: isDark
          ? [
              AppColors.surfaceFor(context),
              AppColors.surfaceMutedFor(context),
            ]
          : const [Color(0xFFFFFFFF), Color(0xFFF4F7FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final hasSecondaryAction =
        secondaryActionLabel != null && onSecondaryTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isDark
                  ? borderColor
                  : Colors.white.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : accent).withValues(
                  alpha: isDark ? 0.14 : 0.08,
                ),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: hasSecondaryAction ? 228 : 208,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Opacity(
                      opacity: isDark ? 0.12 : 0.14,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 190,
                          child: scene,
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      margin: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.72 : 0.50),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        accent.withValues(
                                          alpha: isDark ? 0.24 : 0.16,
                                        ),
                                        accent.withValues(
                                          alpha: isDark ? 0.14 : 0.08,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: accent.withValues(
                                        alpha: isDark ? 0.22 : 0.12,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: accent,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: textPrimary,
                                              height: 1.05,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                            ),
                                      ),
                                      if (statusLine != null) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(
                                              alpha: isDark ? 0.10 : 0.06,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            statusLine!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: isDark
                                                      ? Colors.white
                                                      : AppColors.textPrimaryFor(
                                                          context,
                                                        ),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSoftFor(context),
                                    height: 1.25,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),

                            if (highlights.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final highlight in highlights.take(2))
                                    _CardHighlightChip(
                                      icon: highlight.icon,
                                      label: highlight.label,
                                      tint: accent,
                                    ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),

                            if (secondaryActionLabel != null &&
                                onSecondaryTap != null) ...[
                              _SecondaryInlineAction(
                                label: secondaryActionLabel!,
                                onTap: onSecondaryTap!,
                                isPrimary: false,
                                compact: false,
                              ),
                              const SizedBox(height: 12),
                            ],

                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    actionLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 20,
                                  color: accent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHighlightChip extends StatelessWidget {
  const _CardHighlightChip({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryFor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryInlineAction extends StatelessWidget {
  const _SecondaryInlineAction({
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.compact,
  });

  final String label;
  final Future<void> Function() onTap;
  final bool isPrimary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final tint = isPrimary ? AppColors.caution : AppColors.primary;

    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 11 : 12,
              vertical: compact ? 9 : 10,
            ),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: tint.withValues(alpha: isDark ? 0.22 : 0.14),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: compact ? 24 : 26,
                  height: compact ? 24 : 26,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: compact ? 14 : 15,
                    color: tint,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: tint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionsScene extends StatelessWidget {
  const _QuestionsScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 18,
          top: 18,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F76E6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -10,
          top: -8,
          child: Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Color(0xF2FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -12,
          bottom: -16,
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(220, 64),
                topRight: Radius.elliptical(240, 68),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 178,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 16,
                  top: 16,
                  child: Transform.rotate(
                    angle: -0.08,
                    child: _QuestionSheet(accent: const Color(0xFF2B7BE8)),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 10,
                  child: Transform.rotate(
                    angle: 0.08,
                    child: _QuestionSheet(accent: const Color(0xFF7E4DFF)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionSheet extends StatelessWidget {
  const _QuestionSheet({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.question_answer_rounded, size: 15, color: accent),
          ),
          const Spacer(),
          Container(
            width: 44,
            height: 8,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 30,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0x332B7BE8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanResetSheet extends StatelessWidget {
  const _PlanResetSheet({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FrostedPanel(
          padding: const EdgeInsets.all(20),
          backgroundColor: AppColors.isDark(context)
              ? const Color(0xF0141E2E)
              : Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.publicHomePlanResetTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.publicHomePlanResetBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.maybePop(context),
                      child: Text(l10n.backAction),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onConfirm,
                      child: Text(l10n.startNewPlanAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanScene extends StatelessWidget {
  const _PlanScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 18,
          top: 18,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F76E6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 26,
          top: 20,
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -12,
          bottom: -28,
          child: Container(
            width: 108,
            height: 108,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -18,
          top: -10,
          child: Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: Color(0xF2FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 44,
          bottom: 34,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xD9FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(240, 70),
                topRight: Radius.elliptical(220, 60),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 190,
            height: 108,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 8,
                  top: 30,
                  child: Transform.rotate(
                    angle: -0.10,
                    child: Container(
                      width: 102,
                      height: 66,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: CustomPaint(painter: const _ChecklistPainter()),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 8,
                  child: Transform.rotate(
                    angle: 0.08,
                    child: Container(
                      width: 74,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2B7BE8,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 16,
                              color: Color(0xFF2B7BE8),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 44,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0x332B7BE8),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 32,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0x332B7BE8),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CitiesScene extends StatelessWidget {
  const _CitiesScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 20,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF1F76E6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -12,
          top: -6,
          child: Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: Color(0xF2FFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -18,
          bottom: -24,
          child: Container(
            width: 102,
            height: 102,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(220, 64),
                topRight: Radius.elliptical(260, 74),
              ),
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: 190,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Positioned(
                  left: 10,
                  top: 24,
                  child: _MiniCityCard(
                    titleWidth: 44,
                    accent: Color(0xFF35C6F4),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: _MiniCityCard(
                    titleWidth: 52,
                    accent: Color(0xFF2B7BE8),
                  ),
                ),
                Positioned(bottom: 8, child: _LocationPinCard()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniCityCard extends StatelessWidget {
  const _MiniCityCard({required this.titleWidth, required this.accent});

  final double titleWidth;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Container(
              width: titleWidth,
              height: 8,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Spacer(),
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPinCard extends StatelessWidget {
  const _LocationPinCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.location_on_rounded,
          size: 34,
          color: Color(0xFF7E4DFF),
        ),
      ),
    );
  }
}

class _ChecklistPainter extends CustomPainter {
  const _ChecklistPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0x332B7BE8)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = const Color(0xFF2B7BE8);

    for (var i = 0; i < 3; i++) {
      final y = 14.0 + (i * 16.0);
      canvas.drawCircle(Offset(10, y), 3.5, dotPaint);
      canvas.drawLine(Offset(20, y), Offset(size.width - 12, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
