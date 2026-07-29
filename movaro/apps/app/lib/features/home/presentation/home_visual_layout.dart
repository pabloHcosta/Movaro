import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';

class HomeVisualLayout extends StatelessWidget {
  const HomeVisualLayout({
    required this.onDiscoverDirectionTap,
    required this.onKnownCityTap,
    required this.onExploreCitiesTap,
    required this.onOpenCostsTap,
    required this.onOpenDocumentsTap,
    required this.onOpenHousingTap,
    super.key,
  });

  final VoidCallback onDiscoverDirectionTap;
  final VoidCallback onKnownCityTap;
  final VoidCallback onExploreCitiesTap;
  final VoidCallback onOpenCostsTap;
  final VoidCallback onOpenDocumentsTap;
  final VoidCallback onOpenHousingTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 390;
            final horizontalPadding = isNarrow ? 14.0 : 18.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                14,
                horizontalPadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AppValueHeader(scheme: scheme),
                  const SizedBox(height: 20),
                  _buildTitle(context, scheme, isNarrow),
                  const SizedBox(height: 10),
                  _buildSubtitle(context, scheme),
                  const SizedBox(height: 14),
                  _buildSupportLine(context, scheme),
                  const SizedBox(height: 20),
                  _buildPrimaryPaths(context, scheme, isDark, isNarrow),
                  const SizedBox(height: 22),
                  _buildSecondaryLinks(context, scheme, isDark),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ColorScheme scheme, bool isNarrow) {
    final l10n = context.l10n;
    final baseStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontSize: isNarrow ? 29 : 32,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.9,
      height: 1.08,
      color: scheme.onSurface,
    );

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: l10n.homeEntryTitlePrefix),
          TextSpan(
            text: l10n.homeEntryTitleHighlight,
            style: TextStyle(color: scheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, ColorScheme scheme) {
    return Text(
      context.l10n.homeEntrySubtitle,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.68),
        height: 1.42,
      ),
    );
  }

  Widget _buildSupportLine(BuildContext context, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.schedule_rounded,
              size: 14,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              context.l10n.homeEntrySupportLine,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.78),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryPaths(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
    bool isNarrow,
  ) {
    final l10n = context.l10n;

    return Column(
      children: [
        _PathCard(
          icon: Icons.auto_awesome_rounded,
          title: l10n.homeEntryDiscoverTitle,
          body: l10n.homeEntryDiscoverBody,
          badge: l10n.homeEntryDiscoverBadge,
          buttonLabel: l10n.homeEntryDiscoverAction,
          isPrimary: true,
          scheme: scheme,
          isDark: isDark,
          isNarrow: isNarrow,
          onTap: onDiscoverDirectionTap,
        ),
        const SizedBox(height: 14),
        _PathCard(
          icon: Icons.location_city_rounded,
          title: l10n.homeEntryKnownCityTitle,
          body: l10n.homeEntryKnownCityBody,
          badge: l10n.homeEntryKnownCityBadge,
          buttonLabel: l10n.homeEntryKnownCityAction,
          isPrimary: false,
          scheme: scheme,
          isDark: isDark,
          isNarrow: isNarrow,
          onTap: onKnownCityTap,
        ),
      ],
    );
  }

  Widget _buildSecondaryLinks(
    BuildContext context,
    ColorScheme scheme,
    bool isDark,
  ) {
    final l10n = context.l10n;
    final items = [
      (
        Icons.explore_rounded,
        l10n.homeEntryExploreCitiesAction,
        onExploreCitiesTap,
        const Color(0xFF38BDF8),
      ),
      (
        Icons.account_balance_wallet_rounded,
        l10n.homeVisualCostsAction,
        onOpenCostsTap,
        const Color(0xFF34D399),
      ),
      (
        Icons.description_rounded,
        l10n.homeVisualDocumentsAction,
        onOpenDocumentsTap,
        const Color(0xFFA78BFA),
      ),
      (
        Icons.home_work_rounded,
        l10n.homeVisualHousingAction,
        onOpenHousingTap,
        const Color(0xFFF59E0B),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.bolt_rounded, size: 17, color: scheme.primary),
            ),
            const SizedBox(width: 9),
            Text(
              l10n.homeEntryShortcutsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ShortcutTile(
                icon: items[0].$1,
                label: items[0].$2,
                onTap: items[0].$3,
                accent: items[0].$4,
                scheme: scheme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ShortcutTile(
                icon: items[1].$1,
                label: items[1].$2,
                onTap: items[1].$3,
                accent: items[1].$4,
                scheme: scheme,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ShortcutTile(
                icon: items[2].$1,
                label: items[2].$2,
                onTap: items[2].$3,
                accent: items[2].$4,
                scheme: scheme,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ShortcutTile(
                icon: items[3].$1,
                label: items[3].$2,
                onTap: items[3].$3,
                accent: items[3].$4,
                scheme: scheme,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AppValueHeader extends StatelessWidget {
  const _AppValueHeader({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final headline = switch (locale) {
      'es' => 'Tu guía para mudarte a Brasil',
      'en' => 'Your guide to moving to Brazil',
      _ => 'Seu guia para se mudar para o Brasil',
    };
    final chips = switch (locale) {
      'es' => ['Ciudades reales', 'Documentos', 'Plan propio'],
      'en' => ['Real cities', 'Documents', 'My plan'],
      _ => ['Cidades reais', 'Documentos', 'Plano próprio'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.16),
                ),
              ),
              alignment: Alignment.center,
              child: const Text('🇧🇷', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                headline,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final chip in chips) _ValueChip(label: chip, scheme: scheme),
          ],
        ),
      ],
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.scheme});

  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.badge,
    required this.buttonLabel,
    required this.isPrimary,
    required this.scheme,
    required this.isDark,
    required this.isNarrow,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String badge;
  final String buttonLabel;
  final bool isPrimary;
  final ColorScheme scheme;
  final bool isDark;
  final bool isNarrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isPrimary ? Colors.white : scheme.onSurface;
    final borderRadius = BorderRadius.circular(26);
    final gradient = isPrimary
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF168BFF), Color(0xFF075FEA), Color(0xFF044BC4)],
            stops: [0, 0.58, 1],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF182130), Color(0xFF101722)]
                : const [Color(0xFFFFFFFF), Color(0xFFF0F5FC)],
          );

    return Semantics(
      button: true,
      label: buttonLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: borderRadius,
              border: Border.all(
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.12)
                    : scheme.outlineVariant.withValues(alpha: 0.50),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPrimary ? scheme.primary : Colors.black).withValues(
                    alpha: isPrimary
                        ? (isDark ? 0.30 : 0.18)
                        : (isDark ? 0.16 : 0.06),
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Stack(
                children: [
                  if (isPrimary) ...[
                    Positioned(
                      right: -38,
                      top: -44,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 42,
                      bottom: -74,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.07),
                            width: 22,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    Positioned(
                      left: 0,
                      top: 24,
                      bottom: 24,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(isNarrow ? 18 : 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isPrimary
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : scheme.primary.withValues(alpha: 0.11),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: isPrimary
                                      ? Colors.white.withValues(alpha: 0.16)
                                      : scheme.primary.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: isPrimary
                                    ? Colors.white
                                    : scheme.primary,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: foreground.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: foreground.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: Text(
                                    badge,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: foreground.withValues(
                                            alpha: 0.90,
                                          ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.35,
                                height: 1.12,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          body,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: foreground.withValues(
                                  alpha: isPrimary ? 0.86 : 0.68,
                                ),
                                height: 1.42,
                              ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                          decoration: BoxDecoration(
                            color: isPrimary
                                ? Colors.white
                                : scheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: isPrimary
                                ? null
                                : Border.all(
                                    color: scheme.primary.withValues(
                                      alpha: 0.16,
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  buttonLabel,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: isPrimary
                                            ? scheme.primary
                                            : foreground,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isPrimary
                                      ? scheme.primary.withValues(alpha: 0.10)
                                      : scheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPrimary
                                      ? Icons.arrow_forward_rounded
                                      : Icons.search_rounded,
                                  size: 18,
                                  color: isPrimary
                                      ? scheme.primary
                                      : scheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.accent,
    required this.scheme,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color accent;
  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF121A26)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accent.withValues(alpha: isDark ? 0.20 : 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 19, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
