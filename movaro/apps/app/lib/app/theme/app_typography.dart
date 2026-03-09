import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        height: 1.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.4,
      ),
      displaySmall: TextStyle(
        fontSize: 40,
        height: 1.02,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.6,
      ),
      headlineMedium: TextStyle(
        fontSize: 32,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
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
      labelSmall: TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
    );
  }
}
