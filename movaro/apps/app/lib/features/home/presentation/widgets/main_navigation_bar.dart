import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_text_styles.dart';
import 'package:movaro_app/features/journey/journey_context_controller.dart';
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
    final items = _items(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = AppColors.isDark(context);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding + 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xF20E1628)
                  : const Color(0xEFFFFFFF),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.24)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: isDark ? 24 : 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                for (final item in items)
                  Expanded(
                    child: _NavTab(
                      label: item.label,
                      icon: item.icon,
                      activeIcon: item.activeIcon,
                      isActive: currentIndex == item.slot,
                      isDark: isDark,
                      onTap: () => _handleTap(context, item.slot),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_NavItemData> _items(BuildContext context) {
    final hasPlan = migrationQuestionnaireController.generatedPlan != null;

    return [
      _NavItemData(
        slot: 0,
        label: context.l10n.mainNavHome,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      _NavItemData(
        slot: 1,
        label: context.l10n.mainNavDecision,
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
      ),
      if (hasPlan)
        _NavItemData(
          slot: 2,
          label: context.l10n.mainNavExecution,
          icon: Icons.route_outlined,
          activeIcon: Icons.route,
        ),
      _NavItemData(
        slot: 3,
        label: context.l10n.aiChatTitle,
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
      ),
      _NavItemData(
        slot: 4,
        label: context.l10n.favoritesPageTitle,
        icon: Icons.favorite_outline,
        activeIcon: Icons.favorite,
      ),
    ];
  }

  void _handleTap(BuildContext context, int slot) {
    if (slot == currentIndex) return;

    final plan = migrationQuestionnaireController.generatedPlan;
    if (slot == 2 && plan == null) {
      final locale = Localizations.localeOf(context).languageCode;
      final message = switch (locale) {
        'pt' => 'Crie seu plano para acessar sua rota',
        'es' => 'Crea tu plan para acceder a tu ruta',
        _ => 'Create your plan to access your route',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: switch (locale) {
              'pt' => 'Criar plano',
              'es' => 'Crear plan',
              _ => 'Create plan',
            },
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.migrationQuestionnaire,
            ),
          ),
        ),
      );
      return;
    }
    final hasConfirmedCity = plan?.isCityConfirmed == true;
    final route = switch (slot) {
      0 => AppRoutes.publicHome,
      1 => AppRoutes.explore,
      2 =>
        hasConfirmedCity
            ? AppRoutes.migrationPlanCopilot
            : (plan != null
                  ? AppRoutes.migrationResultReveal
                  : AppRoutes.migrationQuestionnaire),
      3 => AppRoutes.info,
      _ => AppRoutes.favorites,
    };

    Navigator.pushReplacementNamed(context, route);
  }
}

class _NavItemData {
  const _NavItemData({
    required this.slot,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final int slot;
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.4, 0, 0.2, 1),
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 10 : 6,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0088FF), Color(0xFF00BBFF)],
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF0088FF).withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppColors.textSoft.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                style: context.textStyles.navLabel.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? Colors.white
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.textSoft.withValues(alpha: 0.92)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
