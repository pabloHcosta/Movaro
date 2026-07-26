import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/home/application/city_feed_datasource.dart';
import 'package:movaro_app/features/home/domain/city_feed_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';

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
    final isDark = AppColors.isDark(context);
    final color = item.typeColor(isDark);
    final locale = Localizations.localeOf(context).languageCode;

    // Items where a "Ver no guia" CTA is meaningful — tips, warnings,
    // opportunities all have a corresponding guide step the user can act on.
    final showGuideCta = onOpenGuideItem != null && item.guideItemId != null;

    final guideCtaLabel = switch (locale) {
      'pt' => 'Ver passo a passo no guia →',
      'es' => 'Ver paso a paso en la guía →',
      _ => 'See step-by-step guide →',
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(sheetContext),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderFor(sheetContext)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, size: 18, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.badge ?? item.typeLabel(locale),
                              style: AppTypography.compactBadge.copyWith(
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.title,
                              style: Theme.of(sheetContext).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimaryFor(
                                      sheetContext,
                                    ),
                                    height: 1.25,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSoftFor(sheetContext),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Body
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(sheetContext).size.height * 0.45,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        item.body,
                        style: Theme.of(sheetContext).textTheme.bodySmall
                            ?.copyWith(
                              height: 1.55,
                              color: AppColors.textSoftFor(sheetContext),
                            ),
                      ),
                    ),
                  ),
                  if (item.sourceLabel != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      item.sourceUrl == null
                          ? item.sourceLabel!
                          : '${item.sourceLabel!} · ${item.updatedAt ?? ''}'
                                .trim()
                                .replaceFirst(RegExp(r' · $'), ''),
                      style: Theme.of(sheetContext).textTheme.labelSmall
                          ?.copyWith(
                            color: AppColors.textSoftFor(sheetContext),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                  // Guide CTA — only for actionable item types
                  if (showGuideCta) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          onOpenGuideItem(item.guideItemId);
                        },
                        icon: const Icon(Icons.route_rounded, size: 16),
                        label: Text(guideCtaLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
