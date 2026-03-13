import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({
    required this.migrationQuestionnaireController,
    super.key,
  });

  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = AppColors.isDark(context);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding,
                    context.pageHorizontalPadding,
                    context.pageVerticalPadding + 20,
                  ),
                  children: [
                    AppGlassHeader(
                      title: l10n.explorePageTitle,
                      onBack: Navigator.canPop(context)
                          ? () => Navigator.maybePop(context)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    FrostedPanel(
                      padding: const EdgeInsets.all(32),
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [
                                AppColors.heroStart,
                                AppColors.heroMiddle,
                                AppColors.heroEnd,
                              ]
                            : const [
                                Color(0xFFF8FBFF),
                                Color(0xFFEAF3FF),
                                Color(0xFFD9EAFF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      backgroundColor: isDark
                          ? const Color(0xB30B1320)
                          : const Color(0xF5FFFFFF),
                      borderColor: isDark
                          ? const Color(0x1AFFFFFF)
                          : AppColors.primary.withValues(alpha: 0.10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.exploreTrailsEyebrow,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.82)
                                      : AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.exploreTrailsTitle,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimaryFor(context),
                                ),
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 680),
                            child: Text(
                              l10n.exploreTrailsBody,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.78)
                                        : AppColors.textSoftFor(context),
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
                        final wide = constraints.maxWidth >= 1020;
                        final medium = constraints.maxWidth >= 680;
                        final panelWidth = wide
                            ? (constraints.maxWidth - 24) / 3
                            : medium
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: panelWidth,
                              child: _TrailCard(
                                title: l10n.exploreTrailCitiesTitle,
                                description: l10n.exploreTrailCitiesBody,
                                actionLabel: l10n.exploreCitiesAction,
                                icon: Icons.location_city_outlined,
                                isPrimary: true,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.cities,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: panelWidth,
                              child: _TrailCard(
                                title: l10n.exploreTrailDocsTitle,
                                description: l10n.exploreTrailDocsBody,
                                actionLabel: l10n.exploreDocumentationAction,
                                icon: Icons.description_outlined,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.documentationGuide,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: panelWidth,
                              child: _TrailCard(
                                title: l10n.exploreTrailPrepTitle,
                                description: migrationQuestionnaireController
                                            .generatedPlan
                                            ?.isCityConfirmed ==
                                        true
                                    ? l10n.exploreTrailPrepBodyReady
                                    : l10n.exploreTrailPrepBodyStart,
                                actionLabel: migrationQuestionnaireController
                                            .generatedPlan
                                            ?.isCityConfirmed ==
                                        true
                                    ? l10n.migrationPlanCopilotAction
                                    : l10n.exploreQuestionnaireAction,
                                icon: Icons.checklist_rounded,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  migrationQuestionnaireController
                                              .generatedPlan
                                              ?.isCityConfirmed ==
                                          true
                                      ? AppRoutes.migrationPlanCopilot
                                      : AppRoutes.migrationQuestionnaire,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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

class _TrailCard extends StatelessWidget {
  const _TrailCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String title;
  final String description;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final textPrimary = AppColors.textPrimaryFor(context);
    final cardBackground = isPrimary
        ? AppColors.tintedSurfaceFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFF4F8FF),
          )
        : AppColors.surfaceFor(context);
    final cardBorder = isPrimary
        ? AppColors.tintedBorderFor(
            context,
            tint: AppColors.primary,
            lightColor: const Color(0xFFD3E6FF),
          )
        : AppColors.borderFor(context);
    final iconBox = Container(
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
        color: isPrimary ? Colors.white : textPrimary,
      ),
    );

    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(28),
      backgroundColor: cardBackground,
      borderColor: cardBorder,
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : AppColors.primary).withValues(
            alpha: isDark ? 0.12 : 0.05,
          ),
          blurRadius: isPrimary ? 24 : 18,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconBox,
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onTap,
            icon: Icon(icon),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
