import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';

class HomeVisualLayout extends StatelessWidget {
  const HomeVisualLayout({
    required this.onDiscoverDirectionTap,
    required this.onKnownCityTap,
    required this.onExploreCitiesTap,
    required this.onOpenCostsTap,
    required this.onOpenDocumentsTap,
    super.key,
  });

  final VoidCallback onDiscoverDirectionTap;
  final VoidCallback onKnownCityTap;
  final VoidCallback onExploreCitiesTap;
  final VoidCallback onOpenCostsTap;
  final VoidCallback onOpenDocumentsTap;

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
            final isCompact =
                constraints.maxWidth < 540 || constraints.maxHeight < 760;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 16 : 20,
                isCompact ? 10 : 16,
                isCompact ? 16 : 20,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StageSummaryBanner(
                    stage: context.l10n.stageClarityTitle,
                    body: context.l10n.stageClarityBody,
                    action: context.l10n.stageClarityAction,
                    accent: scheme.primary,
                    compact: isCompact,
                  ),
                  SizedBox(height: isCompact ? 12 : 16),
                  _buildTitle(context, scheme, isCompact),
                  SizedBox(height: isCompact ? 8 : 10),
                  _buildSubtitle(context, scheme, isCompact),
                  SizedBox(height: isCompact ? 10 : 12),
                  _buildSupportLine(context, scheme),
                  SizedBox(height: isCompact ? 12 : 18),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _buildPrimaryPaths(
                            context,
                            scheme,
                            isDark,
                            isCompact,
                          ),
                        ),
                        SizedBox(height: isCompact ? 12 : 16),
                        _buildSecondaryLinks(context, scheme, isCompact),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ColorScheme scheme, bool isCompact) {
    final l10n = context.l10n;
    final baseStyle =
        (isCompact
                ? Theme.of(context).textTheme.headlineSmall
                : Theme.of(context).textTheme.headlineMedium)
            ?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
              color: scheme.onSurface,
            );

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
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

  Widget _buildSubtitle(
    BuildContext context,
    ColorScheme scheme,
    bool isCompact,
  ) {
    final l10n = context.l10n;
    return Text(
      l10n.homeEntrySubtitle,
      maxLines: isCompact ? 2 : 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface.withValues(alpha: 0.70),
        height: isCompact ? 1.35 : 1.45,
      ),
    );
  }

  Widget _buildSupportLine(BuildContext context, ColorScheme scheme) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: scheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.homeEntrySupportLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.70),
                height: 1.2,
                fontWeight: FontWeight.w600,
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
    bool isCompact,
  ) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: _PathCard(
            icon: Icons.auto_awesome_rounded,
            title: l10n.homeEntryDiscoverTitle,
            body: l10n.homeEntryDiscoverBody,
            badge: l10n.homeEntryDiscoverBadge,
            buttonLabel: l10n.homeEntryDiscoverAction,
            isPrimary: true,
            scheme: scheme,
            isDark: isDark,
            compact: isCompact,
            onTap: onDiscoverDirectionTap,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _PathCard(
            icon: Icons.location_city_outlined,
            title: l10n.homeEntryKnownCityTitle,
            body: l10n.homeEntryKnownCityBody,
            badge: l10n.homeEntryKnownCityBadge,
            buttonLabel: l10n.homeEntryKnownCityAction,
            isPrimary: false,
            scheme: scheme,
            isDark: isDark,
            compact: isCompact,
            onTap: onKnownCityTap,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryLinks(
    BuildContext context,
    ColorScheme scheme,
    bool isCompact,
  ) {
    final l10n = context.l10n;
    final items = [
      (
        Icons.explore_outlined,
        l10n.homeEntryExploreCitiesAction,
        onExploreCitiesTap,
      ),
      (Icons.attach_money_rounded, l10n.homeVisualCostsAction, onOpenCostsTap),
      (
        Icons.description_outlined,
        l10n.homeVisualDocumentsAction,
        onOpenDocumentsTap,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeEntryShortcutsTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface.withValues(alpha: 0.80),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                InkWell(
                  onTap: items[index].$3,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: isCompact ? 10 : 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          items[index].$1,
                          size: isCompact ? 16 : 17,
                          color: scheme.onSurface.withValues(alpha: 0.42),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            items[index].$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.68,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: scheme.onSurface.withValues(alpha: 0.22),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index != items.length - 1)
                  Divider(
                    height: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StageSummaryBanner extends StatelessWidget {
  const _StageSummaryBanner({
    required this.stage,
    required this.body,
    required this.action,
    required this.accent,
    required this.compact,
  });

  final String stage;
  final String body;
  final String action;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            body,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.78),
              height: 1.35,
            ),
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            action,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.58),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    required this.compact,
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
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, const Color(0xFF0066FF)],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerHighest,
              scheme.surfaceContainerHighest.withValues(alpha: 0.92),
            ],
          );
    final foreground = isPrimary ? Colors.white : scheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: background,
        borderRadius: BorderRadius.circular(22),
        border: isPrimary
            ? null
            : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: (isPrimary ? scheme.primary : Colors.black).withValues(
              alpha: isPrimary
                  ? (isDark ? 0.28 : 0.18)
                  : (isDark ? 0.10 : 0.05),
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 18),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: foreground.withValues(
                            alpha: isPrimary ? 0.12 : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: foreground, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w800,
                                height: 1.12,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: isPrimary
                            ? Colors.white
                            : scheme.surface,
                        foregroundColor: isPrimary
                            ? scheme.primary
                            : foreground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(
                        buttonLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: isPrimary ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: foreground, size: 22),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: foreground.withValues(alpha: isPrimary ? 0.88 : 0.72),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: isPrimary ? 0.14 : 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: foreground.withValues(
                          alpha: isPrimary ? 0.92 : 0.74,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onTap,
                      icon: Icon(
                        isPrimary
                            ? Icons.arrow_forward_rounded
                            : Icons.search_rounded,
                      ),
                      label: Text(
                        buttonLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: isPrimary
                            ? Colors.white
                            : scheme.surface,
                        foregroundColor: isPrimary
                            ? scheme.primary
                            : foreground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
