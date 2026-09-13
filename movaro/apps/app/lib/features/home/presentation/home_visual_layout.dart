import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mudavi_app/app/localization/app_localization.dart';

class HomeVisualLayout extends StatelessWidget {
  const HomeVisualLayout({
    required this.onDiscoverDirectionTap,
    required this.onKnownCityTap,
    required this.onOpenCostsTap,
    required this.onOpenDocumentsTap,
    required this.onOpenHousingTap,
    super.key,
  });

  final VoidCallback onDiscoverDirectionTap;
  final VoidCallback onKnownCityTap;
  final VoidCallback onOpenCostsTap;
  final VoidCallback onOpenDocumentsTap;
  final VoidCallback onOpenHousingTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: IgnorePointer(
              child: RepaintBoundary(child: _PremiumBackdrop(isDark: isDark)),
            ),
          ),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 390;
                final isShort = constraints.maxHeight < 700;
                final horizontalPadding = isNarrow ? 20.0 : 28.0;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    isShort ? 16 : 28,
                    horizontalPadding,
                    120,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BrandSignature(isDark: isDark, scheme: scheme),
                          SizedBox(height: isShort ? 24 : 36),
                          _HeroMessage(
                            scheme: scheme,
                            isNarrow: isNarrow,
                            isShort: isShort,
                          ),
                          SizedBox(height: isShort ? 24 : 36),
                          _PrimaryAction(
                            isDark: isDark,
                            onTap: onDiscoverDirectionTap,
                          ),
                          const SizedBox(height: 11),
                          _SecondaryAction(
                            scheme: scheme,
                            isDark: isDark,
                            onTap: onKnownCityTap,
                          ),
                          SizedBox(height: isShort ? 28 : 36),
                          _QuickActions(
                            scheme: scheme,
                            isDark: isDark,
                            compact: isShort || isNarrow,
                            onOpenCostsTap: onOpenCostsTap,
                            onOpenDocumentsTap: onOpenDocumentsTap,
                            onOpenHousingTap: onOpenHousingTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBackdrop extends StatelessWidget {
  const _PremiumBackdrop({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF070A10),
                      Color(0xFF0A111C),
                      Color(0xFF080B12),
                    ]
                  : const [
                      Color(0xFFF8FAFD),
                      Color(0xFFF0F6FF),
                      Color(0xFFF8FAFD),
                    ],
              stops: const [0, 0.52, 1],
            ),
          ),
        ),
        Positioned(
          top: -180,
          right: -150,
          child: _AmbientOrb(
            size: 430,
            color: const Color(0xFF168BFF),
            opacity: isDark ? 0.18 : 0.10,
          ),
        ),
        Positioned(
          top: 170,
          left: -210,
          child: _AmbientOrb(
            size: 380,
            color: const Color(0xFF6D5BFF),
            opacity: isDark ? 0.08 : 0.035,
          ),
        ),
        Positioned(
          bottom: -220,
          right: -170,
          child: _AmbientOrb(
            size: 410,
            color: const Color(0xFF35C6F4),
            opacity: isDark ? 0.08 : 0.07,
          ),
        ),
      ],
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.32),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.46, 1],
        ),
      ),
    );
  }
}

class _BrandSignature extends StatelessWidget {
  const _BrandSignature({required this.isDark, required this.scheme});

  final bool isDark;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF116DCA,
                ).withValues(alpha: isDark ? 0.16 : 0.10),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: SvgPicture.asset(
            isDark
                ? 'assets/brand/mudavi_mark_light.svg'
                : 'assets/brand/mudavi_mark_dark.svg',
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Mudavi',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.72),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _HeroMessage extends StatelessWidget {
  const _HeroMessage({
    required this.scheme,
    required this.isNarrow,
    required this.isShort,
  });

  final ColorScheme scheme;
  final bool isNarrow;
  final bool isShort;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            context.l10n.homeEntryTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: isShort ? 29 : (isNarrow ? 32 : 36),
              fontWeight: FontWeight.w700,
              letterSpacing: -1.25,
              height: 1.10,
              color: scheme.onSurface,
              shadows: scheme.brightness == Brightness.dark
                  ? [
                      Shadow(
                        color: const Color(0xFF168BFF).withValues(alpha: 0.16),
                        blurRadius: 24,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
        SizedBox(height: isShort ? 10 : 12),
        Text(
          context.l10n.homeEntrySubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.60),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final radius = BorderRadius.circular(26);
    return Semantics(
      key: const ValueKey('home-action-discover'),
      button: true,
      label: l10n.homeEntryDiscoverAction,
      hint: l10n.homeEntrySupportLine,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0878F5).withValues(
                  alpha: isDark ? 0.22 : 0.18,
                ),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: const Color(0xFF0878F5),
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF249FFF),
                    Color(0xFF0878F5),
                    Color(0xFF2856D8),
                  ],
                ),
              ),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        l10n.homeEntryDiscoverAction,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        l10n.homeEntrySupportLine,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.scheme,
    required this.isDark,
    required this.onTap,
  });

  final ColorScheme scheme;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(19);

    return ConstrainedBox(
      key: const ValueKey('home-action-known-city'),
      constraints: const BoxConstraints(minHeight: 60),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              borderRadius: borderRadius,
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.055)
                      : Colors.white.withValues(alpha: 0.72),
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.11)
                        : Colors.white,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.18 : 0.055,
                      ),
                      blurRadius: 22,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(
                          alpha: isDark ? 0.15 : 0.09,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_city_rounded,
                        size: 19,
                        color: isDark
                            ? const Color(0xFF6AB8FF)
                            : scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.homeEntryKnownCityAction,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: scheme.onSurface.withValues(alpha: 0.40),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.scheme,
    required this.isDark,
    required this.compact,
    required this.onOpenCostsTap,
    required this.onOpenDocumentsTap,
    required this.onOpenHousingTap,
  });

  final ColorScheme scheme;
  final bool isDark;
  final bool compact;
  final VoidCallback onOpenCostsTap;
  final VoidCallback onOpenDocumentsTap;
  final VoidCallback onOpenHousingTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (
        icon: Icons.account_balance_wallet_rounded,
        key: const ValueKey('home-shortcut-costs'),
        label: l10n.homeVisualCostsAction,
        onTap: onOpenCostsTap,
        accent: const Color(0xFF169B7A),
      ),
      (
        icon: Icons.description_rounded,
        key: const ValueKey('home-shortcut-documents'),
        label: l10n.homeVisualDocumentsAction,
        onTap: onOpenDocumentsTap,
        accent: const Color(0xFF8665D6),
      ),
      (
        icon: Icons.home_work_rounded,
        key: const ValueKey('home-shortcut-housing'),
        label: l10n.homeVisualHousingAction,
        onTap: onOpenHousingTap,
        accent: const Color(0xFFC58116),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.homeEntryShortcutsTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final width = stacked
                ? constraints.maxWidth
                : (constraints.maxWidth - 20) / 3;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final item in items)
                  SizedBox(
                    width: width,
                    child: _QuickActionTile(
                      icon: item.icon,
                      actionKey: item.key,
                      label: item.label,
                      onTap: item.onTap,
                      accent: item.accent,
                      scheme: scheme,
                      isDark: isDark,
                      compact: compact,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.actionKey,
    required this.label,
    required this.onTap,
    required this.accent,
    required this.scheme,
    required this.isDark,
    required this.compact,
  });

  final IconData icon;
  final Key actionKey;
  final String label;
  final VoidCallback onTap;
  final Color accent;
  final ColorScheme scheme;
  final bool isDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: actionKey,
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(18),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: compact ? 100 : 112),
              child: Ink(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.052)
                      : Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.09)
                        : Colors.white,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withValues(alpha: isDark ? 0.22 : 0.16),
                            accent.withValues(alpha: isDark ? 0.10 : 0.07),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: accent.withValues(alpha: isDark ? 0.18 : 0.13),
                        ),
                      ),
                      child: Icon(icon, size: 17, color: accent),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
