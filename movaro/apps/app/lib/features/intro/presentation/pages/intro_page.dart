import 'package:flutter/material.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/router/app_routes.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/journey/journey_context_controller.dart';
import 'package:movaro_app/core/widgets/ambient_background.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({
    required this.journeyContextController,
    this.isFirstLaunch = false,
    super.key,
  });

  final bool isFirstLaunch;
  final JourneyContextController journeyContextController;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish(BuildContext context) async {
    await widget.journeyContextController.markIntroSeen();

    if (!context.mounted) {
      return;
    }

    if (widget.isFirstLaunch) {
      Navigator.pushReplacementNamed(context, AppRoutes.journeySetup);
      return;
    }

    Navigator.maybePop(context);
  }

  void _goNext(BuildContext context) {
    if (_currentPage == 2) {
      _finish(context);
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 720;

    final slides = [
      _IntroSlideData(
        kind: _IntroIllustrationKind.explore,
        title: l10n.introExploreTitle,
        description: l10n.introExploreDescription,
      ),
      _IntroSlideData(
        kind: _IntroIllustrationKind.plan,
        title: l10n.introPlanTitle,
        description: l10n.introPlanDescription,
      ),
      _IntroSlideData(
        kind: _IntroIllustrationKind.documents,
        title: l10n.introDocumentationTitle,
        description: l10n.introDocumentationDescription,
      ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          const _IntroBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 20 : 32,
                    isCompact ? 16 : 28,
                    isCompact ? 20 : 32,
                    isCompact ? 18 : 28,
                  ),
                  child: Column(
                    children: [
                      _IntroTopBar(
                        title: l10n.introPageTitle,
                        skipLabel: l10n.introSkipAction,
                        showBack:
                            !widget.isFirstLaunch || Navigator.canPop(context),
                        onBack: () => Navigator.maybePop(context),
                        onSkip: () => _finish(context),
                        isCompact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 20 : 28),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: slides.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _IntroStepPage(
                              data: slides[index],
                              isCompact: isCompact,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: isCompact ? 18 : 28),
                      _IntroBottomSection(
                        currentPage: _currentPage,
                        isCompact: isCompact,
                        onDotTap: (index) {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        onNext: () => _goNext(context),
                        primaryLabel: _currentPage == 2
                            ? l10n.introPrimaryAction
                            : 'Next',
                      ),
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

class _IntroSlideData {
  const _IntroSlideData({
    required this.kind,
    required this.title,
    required this.description,
  });

  final _IntroIllustrationKind kind;
  final String title;
  final String description;
}

enum _IntroIllustrationKind { explore, plan, documents }

class _IntroTopBar extends StatelessWidget {
  const _IntroTopBar({
    required this.title,
    required this.skipLabel,
    required this.showBack,
    required this.onBack,
    required this.onSkip,
    required this.isCompact,
  });

  final String title;
  final String skipLabel;
  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          _CircleGhostButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
            size: isCompact ? 40 : 46,
          )
        else
          SizedBox(width: isCompact ? 40 : 46),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isCompact ? 15 : 17,
                height: 1.2,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 12,
              vertical: 8,
            ),
          ),
          child: Text(
            skipLabel,
            style: TextStyle(
              fontSize: isCompact ? 14 : 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroStepPage extends StatelessWidget {
  const _IntroStepPage({required this.data, required this.isCompact});

  final _IntroSlideData data;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        children: [
          Expanded(
            flex: 60,
            child: _IntroHeroIllustration(kind: data.kind, isCompact: true),
          ),
          const SizedBox(height: 18),
          Expanded(
            flex: 24,
            child: _IntroTextContent(
              title: data.title,
              description: data.description,
              isCompact: true,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 11,
          child: _IntroTextContent(
            title: data.title,
            description: data.description,
            isCompact: false,
          ),
        ),
        const SizedBox(width: 36),
        Expanded(
          flex: 12,
          child: _IntroHeroIllustration(kind: data.kind, isCompact: false),
        ),
      ],
    );
  }
}

class _IntroHeroIllustration extends StatelessWidget {
  const _IntroHeroIllustration({required this.kind, required this.isCompact});

  final _IntroIllustrationKind kind;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(isCompact ? 28 : 36);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: isCompact ? 20 : 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF78C6F4),
                    Color(0xFF69B6ED),
                    Color(0xFF4DA3F1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: isCompact ? -10 : -18,
              right: isCompact ? -18 : -8,
              child: IgnorePointer(
                child: Container(
                  width: isCompact ? 82 : 116,
                  height: isCompact ? 82 : 116,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xF3FFFFFF),
                  ),
                ),
              ),
            ),
            Positioned(
              left: isCompact ? -36 : -54,
              bottom: isCompact ? -32 : -42,
              child: IgnorePointer(
                child: Container(
                  width: isCompact ? 108 : 146,
                  height: isCompact ? 108 : 146,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xF7FFFFFF),
                  ),
                ),
              ),
            ),
            Positioned(
              left: isCompact ? 24 : 30,
              top: isCompact ? 24 : 30,
              child: Container(
                width: isCompact ? 7 : 8,
                height: isCompact ? 7 : 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF1F76E6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: isCompact ? 60 : 88,
              top: isCompact ? 28 : 34,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: isCompact ? 38 : 48,
              bottom: isCompact ? 60 : 74,
              child: Container(
                width: isCompact ? 36 : 44,
                height: isCompact ? 36 : 44,
                decoration: const BoxDecoration(
                  color: Color(0xD9FFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: isCompact ? 82 : 108,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.elliptical(560, 120),
                    topRight: Radius.elliptical(420, 90),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 18 : 30,
                isCompact ? 18 : 26,
                isCompact ? 18 : 28,
                isCompact ? 44 : 52,
              ),
              child: _IntroScene(kind: kind, isCompact: isCompact),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: isCompact ? 14 : 18,
              child: _ReferenceDots(
                activeIndex: switch (kind) {
                  _IntroIllustrationKind.explore => 0,
                  _IntroIllustrationKind.plan => 1,
                  _IntroIllustrationKind.documents => 2,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroScene extends StatelessWidget {
  const _IntroScene({required this.kind, required this.isCompact});

  final _IntroIllustrationKind kind;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case _IntroIllustrationKind.explore:
        return _ExploreScene(isCompact: isCompact);
      case _IntroIllustrationKind.plan:
        return _PlanScene(isCompact: isCompact);
      case _IntroIllustrationKind.documents:
        return _DocumentsScene(isCompact: isCompact);
    }
  }
}

class _ExploreScene extends StatelessWidget {
  const _ExploreScene({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -0.06,
        child: Container(
          width: isCompact ? 170 : 250,
          height: isCompact ? 118 : 162,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.all(isCompact ? 10 : 14),
          child: CustomPaint(
            painter: const _MapCardPainter(
              lineColor: Color(0xFF2B7BE8),
              fillColor: Color(0x402B7BE8),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanScene extends StatelessWidget {
  const _PlanScene({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: isCompact ? 22 : 38,
          bottom: isCompact ? 26 : 44,
          child: Container(
            width: isCompact ? 90 : 124,
            height: isCompact ? 28 : 38,
            decoration: BoxDecoration(
              color: const Color(0x332B7BE8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        Center(
          child: Transform.rotate(
            angle: -0.02,
            child: Icon(
              Icons.airplanemode_active_rounded,
              size: isCompact ? 118 : 164,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentsScene extends StatelessWidget {
  const _DocumentsScene({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: isCompact ? 190 : 270,
        height: isCompact ? 126 : 168,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: isCompact ? 20 : 30,
              top: isCompact ? 24 : 28,
              child: Transform.rotate(
                angle: -0.18,
                child: _PaperCard(
                  width: isCompact ? 70 : 94,
                  height: isCompact ? 88 : 116,
                  accent: const Color(0xFF2B7BE8),
                ),
              ),
            ),
            Positioned(
              right: isCompact ? 16 : 24,
              top: isCompact ? 18 : 24,
              child: Transform.rotate(
                angle: 0.10,
                child: _PaperCard(
                  width: isCompact ? 82 : 108,
                  height: isCompact ? 98 : 128,
                  accent: const Color(0xFF7E4DFF),
                  withCheck: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({
    required this.width,
    required this.height,
    required this.accent,
    this.withCheck = false,
  });

  final double width;
  final double height;
  final Color accent;
  final bool withCheck;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.36,
            height: 10,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: width * 0.58,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0x1F2B7BE8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: width * 0.46,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0x1F2B7BE8),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Spacer(),
          if (withCheck)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_rounded, size: 18, color: accent),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReferenceDots extends StatelessWidget {
  const _ReferenceDots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 10 : 6,
          height: isActive ? 10 : 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.secondary
                : AppColors.secondary.withValues(alpha: 0.38),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _MapCardPainter extends CustomPainter {
  const _MapCardPainter({required this.lineColor, required this.fillColor});

  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = fillColor;
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3;

    final left = Path()
      ..moveTo(size.width * 0.10, size.height * 0.18)
      ..lineTo(size.width * 0.39, size.height * 0.10)
      ..lineTo(size.width * 0.39, size.height * 0.78)
      ..lineTo(size.width * 0.10, size.height * 0.68)
      ..close();
    final middle = Path()
      ..moveTo(size.width * 0.39, size.height * 0.10)
      ..lineTo(size.width * 0.62, size.height * 0.20)
      ..lineTo(size.width * 0.62, size.height * 0.88)
      ..lineTo(size.width * 0.39, size.height * 0.78)
      ..close();
    final right = Path()
      ..moveTo(size.width * 0.62, size.height * 0.20)
      ..lineTo(size.width * 0.90, size.height * 0.08)
      ..lineTo(size.width * 0.90, size.height * 0.74)
      ..lineTo(size.width * 0.62, size.height * 0.88)
      ..close();

    canvas.drawPath(left, fillPaint);
    canvas.drawPath(middle, fillPaint);
    canvas.drawPath(right, fillPaint);
    canvas.drawPath(left, linePaint);
    canvas.drawPath(middle, linePaint);
    canvas.drawPath(right, linePaint);

    final continentPaint = Paint()..color = lineColor.withValues(alpha: 0.22);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.23,
        size.height * 0.34,
        size.width * 0.12,
        size.height * 0.14,
      ),
      continentPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.46,
        size.height * 0.30,
        size.width * 0.16,
        size.height * 0.20,
      ),
      continentPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.70,
        size.height * 0.34,
        size.width * 0.10,
        size.height * 0.13,
      ),
      continentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapCardPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

class _IntroTextContent extends StatelessWidget {
  const _IntroTextContent({
    required this.title,
    required this.description,
    required this.isCompact,
  });

  final String title;
  final String description;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: isCompact
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      crossAxisAlignment: isCompact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (!isCompact) const SizedBox(height: 22),
        Text(
          title,
          textAlign: isCompact ? TextAlign.center : TextAlign.left,
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style:
              (isCompact
                      ? Theme.of(context).textTheme.headlineLarge
                      : Theme.of(context).textTheme.displaySmall)
                  ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 0.98,
                    letterSpacing: -1.0,
                  ),
        ),
        SizedBox(height: isCompact ? 14 : 16),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isCompact ? 340 : 480),
          child: Text(
            description,
            textAlign: isCompact ? TextAlign.center : TextAlign.left,
            maxLines: isCompact ? 4 : 5,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              height: 1.5,
              fontSize: isCompact ? 16 : 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroBottomSection extends StatelessWidget {
  const _IntroBottomSection({
    required this.currentPage,
    required this.isCompact,
    required this.onDotTap,
    required this.onNext,
    required this.primaryLabel,
  });

  final int currentPage;
  final bool isCompact;
  final ValueChanged<int> onDotTap;
  final VoidCallback onNext;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PageDots(
          currentPage: currentPage,
          onDotTap: onDotTap,
          darkStyle: false,
        ),
        SizedBox(height: isCompact ? 16 : 18),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isCompact ? 340 : 220),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: currentPage == 2
                    ? AppColors.primary
                    : Colors.white,
                foregroundColor: currentPage == 2
                    ? Colors.white
                    : AppColors.primary,
                padding: EdgeInsets.symmetric(
                  vertical: isCompact ? 18 : 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: currentPage == 2
                        ? Colors.transparent
                        : AppColors.primary.withValues(alpha: 0.40),
                  ),
                ),
                elevation: 0,
              ),
              child: Text(
                primaryLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isCompact ? 16 : 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.currentPage,
    required this.onDotTap,
    required this.darkStyle,
  });

  final int currentPage;
  final ValueChanged<int> onDotTap;
  final bool darkStyle;

  @override
  Widget build(BuildContext context) {
    final activeColor = darkStyle ? Colors.white : AppColors.primary;
    final inactiveColor = darkStyle
        ? Colors.white.withValues(alpha: 0.22)
        : AppColors.primary.withValues(alpha: 0.24);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = currentPage == index;
        return GestureDetector(
          onTap: () => onDotTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

class _CircleGhostButton extends StatelessWidget {
  const _CircleGhostButton({
    required this.icon,
    required this.onPressed,
    required this.size,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: size * 0.46),
      ),
    );
  }
}

class _IntroBackground extends StatelessWidget {
  const _IntroBackground();

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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
