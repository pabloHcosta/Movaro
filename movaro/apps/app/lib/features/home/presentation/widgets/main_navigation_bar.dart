import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.reselectNavigatesToRoot = false,
    super.key,
  });

  final int currentIndex;
  final JourneyContextController journeyContextController;
  final CitiesController citiesController;
  final MigrationQuestionnaireController migrationQuestionnaireController;
  final bool reselectNavigatesToRoot;

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = AppColors.isDark(context);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(14, 6, 14, bottomPadding + 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xE60B1322) : const Color(0xE8FFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.75),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.34)
                      : const Color(0xFF24415F).withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
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
      _NavItemData(
        slot: 2,
        label: _navText(context, pt: 'Plano', es: 'Plan', en: 'Plan'),
        icon: Icons.route_outlined,
        activeIcon: Icons.route,
      ),
      _NavItemData(
        slot: 3,
        label: _navText(context, pt: 'Ajuda', es: 'Ayuda', en: 'Help'),
        icon: Icons.help_center_outlined,
        activeIcon: Icons.help_center_rounded,
      ),
      _NavItemData(
        slot: 4,
        label: _navText(context, pt: 'Mais', es: 'Más', en: 'More'),
        icon: Icons.more_horiz_rounded,
        activeIcon: Icons.more_horiz_rounded,
      ),
    ];
  }

  void _handleTap(BuildContext context, int slot) {
    if (slot == currentIndex && !reselectNavigatesToRoot) return;

    final route = switch (slot) {
      0 => AppRoutes.publicHome,
      1 => AppRoutes.explore,
      2 => AppRoutes.plan,
      3 => AppRoutes.tools,
      _ => AppRoutes.more,
    };

    if (reselectNavigatesToRoot) {
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
      return;
    }
    Navigator.pushReplacementNamed(context, route);
  }
}

String _navText(
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
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(16),
            splashColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: const Cubic(0.4, 0, 0.2, 1),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? const [Color(0x2E168BFF), Color(0x1814B8FF)]
                            : const [Color(0x18168BFF), Color(0x0D14B8FF)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: isActive
                    ? Border.all(
                        color: const Color(0xFF1B9CFF).withValues(alpha: 0.25),
                      )
                    : null,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFF0088FF,
                          ).withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: 30,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF139DFF).withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      size: 20,
                      color: isActive
                          ? const Color(0xFF32B5FF)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.42)
                                : AppColors.textSoft.withValues(alpha: 0.85)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.textStyles.navLabel.copyWith(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? (isDark
                                ? Colors.white.withValues(alpha: 0.92)
                                : const Color(0xFF0F4C81))
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.42)
                                : AppColors.textSoft.withValues(alpha: 0.92)),
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
}
