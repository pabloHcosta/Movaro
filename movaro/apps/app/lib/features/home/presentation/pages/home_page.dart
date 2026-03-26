import 'package:flutter/material.dart';
import 'package:movaro_app/app/config/app_config.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/language_selector_button.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/environment/app_environment.dart';
import 'package:movaro_app/core/responsive/responsive_context.dart';
import 'package:movaro_app/core/utils/context_extensions.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';
import 'package:movaro_app/core/widgets/environment_badge.dart';
import 'package:movaro_app/core/widgets/frosted_panel.dart';
import 'package:movaro_app/features/auth/application/auth_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    required this.environment,
    required this.authController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final AppEnvironment environment;
  final AuthController authController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = AppColors.isDark(context);
    final surfaceMuted = AppColors.surfaceMutedFor(context);
    final textSoft = AppColors.textSoftFor(context);

    return Scaffold(
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                context.pageHorizontalPadding,
                context.pageVerticalPadding,
                context.pageHorizontalPadding,
                context.pageVerticalPadding + 20,
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const LanguageSelectorButton(),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        await authController.signOut();

                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.publicHome,
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(l10n.signOutAction),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FrostedPanel(
                  padding: const EdgeInsets.all(32),
                  gradient: LinearGradient(
                    colors: [
                      isDark
                          ? const Color(0xCC18202C)
                          : Colors.white.withValues(alpha: 0.86),
                      isDark
                          ? const Color(0xB3151B26)
                          : Colors.white.withValues(alpha: 0.72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 840;

                      final primaryContent = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceMuted,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.authenticatedHomeTitle,
                              style: context.textTheme.labelLarge,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.authenticatedWelcome(
                              authController.session.displayName,
                            ),
                            style: stacked
                                ? context.textTheme.displaySmall
                                : context.textTheme.displayLarge,
                          ),
                          const SizedBox(height: 16),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Text(
                              l10n.authenticatedHomeDescription,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: textSoft,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.migrationStart,
                                ),
                                icon: const Icon(Icons.auto_awesome_rounded),
                                label: Text(l10n.startNewPlanAction),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.cities,
                                ),
                                icon: const Icon(Icons.travel_explore_rounded),
                                label: Text(l10n.authenticatedCitiesShortcut),
                              ),
                            ],
                          ),
                        ],
                      );
                      final secondaryContent = Column(
                        children: [
                          _InfoMetric(
                            title: l10n.authenticatedPlanSectionTitle,
                            value: l10n.savedPlansCount(
                              migrationQuestionnaireController
                                  .savedPlans
                                  .length,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _InfoMetric(
                            title: AppConfig.appTitle(environment),
                            child: EnvironmentBadge(
                              label: l10n.environmentValue(
                                environment.environmentName,
                              ),
                            ),
                          ),
                        ],
                      );

                      return stacked
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                primaryContent,
                                const SizedBox(height: 24),
                                secondaryContent,
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: primaryContent),
                                const SizedBox(width: 24),
                                Expanded(flex: 3, child: secondaryContent),
                              ],
                            );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                FrostedPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.authenticatedPlanSectionTitle,
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.onboardingSummary(
                          authController.session.originCountry ?? '-',
                          authController.session.destinationCountry ?? '-',
                        ),
                        style: context.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double cardWidth = constraints.maxWidth >= 900
                        ? (constraints.maxWidth - 12) / 2
                        : constraints.maxWidth;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _ShortcutPanel(
                            title: l10n.authenticatedCitiesShortcut,
                            description: l10n.publicHomeCitiesBody,
                            actionLabel: l10n.publicHomeCitiesAction,
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.cities),
                            icon: Icons.public_rounded,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _ShortcutPanel(
                            title: l10n.authenticatedSearchShortcut,
                            description: l10n.citiesSearchDescription,
                            actionLabel: l10n.citiesSearchTitle,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.citiesSearch,
                            ),
                            icon: Icons.search_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({required this.title, this.value, this.child});

  final String title;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.labelLarge?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 10),
          if (child != null)
            child!
          else
            Text(value ?? '', style: context.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ShortcutPanel extends StatelessWidget {
  const _ShortcutPanel({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
    required this.icon,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FrostedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(title, style: context.textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSoftFor(context),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_outward_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
