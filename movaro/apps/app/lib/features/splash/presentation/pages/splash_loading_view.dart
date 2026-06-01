import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';

class SplashLoadingView extends StatefulWidget {
  const SplashLoadingView({
    required this.loadingLabel,
    required this.initializingLabel,
    super.key,
  });

  final String loadingLabel;
  final String initializingLabel;

  @override
  State<SplashLoadingView> createState() => _SplashLoadingViewState();
}

class _SplashLoadingViewState extends State<SplashLoadingView>
    with TickerProviderStateMixin {
  // One-shot entrance sequence
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  // Continuous breathing cycle
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  // ── Entrance animations ──────────────────────────────────────────────────
  late final Animation<double> _markFade = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.00, 0.45, curve: Curves.easeOut),
  );

  late final Animation<double> _markScale =
      Tween<double>(begin: 0.80, end: 1.00).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.00, 0.58, curve: Curves.easeOutBack),
        ),
      );

  late final Animation<double> _wordmarkFade = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.30, 0.68, curve: Curves.easeOut),
  );

  late final Animation<double> _wordmarkSlide =
      Tween<double>(begin: 14.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.30, 0.74, curve: Curves.easeOutCubic),
        ),
      );

  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.50, 0.86, curve: Curves.easeOut),
  );

  late final Animation<double> _dotsFade = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.70, 1.00, curve: Curves.easeOut),
  );

  // ── Breathing glow ───────────────────────────────────────────────────────
  late final Animation<double> _glowPulse = CurvedAnimation(
    parent: _pulseController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _tagline(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'es' => 'Tu guía para mudarte a Brasil y arrancar con el pie derecho.',
      'en' => 'Your guide to moving to Brazil and starting on the right foot.',
      _ => 'Seu guia para mudar para o Brasil e começar com o pé direito.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 520;
    final markSize = isCompact ? 88.0 : 108.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),

          // Animated background (glows breathe with pulse)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) =>
                _SplashBackground(glowValue: _glowPulse.value),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ── Logo mark — entrance: fade + scale ──────────────────
                  FadeTransition(
                    opacity: _markFade,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) => _SplashMark(
                          size: markSize,
                          glowValue: _glowPulse.value,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Wordmark — entrance: fade + slide up ────────────────
                  FadeTransition(
                    opacity: _wordmarkFade,
                    child: AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, _) => Transform.translate(
                        offset: Offset(0, _wordmarkSlide.value),
                        child: Text(
                          'Movaro',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2.2,
                                height: 1.0,
                              ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Tagline — entrance: fade ────────────────────────────
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      _tagline(context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        height: 1.4,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Pulsing dots — replaces fake progress bar ───────────
                  FadeTransition(
                    opacity: _dotsFade,
                    child: _LoadingDots(controller: _pulseController),
                  ),

                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated background ──────────────────────────────────────────────────────

class _SplashBackground extends StatelessWidget {
  const _SplashBackground({required this.glowValue});

  final double glowValue;

  @override
  Widget build(BuildContext context) {
    final topAlpha = 0.16 + (glowValue * 0.12);
    final bottomAlpha = 0.22 + (glowValue * 0.14);
    final centerAlpha = 0.06 + (glowValue * 0.05);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.heroStart,
            AppColors.heroMiddle,
            AppColors.heroEnd,
          ],
          stops: [0.0, 0.50, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Top-left lavender glow — breathes with pulse
          Positioned(
            top: -140,
            left: -100,
            child: IgnorePointer(
              child: Container(
                width: 440,
                height: 440,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.glowLavender.withValues(alpha: topAlpha),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom-right blue glow — breathes with pulse
          Positioned(
            right: -130,
            bottom: -170,
            child: IgnorePointer(
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.glowBlue.withValues(alpha: bottomAlpha),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Center radial accent (subtle primary hue)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.05, -0.10),
                    radius: 0.58,
                    colors: [
                      AppColors.primary.withValues(alpha: centerAlpha),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo mark with double glow ───────────────────────────────────────────────

class _SplashMark extends StatelessWidget {
  const _SplashMark({required this.size, required this.glowValue});

  final double size;
  final double glowValue;

  @override
  Widget build(BuildContext context) {
    final outerAlpha = 0.12 + (glowValue * 0.10);
    final innerAlpha = 0.07 + (glowValue * 0.06);
    final outerSize = size + 108.0;
    final innerSize = size + 40.0;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer diffuse glow
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.glowBlue.withValues(alpha: outerAlpha),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Inner tight glow
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: innerAlpha),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Brand mark
          SvgPicture.asset(
            'assets/brand/movaro_mark_light.svg',
            width: size,
            height: size,
          ),
        ],
      ),
    );
  }
}

// ── Pulsing loading dots ─────────────────────────────────────────────────────

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  static const _count = 3;
  static const _size = 6.0;
  static const _spacing = 9.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(controller.value);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _count; i++) ...[
              if (i > 0) const SizedBox(width: _spacing),
              _buildDot(i, t),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDot(int index, double t) {
    // Each dot peaks at a different phase in the 0→1 cycle:
    // dot 0 peaks at t=0.0, dot 1 at t=0.5, dot 2 at t=1.0
    // The controller reverses (0→1→0→1...) creating a pendulum wave.
    final phase = index / (_count - 1); // 0.0, 0.5, 1.0
    final dist = (t - phase).abs();
    final brightness = (1.0 - dist * 2.2).clamp(0.0, 1.0);

    final alpha = 0.22 + (brightness * 0.78);
    final scale = 0.62 + (brightness * 0.38);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      ),
    );
  }
}
