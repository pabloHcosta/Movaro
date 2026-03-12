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
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 520;

    final logoSize = isCompact ? 148.0 : 188.0;
    final progressTopSpacing = isCompact ? 20.0 : 24.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          const _SplashBackground(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) {
                      final glowValue = Curves.easeInOut.transform(
                        _pulseController.value,
                      );

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SplashMark(size: logoSize, glowValue: glowValue),
                          SizedBox(height: progressTopSpacing),
                          const _SplashProgress(),
                        ],
                      );
                    },
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

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.heroStart,
            AppColors.heroMiddle,
            AppColors.heroEnd,
          ],
          stops: [0.06, 0.56, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.glowLavender.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -90,
            bottom: -120,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.glowBlue.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 260,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
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

class _SplashMark extends StatelessWidget {
  const _SplashMark({required this.size, required this.glowValue});

  final double size;
  final double glowValue;

  @override
  Widget build(BuildContext context) {
    final scale = 1 + (glowValue * 0.016);
    final glowAlpha = 0.12 + (glowValue * 0.08);

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: size + 84,
        height: size + 84,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size + 84,
              height: size + 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.glowBlue.withValues(alpha: glowAlpha),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/brand/movaro_mark_light.svg',
              width: size,
              height: size,
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 126,
        height: 3,
        color: Colors.white.withValues(alpha: 0.16),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.12, end: 0.78),
          duration: const Duration(milliseconds: 1300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.glowLavender.withValues(alpha: 0.92),
                        Colors.white,
                        AppColors.glowBlue.withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
