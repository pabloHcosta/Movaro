import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_typography.dart';

/// Semantic text styles for the Movaro app.
///
/// ## Usage rules
///
/// 1. Always prefer a named style from this class or from
///    `Theme.of(context).textTheme` over writing a raw [TextStyle].
///
/// 2. Only override [TextStyle.color] at the call site — never [TextStyle.fontSize].
///    If the size isn't right, pick (or add) a different semantic style.
///
/// 3. For compact UI elements (score badges, map overlays, metric chips) use
///    [AppTypography.compactBadge], [AppTypography.compactLabel],
///    [AppTypography.tinyLabel] or [AppTypography.microLabel] directly.
///
/// ## Quick reference
///
/// | Style              | Size | Weight | Use for                                     |
/// |--------------------|------|--------|---------------------------------------------|
/// | heroTitle          |  32  |  900   | Hero section main heading                   |
/// | heroSubtitle       |  15  |  400   | Hero section supporting text                |
/// | pageTitle          |  22  |  800   | Page-level titles (AppGlassHeader)          |
/// | sectionTitle       |  20  |  800   | Card / section titles                       |
/// | itemTitle          |  17  |  700   | List item / small card titles               |
/// | cardSubtitle       |  13  |  400   | Secondary text under card titles            |
/// | sectionLabel       |  12  |  700   | Uppercase section labels (e.g. "PROGRESSO") |
/// | badgeLabel         |  15  |  800   | Pill/badge labels with color fill           |
/// | navLabel           |  11  |  700   | Bottom navigation bar labels                |
/// | displayNumber      |  36  |  900   | Large numeric display (e.g. progress %)     |
/// | compactBadge       |  10  |  700   | Small uppercase inline badges               |
/// | compactLabel       |   9  |  600   | Score/metric chip values                    |
/// | tinyLabel          |   8  |  600   | Map overlay labels, image overlays          |
/// | microLabel         | 7.5  |  700   | Icon-adjacent micro indicators              |
class AppTextStyles {
  const AppTextStyles._();

  // ── Hero ──────────────────────────────────────────────────

  static TextStyle heroTitle(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
        height: 1.15,
      );

  static TextStyle heroSubtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;

  // ── Page / Section ────────────────────────────────────────

  static TextStyle pageTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w800,
      );

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w800,
      );

  static TextStyle itemTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleSmall!.copyWith(
        fontWeight: FontWeight.w700,
      );

  // ── Body ──────────────────────────────────────────────────

  static TextStyle cardSubtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!;

  // ── Labels ────────────────────────────────────────────────

  /// Uppercase section label (e.g. "PROGRESSO GERAL", "PLANO ATIVO")
  static TextStyle sectionLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  /// Filled pill/badge label
  static TextStyle badgeLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.w800,
      );

  /// Bottom navigation bar label
  static TextStyle navLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w700,
      );

  // ── Display numbers ───────────────────────────────────────

  /// Large numeric display (e.g. "11%" progress counter)
  static TextStyle displayNumber(BuildContext context) =>
      Theme.of(context).textTheme.headlineLarge!;

  // ── Compact (delegates to AppTypography constants) ────────

  /// 10px — small uppercase inline badges
  static TextStyle compactBadge(BuildContext context) =>
      AppTypography.compactBadge;

  /// 9px — score/metric chip values
  static TextStyle compactLabel(BuildContext context) =>
      AppTypography.compactLabel;

  /// 8px — map overlay / image overlay labels
  static TextStyle tinyLabel(BuildContext context) => AppTypography.tinyLabel;

  /// 7.5px — icon-adjacent micro indicators
  static TextStyle microLabel(BuildContext context) =>
      AppTypography.microLabel;
}

/// Convenience extension for ergonomic access via [BuildContext].
///
/// ```dart
/// Text('Hello', style: context.textStyles.sectionTitle)
/// ```
extension AppTextStylesX on BuildContext {
  // ignore: library_private_types_in_public_api
  _AppTextStylesProxy get textStyles => _AppTextStylesProxy(this);
}

class _AppTextStylesProxy {
  const _AppTextStylesProxy(this._context);
  final BuildContext _context;

  TextStyle get heroTitle => AppTextStyles.heroTitle(_context);
  TextStyle get heroSubtitle => AppTextStyles.heroSubtitle(_context);
  TextStyle get pageTitle => AppTextStyles.pageTitle(_context);
  TextStyle get sectionTitle => AppTextStyles.sectionTitle(_context);
  TextStyle get itemTitle => AppTextStyles.itemTitle(_context);
  TextStyle get cardSubtitle => AppTextStyles.cardSubtitle(_context);
  TextStyle get sectionLabel => AppTextStyles.sectionLabel(_context);
  TextStyle get badgeLabel => AppTextStyles.badgeLabel(_context);
  TextStyle get navLabel => AppTextStyles.navLabel(_context);
  TextStyle get displayNumber => AppTextStyles.displayNumber(_context);
  TextStyle get compactBadge => AppTextStyles.compactBadge(_context);
  TextStyle get compactLabel => AppTextStyles.compactLabel(_context);
  TextStyle get tinyLabel => AppTextStyles.tinyLabel(_context);
  TextStyle get microLabel => AppTextStyles.microLabel(_context);
}
