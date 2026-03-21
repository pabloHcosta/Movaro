import 'package:flutter/material.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_text_styles.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasActiveDestination =
        migrationQuestionnaireController.generatedPlan?.isCityConfirmed == true;
    final items = hasActiveDestination
        ? _activeItems(context)
        : _emptyItems(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey<bool>(hasActiveDestination),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xF707090E) : const Color(0xF7F8FAFC),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        padding: EdgeInsets.only(
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 6,
        ),
        child: SafeArea(
          top: false,
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
    );
  }

  List<_NavItemData> _emptyItems(BuildContext context) => [
    _NavItemData(
      slot: 0,
      label: _text(context, pt: 'Home', es: 'Home', en: 'Home'),
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavItemData(
      slot: 1,
      label: _text(context, pt: 'Explore', es: 'Explore', en: 'Explore'),
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    _NavItemData(
      slot: 4,
      label: _text(context, pt: 'Favoritas', es: 'Favoritas', en: 'Favorites'),
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
    ),
  ];

  List<_NavItemData> _activeItems(BuildContext context) => [
    _NavItemData(
      slot: 0,
      label: _text(context, pt: 'Home', es: 'Home', en: 'Home'),
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavItemData(
      slot: 1,
      label: _text(context, pt: 'Explore', es: 'Explore', en: 'Explore'),
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
      label: _text(context, pt: 'Info BR', es: 'Info BR', en: 'Info BR'),
      icon: Icons.info_outline,
      activeIcon: Icons.info,
    ),
    _NavItemData(
      slot: 4,
      label: _text(context, pt: 'Favoritas', es: 'Favoritas', en: 'Favorites'),
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
    ),
  ];

  void _handleTap(BuildContext context, int slot) {
    if (slot == currentIndex) {
      return;
    }

    final route = switch (slot) {
      0 => AppRoutes.publicHome,
      1 => AppRoutes.explore,
      2 => AppRoutes.migrationPlanCopilot,
      3 => AppRoutes.infoBrazil,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveBackground = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);
    final inactiveForeground = isDark
        ? Colors.white.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.30);
    final inactiveLabel = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.black.withValues(alpha: 0.25);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive)
                Container(
                  width: 46,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark
                        ? const Color(0x2E0284C7)
                        : const Color(0x1F0284C7),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x470EA5E9)
                          : const Color(0x590EA5E9),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(activeIcon, size: 13, color: Colors.white),
                    ),
                  ),
                )
              else
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: inactiveBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 17, color: inactiveForeground),
                ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.navLabel.copyWith(
                  color: isActive
                      ? (isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0369A1))
                      : inactiveLabel,
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
