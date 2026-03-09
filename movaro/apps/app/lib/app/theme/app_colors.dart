import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF0071E3);
  static const secondary = Color(0xFF7C8DFF);
  static const accent = Color(0xFF35C6F4);
  static const background = Color(0xFFF5F5F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0F3F8);
  static const surfaceElevated = Color(0xFFE9EEF8);
  static const textPrimary = Color(0xFF1D1D1F);
  static const textSoft = Color(0xFF6E6E73);
  static const border = Color(0x1A1D1D1F);
  static const heroStart = Color(0xFF09111F);
  static const heroMiddle = Color(0xFF183A70);
  static const heroEnd = Color(0xFF74B5FF);
  static const glowBlue = Color(0xFFB8D8FF);
  static const glowLavender = Color(0xFFD6D9FF);
  static const success = Color(0xFF1F7A46);
  static const warning = Color(0xFFE0A100);
  static const caution = Color(0xFFE77728);
  static const danger = Color(0xFFC73E1D);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundFor(BuildContext context) =>
      isDark(context) ? const Color(0xFF06080D) : background;

  static Color surfaceFor(BuildContext context) =>
      isDark(context) ? const Color(0xFF0F141C) : surface;

  static Color surfaceMutedFor(BuildContext context) =>
      isDark(context) ? const Color(0xFF171D27) : surfaceMuted;

  static Color surfaceElevatedFor(BuildContext context) =>
      isDark(context) ? const Color(0xFF1A2230) : surfaceElevated;

  static Color textPrimaryFor(BuildContext context) =>
      isDark(context) ? const Color(0xFFF5F7FB) : textPrimary;

  static Color textSoftFor(BuildContext context) =>
      isDark(context) ? const Color(0xFFB5BFCE) : textSoft;

  static Color borderFor(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.10) : border;

  static Color frostedBackgroundFor(BuildContext context) =>
      isDark(context) ? const Color(0xCC101722) : const Color(0xCCFFFFFF);

  static Color frostedBorderFor(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : const Color(0x1A1D1D1F);

  static List<BoxShadow> frostedShadowFor(BuildContext context) =>
      isDark(context)
      ? const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 42,
            offset: Offset(0, 20),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ];

  static Color tintedSurfaceFor(
    BuildContext context, {
    required Color tint,
    required Color lightColor,
    double darkAlpha = 0.12,
    Color? darkBase,
  }) {
    if (!isDark(context)) {
      return lightColor;
    }

    return Color.alphaBlend(
      tint.withValues(alpha: darkAlpha),
      darkBase ?? surfaceFor(context),
    );
  }

  static Color tintedBorderFor(
    BuildContext context, {
    required Color tint,
    required Color lightColor,
    double darkAlpha = 0.24,
  }) {
    if (!isDark(context)) {
      return lightColor;
    }

    return tint.withValues(alpha: darkAlpha);
  }
}
