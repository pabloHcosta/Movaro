import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/router/app_routes.dart';
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
    final hasActiveDestination =
        migrationQuestionnaireController.generatedPlan?.isCityConfirmed == true;
    final items = hasActiveDestination
        ? _activeItems(context)
        : _emptyItems(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey<bool>(hasActiveDestination),
        color: Colors.transparent,
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding + 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xF20E1628),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
                        onTap: () => _handleTap(context, item.slot),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_NavItemData> _emptyItems(BuildContext context) => [
    _NavItemData(
      slot: 0,
      label: _text(context, pt: 'Home', es: 'Inicio', en: 'Home'),
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavItemData(
      slot: 1,
      label: _text(context, pt: 'Explorar', es: 'Explorar', en: 'Explore'),
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    _NavItemData(
      slot: 4,
      label: _text(context, pt: 'Favoritos', es: 'Favoritos', en: 'Favorites'),
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
    ),
  ];

  List<_NavItemData> _activeItems(BuildContext context) => [
    _NavItemData(
      slot: 0,
      label: _text(context, pt: 'Home', es: 'Inicio', en: 'Home'),
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavItemData(
      slot: 1,
      label: _text(context, pt: 'Explorar', es: 'Explorar', en: 'Explore'),
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    _NavItemData(
      slot: 2,
      label: _text(context, pt: 'Guia', es: 'Guía', en: 'Guide'),
      icon: Icons.route_outlined,
      activeIcon: Icons.route,
    ),
    _NavItemData(
      slot: 3,
      label: _text(context, pt: 'Assistente', es: 'Asistente', en: 'Assistant'),
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
    ),
    _NavItemData(
      slot: 4,
      label: _text(context, pt: 'Favoritos', es: 'Favoritos', en: 'Favorites'),
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
    ),
  ];

  void _handleTap(BuildContext context, int slot) {
    if (slot == currentIndex) return;

    final route = switch (slot) {
      0 => AppRoutes.publicHome,
      1 => AppRoutes.explore,
      2 => AppRoutes.migrationPlanCopilot,
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
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withValues(alpha: 0.08),
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
                    : Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                style: context.textStyles.navLabel.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _text(
  BuildContext context, {
  required String pt,
  required String es,
  required String en,
}) {
  return switch (Localizations.localeOf(context).languageCode) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
}
