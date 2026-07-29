import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/core/trust/source_freshness_policy.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/home/application/city_feed_datasource.dart';
import 'package:movaro_app/features/home/domain/city_feed_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';
import 'package:url_launcher/url_launcher.dart';

/// Horizontally scrollable snackable content feed.
///
/// Renders [CityFeedItem] cards filtered by the user's city and journey stage.
/// Each card is intentionally compact — one idea per card, no overload.
///
/// [onOpenGuide] — optional callback invoked when the user taps "Ver no guia"
/// inside an expanded card. Typically navigates to the migration copilot.
class CityFeedWidget extends StatelessWidget {
  const CityFeedWidget({
    required this.cityCode,
    required this.stage,
    required this.locale,
    this.city,
    this.weather,
    this.socialProof,
    this.climateSummary,
    this.arrivalStory,
    this.comparison,
    this.guideCurrentItem,
    this.cardHeight = 118.0,
    this.onOpenGuideItem,
    super.key,
  });

  final String? cityCode;
  final UserJourneyStage stage;
  final String locale;
  final City? city;
  final CityWeather? weather;
  final CityDetailSocialProof? socialProof;
  final CityDetailClimateSummary? climateSummary;
  final CityDetailArrivalStory? arrivalStory;
  final CityDetailComparison? comparison;
  final GuideActionItem? guideCurrentItem;

  /// Fixed height of the compact preview row. Full content opens in a sheet.
  final double cardHeight;

  /// Optional: called when the user taps the guide CTA inside an expanded
  /// card. If null, the "Ver no guia" button is not shown.
  final ValueChanged<String?>? onOpenGuideItem;

  @override
  Widget build(BuildContext context) {
    final allItems = CityFeedDatasource.build(
      cityCode: cityCode,
      stage: stage,
      locale: locale,
      city: city,
      weather: weather,
      socialProof: socialProof,
      climateSummary: climateSummary,
      arrivalStory: arrivalStory,
      comparison: comparison,
      guideCurrentItem: guideCurrentItem,
    );
    final nonDuplicateItems = allItems
        .where((item) => item.guideItemId != guideCurrentItem?.id)
        .toList(growable: false);
    final items = nonDuplicateItems.isEmpty ? allItems : nonDuplicateItems;

    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = AppColors.isDark(context);
    final cardWidth = (MediaQuery.sizeOf(context).width - 56).clamp(
      248.0,
      300.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Text(
                _sectionTitle(locale),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoftFor(context),
                ),
              ),
              const Spacer(),
              Text(
                _itemCountLabel(locale, items.length),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.38)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _FeedCard(
              item: items[index],
              width: cardWidth,
              isFeatured: index == 0,
              onOpenGuideItem: onOpenGuideItem,
            ),
          ),
        ),
      ],
    );
  }

  String _sectionTitle(String locale) => switch (locale) {
    'pt' => 'PARA VOCÊ',
    'es' => 'PARA TI',
    _ => 'FOR YOU',
  };

  String _itemCountLabel(String locale, int count) => switch (locale) {
    'pt' => '$count dicas',
    'es' => '$count consejos',
    _ => '$count tips',
  };
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({
    required this.item,
    required this.width,
    required this.isFeatured,
    this.onOpenGuideItem,
  });

  final CityFeedItem item;
  final double width;
  final bool isFeatured;
  final ValueChanged<String?>? onOpenGuideItem;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final color = item.typeColor(isDark);
    final locale = Localizations.localeOf(context).languageCode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          _showExpandedCard(context, onOpenGuideItem);
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isFeatured
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            color.withValues(alpha: 0.15),
                            AppColors.surfaceFor(context),
                            AppColors.surfaceFor(context),
                          ]
                        : [
                            color.withValues(alpha: 0.10),
                            AppColors.surfaceFor(context),
                            AppColors.surfaceFor(context),
                          ],
                    stops: const [0, 0.42, 1],
                  )
                : null,
            color: isFeatured ? null : AppColors.surfaceFor(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isFeatured
                  ? color.withValues(alpha: 0.24)
                  : AppColors.borderFor(context),
            ),
            boxShadow: isFeatured
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, size: 15, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.badge ?? item.typeLabel(locale),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryFor(context),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Text(
                    _verMaisLabel(locale),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _verMaisLabel(String locale) => switch (locale) {
    'pt' => 'Ver dica',
    'es' => 'Ver consejo',
    _ => 'View tip',
  };

  void _showExpandedCard(
    BuildContext context,
    ValueChanged<String?>? onOpenGuideItem,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.68),
      builder: (sheetContext) =>
          _ExpandedFeedSheet(item: item, onOpenGuideItem: onOpenGuideItem),
    );
  }
}

class _ExpandedFeedSheet extends StatelessWidget {
  const _ExpandedFeedSheet({required this.item, this.onOpenGuideItem});

  final CityFeedItem item;
  final ValueChanged<String?>? onOpenGuideItem;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final accent = item.typeColor(isDark);
    final locale = Localizations.localeOf(context).languageCode;
    final showGuideCta = onOpenGuideItem != null && item.guideItemId != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Material(
              color: AppColors.surfaceFor(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetHero(item: item, accent: accent, locale: locale),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        22,
                        22,
                        22,
                        18 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionEyebrow(
                            icon: Icons.auto_awesome_rounded,
                            label: _copy(
                              locale,
                              pt: 'O QUE VOCÊ PRECISA SABER',
                              es: 'LO QUE NECESITÁS SABER',
                              en: 'WHAT YOU NEED TO KNOW',
                            ),
                            color: accent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _resolvedBody(context),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColors.textPrimaryFor(context),
                                  fontSize: 16,
                                  height: 1.62,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.1,
                                ),
                          ),
                          if (item.sourceLabel != null) ...[
                            const SizedBox(height: 24),
                            _SourcePanel(
                              item: item,
                              locale: locale,
                              accent: accent,
                            ),
                          ],
                          if (showGuideCta) ...[
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onOpenGuideItem!(item.guideItemId);
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                icon: const Icon(Icons.route_rounded, size: 19),
                                label: Text(
                                  _copy(
                                    locale,
                                    pt: 'Abrir passo a passo',
                                    es: 'Abrir paso a paso',
                                    en: 'Open step-by-step',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  String _resolvedBody(BuildContext context) {
    final minBrl = item.rangeMinBrl;
    final maxBrl = item.rangeMaxBrl;
    if (minBrl == null || maxBrl == null) return item.body;
    final range = MultiCurrencyAmount.formatRangeFromBrl(
      context: context,
      minBrl: minBrl,
      maxBrl: maxBrl,
    );
    return '${item.bodyBeforeRange ?? ''}$range${item.bodyAfterRange ?? ''}';
  }

  static String _copy(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) => switch (locale) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };
}

class _SheetHero extends StatelessWidget {
  const _SheetHero({
    required this.item,
    required this.accent,
    required this.locale,
  });

  final CityFeedItem item;
  final Color accent;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 14, 18, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: isDark ? 0.34 : 0.23),
                accent.withValues(alpha: isDark ? 0.14 : 0.08),
                AppColors.surfaceFor(context),
              ],
              stops: const [0, 0.58, 1],
            ),
            border: Border(
              bottom: BorderSide(
                color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSoftFor(
                      context,
                    ).withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.24 : 0.14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.32)),
                    ),
                    child: Icon(item.icon, size: 23, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: isDark ? 0.18 : 0.10),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        item.badge ?? item.typeLabel(locale),
                        style: AppTypography.compactBadge.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceFor(
                        context,
                      ).withValues(alpha: 0.72),
                    ),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textPrimaryFor(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                item.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontSize: 25,
                  height: 1.16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.65,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _heroSupporting(locale),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSoftFor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -34,
          top: 52,
          child: IgnorePointer(
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: 0.11),
                  width: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _heroSupporting(String locale) => switch (locale) {
    'pt' => 'Uma leitura prática para a sua decisão',
    'es' => 'Una lectura práctica para tu decisión',
    _ => 'A practical read for your decision',
  };
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.75,
          ),
        ),
      ],
    );
  }
}

class _SourcePanel extends StatelessWidget {
  const _SourcePanel({
    required this.item,
    required this.locale,
    required this.accent,
  });

  final CityFeedItem item;
  final String locale;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasLink = item.sourceUrl != null;
    final isDark = AppColors.isDark(context);
    final curationDate = SourceFreshnessPolicy.parseCurationDate(
      item.updatedAt,
    );
    final freshness = curationDate == null
        ? null
        : SourceFreshnessPolicy.assess(
            lastVerified: curationDate,
            reviewAfter: const Duration(days: 90),
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.10 : 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(
            icon: hasLink
                ? Icons.verified_user_outlined
                : Icons.info_outline_rounded,
            label: _sourceEyebrow(locale, hasLink),
            color: accent,
          ),
          const SizedBox(height: 10),
          Text(
            item.sourceLabel!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimaryFor(context),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (item.updatedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _verifiedLabel(locale, item.updatedAt!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSoftFor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (freshness?.requiresWarning ?? false) ...[
            const SizedBox(height: 8),
            Text(
              switch (locale) {
                'pt' =>
                  'Revisão pendente — confirme a informação na fonte original.',
                'es' =>
                  'Revisión pendiente — confirmá la información en la fuente original.',
                _ =>
                  'Review pending — confirm the information at the original source.',
              },
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (hasLink) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse(item.sourceUrl!),
                  mode: LaunchMode.externalApplication,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.36)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 17),
                label: Text(_openSourceLabel(locale)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _sourceEyebrow(String locale, bool hasLink) => switch (locale) {
    'pt' => hasLink ? 'FONTE VERIFICÁVEL' : 'REFERÊNCIA',
    'es' => hasLink ? 'FUENTE VERIFICABLE' : 'REFERENCIA',
    _ => hasLink ? 'VERIFIABLE SOURCE' : 'REFERENCE',
  };

  String _verifiedLabel(String locale, String date) => switch (locale) {
    'pt' => 'Verificado em $date',
    'es' => 'Verificado el $date',
    _ => 'Verified on $date',
  };

  String _openSourceLabel(String locale) => switch (locale) {
    'pt' => 'Consultar fonte original',
    'es' => 'Consultar fuente original',
    _ => 'View original source',
  };
}
