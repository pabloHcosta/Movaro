import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/migration_questionnaire/application/migration_questionnaire_controller.dart';

class MainNavigationBar extends StatelessWidget {
  const MainNavigationBar({
    required this.currentIndex,
    required this.journeyContextController,
    required this.citiesController,
    required this.migrationQuestionnaireController,
    super.key,
  });

  final int currentIndex;
  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        journeyContextController,
        citiesController,
        migrationQuestionnaireController,
      ]),
      builder: (context, _) {
        final isDark = AppColors.isDark(context);
        final items = _buildItems(context);

        return SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xF0161D29), Color(0xF00C1320)]
                        : const [Color(0xF9FFFFFF), Color(0xF1F3F9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.78),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : AppColors.primary)
                          .withValues(alpha: isDark ? 0.24 : 0.10),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                  child: Row(
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        Expanded(
                          child: _NavItem(
                            label: items[index].label,
                            icon: items[index].icon,
                            isSelected: currentIndex == items[index].slot,
                            isEnabled: true,
                            onTap: () =>
                                _handleTap(context, slot: items[index].slot),
                          ),
                        ),
                        if (index != items.length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<_NavDestination> _buildItems(BuildContext context) {
    return [
      _NavDestination(
        slot: 0,
        label: context.l10n.mainNavHome,
        icon: Icons.home_rounded,
      ),
      _NavDestination(
        slot: 1,
        label: context.l10n.mainNavExplore,
        icon: Icons.travel_explore_rounded,
      ),
      if (_hasDetailedPlan)
        _NavDestination(
          slot: 2,
          label: context.l10n.mainNavPlan,
          icon: Icons.checklist_rounded,
        ),
      _NavDestination(
        slot: 3,
        label: context.l10n.mainNavFavorites,
        icon: Icons.favorite_rounded,
      ),
    ];
  }

  bool get _hasDetailedPlan =>
      migrationQuestionnaireController.generatedPlan?.isCityConfirmed == true;

  void _handleTap(BuildContext context, {required int slot}) {
    final targetRoute = switch (slot) {
      0 => AppRoutes.publicHome,
      1 => AppRoutes.explore,
      2 => _resolvePlanRoute(),
      _ => AppRoutes.favorites,
    };

    if (slot == currentIndex) {
      return;
    }

    if (slot == 2 && targetRoute == AppRoutes.publicHome) {
      _showFeedback(context, context.l10n.mainNavPlanNeedsJourney);
    }

    Navigator.pushReplacementNamed(context, targetRoute);
  }

  String _resolvePlanRoute() {
    final plan = migrationQuestionnaireController.generatedPlan;
    if (plan?.isCityConfirmed == true) {
      return AppRoutes.migrationPlanCopilot;
    }
    if (plan != null) {
      return AppRoutes.migrationPlanResult;
    }
    return AppRoutes.migrationQuestionnaire;
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.slot,
    required this.label,
    required this.icon,
  });

  final int slot;
  final String label;
  final IconData icon;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final baseForeground = isSelected
        ? AppColors.primary
        : isEnabled
        ? AppColors.textSoftFor(context)
        : AppColors.textSoftFor(context).withValues(alpha: 0.50);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF10233E), Color(0xFF0A5DC0)]
                        : const [Color(0xFFEAF4FF), Color(0xFFDCEEFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.44),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.14)
                        : AppColors.primary.withValues(alpha: 0.16))
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.primary.withValues(alpha: 0.05)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.10))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: baseForeground, size: 21),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: baseForeground,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
