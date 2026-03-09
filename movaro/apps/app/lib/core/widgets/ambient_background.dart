import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/app_colors.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF05070B), Color(0xFF0A0E14), Color(0xFF111927)]
              : const [
                  Color(0xFFF8F9FB),
                  AppColors.background,
                  Color(0xFFEFF4FF),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _GlowOrb(
              size: 260,
              colors: [
                (isDark ? AppColors.heroMiddle : AppColors.glowLavender)
                    .withValues(alpha: isDark ? 0.28 : 0.55),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: 120,
            right: -60,
            child: _GlowOrb(
              size: 320,
              colors: [
                (isDark ? AppColors.heroEnd : AppColors.glowBlue).withValues(
                  alpha: isDark ? 0.22 : 0.65,
                ),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
