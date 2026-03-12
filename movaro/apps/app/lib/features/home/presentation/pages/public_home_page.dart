import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/language_selector_button.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/catalog/domain/entities/catalog_country.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/journey/journey_country_metadata.dart';
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
  Future<void> _restartJourneyFlow() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _JourneyResetSheet(
        onConfirm: () => Navigator.of(sheetContext).pop(true),
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await widget.journeyContextController.clearJourney();
    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.journeySetup);
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.isDesktopLayout ? 1160.0 : 920.0;

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
                    context.pageVerticalPadding + 24,
                  ),
                  children: [
                    _LandingHero(
                      journeyContextController: widget.journeyContextController,
                      citiesController: widget.citiesController,
                      migrationQuestionnaireController:
                          widget.migrationQuestionnaireController,
                      onRestartJourney: _restartJourneyFlow,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigationBar(
        currentIndex: 0,
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
    required this.onRestartJourney,
  });

  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final Future<void> Function() onRestartJourney;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final stacked = width < 920;
    final origin = journeyContextController.selectedOrigin;
    final destination = journeyContextController.selectedDestination;

    final primary = _PrimaryIntroBlock(
      origin: origin,
      destination: destination,
      title: l10n.publicHomeFirstStepTitle,
      body: origin != null && destination != null
          ? l10n.publicHomeSelectedJourneyDescription(
              origin.name,
              destination.name,
            )
          : l10n.publicHomeFirstStepBody,
      onRestartJourney: onRestartJourney,
    );

    final actions = _ActionStage(
      migrationQuestionnaireController: migrationQuestionnaireController,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FrostedPanel(
          padding: EdgeInsets.all(stacked ? 22 : 26),
          backgroundColor: const Color(0xB30B1320),
          borderColor: Colors.white.withValues(alpha: 0.12),
          gradient: const LinearGradient(
            colors: [
              AppColors.heroStart,
              AppColors.heroMiddle,
              AppColors.heroEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [primary, const SizedBox(height: 18), actions],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: primary),
                    const SizedBox(width: 22),
                    Expanded(flex: 12, child: actions),
                  ],
                ),
        ),
      ],
    );
  }
}

class _PrimaryIntroBlock extends StatelessWidget {
  const _PrimaryIntroBlock({
    required this.origin,
    required this.destination,
    required this.title,
    required this.body,
    required this.onRestartJourney,
  });

  final CatalogCountry? origin;
  final CatalogCountry? destination;
  final String title;
  final String body;
  final Future<void> Function() onRestartJourney;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoutePlate(
          originEmoji: origin?.flagEmoji ?? '🇦🇷',
          originName: origin?.name ?? 'Argentina',
          destinationEmoji: destination?.flagEmoji ?? '🇧🇷',
          destinationName: destination?.name ?? 'Brasil',
          onRestartJourney: onRestartJourney,
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style:
              (compact
                      ? Theme.of(context).textTheme.headlineMedium
                      : Theme.of(context).textTheme.displaySmall)
                  ?.copyWith(
                    color: Colors.white,
                    letterSpacing: compact ? -0.6 : -1.0,
                    height: 0.96,
                    fontWeight: FontWeight.w700,
                  ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionStage extends StatelessWidget {
  const _ActionStage({required this.migrationQuestionnaireController});

  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final plan = migrationQuestionnaireController.generatedPlan;
    final leadCity = plan?.recommendedCity;
    final hasPlan = plan != null;
    final planTitle = hasPlan
        ? l10n.publicHomeResumePlanTitle
        : l10n.publicHomePlanTitle;
    final planDescription = hasPlan
        ? leadCity != null
              ? l10n.publicHomeResumePlanBodyWithCity(
                  leadCity.name,
                  leadCity.stateCode,
                )
              : l10n.publicHomeResumePlanBody
        : l10n.publicHomePlanBody;
    final planAction = hasPlan
        ? l10n.publicHomeResumePlanAction
        : l10n.publicHomeQuestionnaireAction;
    final planStatus = hasPlan && leadCity != null
        ? '${leadCity.name} (${leadCity.stateCode})'
        : null;

    final planCard = _VisualActionCard(
      title: planTitle,
      description: planDescription,
      actionLabel: planAction,
      statusLine: planStatus,
      onTap: () => Navigator.pushNamed(
        context,
        hasPlan
            ? AppRoutes.migrationPlanResult
            : AppRoutes.migrationQuestionnaire,
      ),
      isPrimary: true,
      compact: width < 920,
      scene: const _PlanScene(),
      icon: hasPlan ? Icons.playlist_play_rounded : Icons.edit_note_rounded,
      accent: AppColors.primary,
    );

    final citiesCard = _VisualActionCard(
      title: l10n.publicHomeCitiesTitle,
      description: l10n.publicHomeCitiesBody,
      actionLabel: l10n.publicHomeCitiesAction,
      onTap: () => Navigator.pushNamed(context, AppRoutes.cities),
      scene: const _CitiesScene(),
      compact: true,
      subdued: true,
      icon: Icons.location_city_rounded,
      accent: const Color(0xFF35A8FF),
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
      compact: true,
      subdued: true,
      icon: Icons.folder_open_rounded,
      accent: const Color(0xFF4DC2A8),
    );

    if (width >= 920) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 8, child: planCard),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                citiesCard,
                const SizedBox(height: 12),
                questionsCard,
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        planCard,
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: citiesCard),
            const SizedBox(width: 12),
            Expanded(child: questionsCard),
          ],
        ),
      ],
    );
  }
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
    this.statusLine,
    this.isPrimary = false,
    this.compact = false,
    this.subdued = false,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;
  final Widget scene;
  final IconData icon;
  final Color accent;
  final String? statusLine;
  final bool isPrimary;
  final bool compact;
  final bool subdued;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final textSoft = AppColors.textSoftFor(context);
    final borderColor = AppColors.borderFor(context);
    final cardGradient = isPrimary
        ? LinearGradient(
            colors: isDark
                ? [
                    AppColors.surfaceElevatedFor(context),
                    AppColors.surfaceMutedFor(context),
                  ]
                : const [Color(0xFFF9FBFF), Color(0xFFEAF3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: isDark
                ? [
                    AppColors.surfaceFor(context),
                    AppColors.surfaceMutedFor(context),
                  ]
                : const [Color(0xFFFFFFFF), Color(0xFFF4F7FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final fixedHeight = isPrimary
        ? (compact ? 174.0 : 188.0)
        : 154.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? borderColor
                  : Colors.white.withValues(alpha: isPrimary ? 0.48 : 0.28),
            ),
            boxShadow: subdued
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.black : AppColors.primary)
                          .withValues(alpha: isDark ? 0.12 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : AppColors.frostedShadowFor(context),
          ),
          child: SizedBox(
            height: fixedHeight,
            child: Stack(
              children: [
                Positioned(
                  top: compact ? 14 : 16,
                  right: compact ? 12 : 16,
                  width: isPrimary
                      ? (compact ? 74 : 96)
                      : 68,
                  height: isPrimary
                      ? (compact ? 54 : 66)
                      : 50,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: subdued ? 0.82 : 0.94,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: scene,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: Container(
                    width: compact ? 38 : 44,
                    height: compact ? 38 : 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(
                        alpha: isDark ? 0.20 : (subdued ? 0.09 : 0.12),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: accent, size: compact ? 20 : 22),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 16 : 18,
                    compact ? 16 : 18,
                    compact ? 16 : 18,
                    compact ? 14 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.22 : 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          actionLabel,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      const Spacer(),
                      if (statusLine != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: isDark ? 0.14 : 0.08,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            statusLine!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimaryFor(context),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: compact ? 210 : (isPrimary ? 280 : 220),
                        child: Text(
                          title,
                          maxLines: compact ? 2 : 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              (compact
                                      ? Theme.of(context).textTheme.titleMedium
                                      : (isPrimary
                                            ? Theme.of(
                                                context,
                                              ).textTheme.titleLarge
                                            : Theme.of(
                                                context,
                                              ).textTheme.titleMedium))
                                  ?.copyWith(
                                    color: textPrimary,
                                    height: 1.05,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: compact ? 240 : (isPrimary ? 330 : 230),
                        child: Text(
                          description,
                          maxLines: compact ? 2 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: textSoft, height: 1.28),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            actionLabel,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: isPrimary ? AppColors.primary : accent,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_outward_rounded,
                            size: compact ? 18 : 20,
                            color: isPrimary ? AppColors.primary : accent,
                          ),
                        ],
                      ),
                    ],
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

class _RoutePlate extends StatelessWidget {
  const _RoutePlate({
    required this.originEmoji,
    required this.originName,
    required this.destinationEmoji,
    required this.destinationName,
    required this.onRestartJourney,
  });

  final String originEmoji;
  final String originName;
  final String destinationEmoji;
  final String destinationName;
  final Future<void> Function() onRestartJourney;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (compact) ...[
                _RouteJourneyRow(
                  originEmoji: originEmoji,
                  originName: originName,
                  destinationEmoji: destinationEmoji,
                  destinationName: destinationName,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _RouteActionPill(
                      icon: Icons.swap_horiz_rounded,
                      label: context.l10n.publicHomeJourneyResetAction,
                      onTap: onRestartJourney,
                      compact: true,
                    ),
                    const LanguageSelectorButton(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0x1AFFFFFF),
                    ),
                  ],
                ),
              ] else
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _RouteJourneyRow(
                      originEmoji: originEmoji,
                      originName: originName,
                      destinationEmoji: destinationEmoji,
                      destinationName: destinationName,
                    ),
                    _RouteActionPill(
                      icon: Icons.swap_horiz_rounded,
                      label: context.l10n.publicHomeJourneyResetAction,
                      onTap: onRestartJourney,
                      compact: false,
                    ),
                    const LanguageSelectorButton(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0x1AFFFFFF),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RouteActionPill extends StatelessWidget {
  const _RouteActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              if (!compact) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteJourneyRow extends StatelessWidget {
  const _RouteJourneyRow({
    required this.originEmoji,
    required this.originName,
    required this.destinationEmoji,
    required this.destinationName,
  });

  final String originEmoji;
  final String originName;
  final String destinationEmoji;
  final String destinationName;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      runSpacing: 8,
      children: [
        _RouteNode(emoji: originEmoji, name: originName),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: Colors.white.withValues(alpha: 0.82),
          ),
        ),
        _RouteNode(emoji: destinationEmoji, name: destinationName),
      ],
    );
  }
}

class _JourneyResetSheet extends StatelessWidget {
  const _JourneyResetSheet({required this.onConfirm});

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
                l10n.publicHomeJourneyResetTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.publicHomeJourneyResetBody,
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
                      child: Text(l10n.publicHomeJourneyResetConfirm),
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

class _RouteNode extends StatelessWidget {
  const _RouteNode({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.88),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
