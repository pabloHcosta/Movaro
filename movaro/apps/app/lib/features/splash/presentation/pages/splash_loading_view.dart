import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movaro_app/app/localization/app_localization.dart';

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
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  );

  late final AnimationController _ambientController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  late final Animation<double> _heroOpacity = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0, 0.5, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _heroScale = Tween<double>(begin: 0.92, end: 1)
      .animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
        ),
      );

  late final Animation<double> _copyOpacity = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.28, 0.78, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _statusOpacity = CurvedAnimation(
    parent: _entranceController,
    curve: const Interval(0.62, 1, curve: Curves.easeOut),
  );

  bool _motionConfigured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionConfigured) return;
    _motionConfigured = true;

    final mediaQuery = MediaQuery.of(context);
    final reduceMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    if (reduceMotion) {
      _entranceController.value = 1;
      _ambientController.value = 0.5;
    } else {
      _entranceController.forward();
      _ambientController.repeat();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B1D),
      body: RepaintBoundary(
        key: const ValueKey('splash-visual-root'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _ambientController,
              builder: (context, _) => CustomPaint(
                painter: _SplashAtmospherePainter(_ambientController.value),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscapeHero =
                      constraints.maxWidth >= 760 &&
                      constraints.maxWidth / constraints.maxHeight > 1.25;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      constraints.maxWidth < 420 ? 22 : 36,
                      24,
                      constraints.maxWidth < 420 ? 22 : 36,
                      24,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 980),
                              child: isLandscapeHero
                                  ? _buildLandscapeHero(context, constraints)
                                  : _buildPortraitHero(context, constraints),
                            ),
                          ),
                        ),
                        FadeTransition(
                          opacity: _statusOpacity,
                          child: _LaunchStatus(
                            label: widget.loadingLabel,
                            semanticsLabel: widget.initializingLabel,
                            controller: _ambientController,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitHero(BuildContext context, BoxConstraints constraints) {
    final heroWidth = math.min(constraints.maxWidth * 0.88, 460.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedHeroMark(
          width: heroWidth,
          opacity: _heroOpacity,
          scale: _heroScale,
          ambientController: _ambientController,
        ),
        SizedBox(height: constraints.maxHeight < 650 ? 12 : 24),
        _BrandCopy(
          opacity: _copyOpacity,
          centered: true,
          compact: constraints.maxHeight < 650,
        ),
      ],
    );
  }

  Widget _buildLandscapeHero(BuildContext context, BoxConstraints constraints) {
    final heroWidth = math.min(constraints.maxWidth * 0.48, 500.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: _AnimatedHeroMark(
            width: heroWidth,
            opacity: _heroOpacity,
            scale: _heroScale,
            ambientController: _ambientController,
          ),
        ),
        const SizedBox(width: 58),
        Flexible(
          child: _BrandCopy(
            opacity: _copyOpacity,
            centered: false,
            compact: constraints.maxHeight < 560,
          ),
        ),
      ],
    );
  }
}

class _AnimatedHeroMark extends StatelessWidget {
  const _AnimatedHeroMark({
    required this.width,
    required this.opacity,
    required this.scale,
    required this.ambientController,
  });

  final double width;
  final Animation<double> opacity;
  final Animation<double> scale;
  final AnimationController ambientController;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Movaro',
      child: FadeTransition(
        opacity: opacity,
        child: ScaleTransition(
          scale: scale,
          child: AnimatedBuilder(
            animation: ambientController,
            builder: (context, child) {
              final wave = math.sin(ambientController.value * math.pi * 2);
              return Transform.translate(
                offset: Offset(0, wave * 3),
                child: child,
              );
            },
            child: SizedBox(
              width: width,
              height: width * 0.63,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          radius: 0.56,
                          colors: [
                            const Color(0xFF0876FF).withValues(alpha: 0.22),
                            const Color(0xFF0876FF).withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: SvgPicture.asset(
                      'assets/brand/movaro_splash_hero.svg',
                      width: width,
                      fit: BoxFit.contain,
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
}

class _BrandCopy extends StatelessWidget {
  const _BrandCopy({
    required this.opacity,
    required this.centered,
    required this.compact,
  });

  final Animation<double> opacity;
  final bool centered;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textAlign = centered ? TextAlign.center : TextAlign.left;
    final crossAxisAlignment = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return AnimatedBuilder(
      animation: opacity,
      builder: (context, child) => Opacity(
        opacity: opacity.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - opacity.value)),
          child: child,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            'Movaro',
            textAlign: textAlign,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontSize: compact ? 38 : 46,
              fontWeight: FontWeight.w800,
              letterSpacing: -2.2,
              height: 1,
            ),
          ),
          SizedBox(height: compact ? 10 : 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Text(
              context.l10n.splashHeroTitle,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFC8D8F4),
                fontSize: compact ? 15 : 17,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchStatus extends StatelessWidget {
  const _LaunchStatus({
    required this.label,
    required this.semanticsLabel,
    required this.controller,
  });

  final String label;
  final String semanticsLabel;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: semanticsLabel,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        padding: const EdgeInsets.fromLTRB(16, 12, 18, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShimmerTrack(controller: controller),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerTrack extends StatelessWidget {
  const _ShimmerTrack({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 46,
        height: 4,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: Colors.white.withValues(alpha: 0.12)),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final position =
                    Curves.easeInOut.transform(controller.value) * 34 - 8;
                return Transform.translate(
                  offset: Offset(position, 0),
                  child: Container(
                    width: 20,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF56E5F3), Color(0xFF1288FF)],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashAtmospherePainter extends CustomPainter {
  const _SplashAtmospherePainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const background = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF020B1D), Color(0xFF061839), Color(0xFF062A83)],
      stops: [0, 0.56, 1],
    );
    canvas.drawRect(rect, Paint()..shader = background.createShader(rect));

    final blueGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF0B70FF).withValues(alpha: 0.2),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.78, size.height * 0.7),
              radius: math.max(size.width, size.height) * 0.62,
            ),
          );
    canvas.drawRect(rect, blueGlow);

    final cyanGlow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF36DDEA).withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.28, size.height * 0.38),
              radius: math.max(size.width, size.height) * 0.42,
            ),
          );
    canvas.drawRect(rect, cyanGlow);

    final shift = math.sin(progress * math.pi * 2) * size.width * 0.015;
    final route = Path()
      ..moveTo(-size.width * 0.08 + shift, size.height * 0.78)
      ..cubicTo(
        size.width * 0.22 + shift,
        size.height * 0.62,
        size.width * 0.48 + shift,
        size.height * 0.96,
        size.width * 1.08 + shift,
        size.height * 0.73,
      );
    canvas.drawPath(
      route,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.035)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final fineRoute = Path()
      ..moveTo(size.width * 0.04 - shift, size.height * 0.18)
      ..cubicTo(
        size.width * 0.32 - shift,
        size.height * 0.04,
        size.width * 0.63 - shift,
        size.height * 0.32,
        size.width * 1.04 - shift,
        size.height * 0.13,
      );
    canvas.drawPath(
      fineRoute,
      Paint()
        ..color = const Color(0xFF61DCEB).withValues(alpha: 0.045)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_SplashAtmospherePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
