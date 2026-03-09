import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/app/theme/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return _buildTheme(brightness: Brightness.light);
  }

  static ThemeData dark() {
    return _buildTheme(brightness: Brightness.dark);
  }

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          secondary: isDark ? const Color(0xFF92A7FF) : AppColors.secondary,
          surface: isDark ? const Color(0xFF0F141C) : AppColors.surface,
          onSurface: isDark ? const Color(0xFFF5F7FB) : AppColors.textPrimary,
          outlineVariant: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : AppColors.border,
          surfaceContainerHighest: isDark
              ? const Color(0xFF171D27)
              : AppColors.surfaceMuted,
          surfaceContainer: isDark
              ? const Color(0xFF1A2230)
              : AppColors.surfaceElevated,
        );
    final textTheme = AppTypography.textTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF06080D)
          : AppColors.background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDark ? const Color(0xD9161C26) : const Color(0xD9FFFFFF),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.border,
            width: 1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: AppTypography.textTheme().labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : AppColors.border,
            width: 1,
          ),
          backgroundColor: isDark
              ? const Color(0x3317222F)
              : const Color(0xA6FFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xCC121A24) : const Color(0xCCFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? const Color(0xFFB5BFCE) : AppColors.textSoft,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? const Color(0xFFB5BFCE) : AppColors.textSoft,
        ),
      ),
      dividerColor: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : AppColors.border,
    );
  }
}
