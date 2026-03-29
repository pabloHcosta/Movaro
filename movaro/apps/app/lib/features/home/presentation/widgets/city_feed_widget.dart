import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_typography.dart';
import 'package:movaro_app/features/home/application/city_feed_datasource.dart';
import 'package:movaro_app/features/home/domain/city_feed_item.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';

/// Horizontally scrollable snackable content feed.
///
/// Renders [CityFeedItem] cards filtered by the user's city and journey stage.
/// Each card is intentionally compact — one idea per card, no overload.
class CityFeedWidget extends StatelessWidget {
  const CityFeedWidget({
    required this.cityCode,
    required this.stage,
    required this.locale,
    this.cardHeight = 152.0,
    super.key,
  });

  final String? cityCode;
  final UserJourneyStage stage;
  final String locale;
  /// Height of the scrollable card row.
  /// Defaults to 152 pt — enough to show 3 body lines without clipping.
  /// The Focus Mode layout passes a screen-derived value computed by
  /// LayoutBuilder (typically 148–178 pt depending on device).
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final items = CityFeedDatasource.build(
      cityCode: cityCode,
      stage: stage,
      locale: locale,
    );

    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            _sectionTitle(locale),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 0.6,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.25)
                  : const Color(0x590A0F1E),
            ),
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _FeedCard(item: items[index]),
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
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.item});

  final CityFeedItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final color = item.typeColor(isDark);
    final locale = Localizations.localeOf(context).languageCode;

    return GestureDetector(
      onTap: () => _showExpandedCard(context),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(item.icon, size: 13, color: color),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    item.badge ?? item.typeLabel(locale),
                    style: AppTypography.compactBadge.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            // Title
            Text(
              item.title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryFor(context),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Body — Flexible so it grows with available card height but
            // never pushes the timestamp off-screen.
            Flexible(
              child: Text(
                item.body,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSoftFor(context),
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (item.updatedAt != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item.updatedAt!,
                  style: AppTypography.tinyLabel.copyWith(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.20)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExpandedCard(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final color = item.typeColor(isDark);
    final locale = Localizations.localeOf(context).languageCode;

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
                border: Border.all(
                  color: AppColors.borderFor(sheetContext),
                ),
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
                          color: color.withValues(
                            alpha: isDark ? 0.18 : 0.12,
                          ),
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
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryFor(sheetContext),
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
                      maxHeight:
                          MediaQuery.of(sheetContext).size.height * 0.50,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        item.body,
                        style: Theme.of(
                          sheetContext,
                        ).textTheme.bodySmall?.copyWith(
                          height: 1.55,
                          color: AppColors.textSoftFor(sheetContext),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
