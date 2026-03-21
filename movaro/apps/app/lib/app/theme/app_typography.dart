import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme() {
    return const TextTheme(
      // ── Display ─────────────────────────────────────────────
      displayLarge: TextStyle(
        fontSize: 56,
        height: 1.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.4,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        height: 1.02,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.8,
      ),
      displaySmall: TextStyle(
        fontSize: 40,
        height: 1.02,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.6,
      ),

      // ── Headline ────────────────────────────────────────────
      // Use for large display numbers (e.g. progress %)
      headlineLarge: TextStyle(
        fontSize: 36,
        height: 1.05,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 32,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      // Use for section headers / prominent card titles
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),

      // ── Title ───────────────────────────────────────────────
      // Use for card/list item titles
      titleLarge: TextStyle(
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleSmall: TextStyle(
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w600,
      ),

      // ── Body ────────────────────────────────────────────────
      bodyLarge: TextStyle(
        fontSize: 17,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
      ),
      // Use for secondary/supporting text
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
      ),

      // ── Label ───────────────────────────────────────────────
      labelLarge: TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      // Use for uppercase section badges, metadata chips
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }

  // ── Compact styles ──────────────────────────────────────────
  // For intentionally small UI elements (score badges, map overlays,
  // metric chips). Do NOT use textTheme with copyWith(fontSize: X) for these.

  /// 10px — compact uppercase badges (e.g. "PLANO ATIVO", pill labels)
  static const TextStyle compactBadge = TextStyle(
    fontSize: 10,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  /// 9px — score/metric value labels inside chips and cards
  static const TextStyle compactLabel = TextStyle(
    fontSize: 9,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// 8px — tight overlay labels (map pins, image overlays, small indicators)
  static const TextStyle tinyLabel = TextStyle(
    fontSize: 8,
    height: 1.15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// 7px — minimum readable size, only for icon-adjacent micro indicators
  static const TextStyle microLabel = TextStyle(
    fontSize: 7.5,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );
}
